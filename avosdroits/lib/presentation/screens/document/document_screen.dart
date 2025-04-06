import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/document.dart';
import '../../../core/services/document_service.dart';
import '../../../core/theme/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' if (dart.library.html) 'dart:html' as html;

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({Key? key}) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final DocumentService _documentService = DocumentService();
  List<Document> _documents = [];
  List<UserFolder> _folders = [];
  int? _selectedFolderId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _documentService.getUserFolders(),
        _documentService.getUserDocuments(folderId: _selectedFolderId),
      ]);
      setState(() {
        _folders = futures[0] as List<UserFolder>;
        _documents = futures[1] as List<Document>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createFolder() async {
    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => _CreateFolderDialog(),
    );

    if (folderName != null && folderName.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final folder = await _documentService.createFolder(folderName);
        setState(() {
          _folders.add(folder);
          _selectedFolderId = folder.id;
        });
        await _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating folder: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteFolder(UserFolder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"? This will not delete the files inside.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _documentService.deleteFolder(folder.id);
        setState(() {
          _folders.removeWhere((f) => f.id == folder.id);
          if (_selectedFolderId == folder.id) {
            _selectedFolderId = null;
          }
        });
        await _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting folder: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result;
      if (kIsWeb) {
        // For web, only allow file selection with withData enabled
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
          withData: true, // Important for web to get the bytes
          allowMultiple: false,
        );
      } else {
        // Show upload options dialog for mobile
        final source = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choisir la source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Choisir un fichier'),
                  onTap: () => Navigator.pop(context, 'file'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
              ],
            ),
          ),
        );

        if (source == null) return;

        if (source == 'camera') {
          final ImagePicker picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
            preferredCameraDevice: CameraDevice.rear,
          );

          if (image == null) return;

          final bytes = await image.readAsBytes();
          result = FilePickerResult([
            PlatformFile(
              name: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
              size: bytes.length,
              bytes: bytes,
            ),
          ]);
        } else {
          result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
          );
        }
      }

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      // Ensure we have either bytes (for web) or path (for mobile)
      if (kIsWeb && file.bytes == null) {
        throw Exception('No file data available');
      } else if (!kIsWeb && file.path == null) {
        throw Exception('No file path available');
      }

      // Show dialog for description, category, and folder selection
      final data = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _UploadDialog(
          folders: _folders,
          fileName: file.name,
        ),
      );

      if (data != null) {
        setState(() => _isLoading = true);

        // Create a new PlatformFile with the custom name if provided
        PlatformFile uploadFile;
        if (data['fileName'] != null && data['fileName'].isNotEmpty) {
          // Extract the extension from the original filename, preserving its exact format
          final lastDotIndex = file.name.lastIndexOf('.');
          final originalExtension = lastDotIndex >= 0 ? file.name.substring(lastDotIndex) : '';
          
          // Add the original extension to the new filename
          final newFileName = data['fileName'] + originalExtension;
          
          if (kIsWeb) {
            uploadFile = PlatformFile(
              name: newFileName,
              size: file.size,
              bytes: file.bytes,
            );
          } else {
            uploadFile = PlatformFile(
              name: newFileName,
              size: file.size,
              path: file.path,
            );
          }
        } else {
          uploadFile = file;
        }

        try {
          await _documentService.uploadDocument(
            uploadFile,
            data['description']!,
            data['category']!,
            folderId: data['folderId'],
          );

          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document téléchargé avec succès')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur lors du téléchargement: $e')),
            );
          }
          rethrow;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _downloadDocument(Document document) async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        // For web, we'll use the document URL directly with auth headers
        final url = await _documentService.getDocumentUrl(document.id);
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        
        // Create an anchor element with auth header
        final anchor = html.AnchorElement()
          ..href = url
          ..setAttribute('download', document.fileName)
          ..style.display = 'none'
          ..setAttribute('data-auth', 'Bearer $token');  // This will be used by the browser

        // Add custom headers using XMLHttpRequest
        final xhr = html.HttpRequest();
        xhr.open('GET', url);
        xhr.setRequestHeader('Authorization', 'Bearer $token');
        xhr.responseType = 'blob';
        
        xhr.onLoad.listen((event) {
          final blob = html.Blob([xhr.response]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          final anchor = html.AnchorElement()
            ..href = url
            ..setAttribute('download', document.fileName)
            ..style.display = 'none';
            
          html.document.body?.children.add(anchor);
          anchor.click();
          html.document.body?.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        });
        
        xhr.onError.listen((event) {
          throw Exception('Failed to download file');
        });
        
        xhr.send();
      } else {
        // For mobile platforms
        final directory = await getApplicationDocumentsDirectory();
        final savePath = '${directory.path}/${document.fileName}';
        await _documentService.downloadDocument(document.id, savePath);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document downloaded to: $savePath')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading document: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteDocument(Document document) async {
    try {
      setState(() => _isLoading = true);
      await _documentService.deleteDocument(document.id);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewDocument(Document document) async {
    final downloadUrl = await _documentService.getDocumentUrl(document.id);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewer(
          url: downloadUrl,
          mimeType: document.contentType,
        ),
      ),
    );

    if (result == true) {
      _downloadDocument(document);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffre Fort'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: _createFolder,
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_folders.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            value: _selectedFolderId,
                            decoration: InputDecoration(
                              labelText: 'Select Folder',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All Documents'),
                              ),
                              ..._folders.map((folder) => DropdownMenuItem<int?>(
                                value: folder.id,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(folder.name),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteFolder(folder),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                            onChanged: (folderId) {
                              setState(() {
                                _selectedFolderId = folderId;
                              });
                              _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _documents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun document',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _uploadDocument,
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Upload Document'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _documents.length,
                          itemBuilder: (context, index) {
                            final document = _documents[index];
                            final isImage = document.contentType.startsWith('image/');
                            final isPdf = document.contentType == 'application/pdf';
                            final canPreview = isImage || isPdf;
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: InkWell(
                                onTap: canPreview ? () => _viewDocument(document) : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isImage ? Icons.image :
                                          isPdf ? Icons.picture_as_pdf :
                                          Icons.insert_drive_file,
                                          color: isImage ? Colors.blue :
                                                 isPdf ? Colors.red :
                                                 Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document.fileName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (document.description != null)
                                              Text(
                                                document.description!,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            Row(
                                              children: [
                                                if (document.category != null)
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 8),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[50],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      document.category!,
                                                      style: TextStyle(
                                                        color: Colors.blue[700],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                if (document.folderName != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      document.folderName!,
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'view':
                                              if (canPreview) _viewDocument(document);
                                              break;
                                            case 'download':
                                              _downloadDocument(document);
                                              break;
                                            case 'delete':
                                              _deleteDocument(document);
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          if (canPreview)
                                            const PopupMenuItem(
                                              value: 'view',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.visibility),
                                                  SizedBox(width: 8),
                                                  Text('View'),
                                                ],
                                              ),
                                            ),
                                          const PopupMenuItem(
                                            value: 'download',
                                            child: Row(
                                              children: [
                                                Icon(Icons.download),
                                                SizedBox(width: 8),
                                                Text('Download'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }
}

class _CreateFolderDialog extends StatefulWidget {
  @override
  _CreateFolderDialogState createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<_CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Folder'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _folderNameController,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a folder name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_folderNameController.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _UploadDialog extends StatefulWidget {
  final List<UserFolder> folders;
  final String fileName;

  const _UploadDialog({required this.folders, required this.fileName});

  @override
  _UploadDialogState createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Personnel';
  int? _selectedFolderId;

  final List<String> _categories = [
    'Personnel',
    'Professionnel',
    'Médical',
    'Juridique',
    'Financier',
    'Autre'
  ];

  @override
  void dispose() {
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Document'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du fichier',
                  border: OutlineInputBorder(),
                  hintText: 'ex: facture_edf_2024.pdf',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de fichier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'ex: Facture EDF du mois de janvier 2024',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (widget.folders.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: _selectedFolderId,
                  decoration: const InputDecoration(
                    labelText: 'Dossier (Optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Aucun dossier'),
                    ),
                    ...widget.folders.map((folder) => DropdownMenuItem<int?>(
                      value: folder.id,
                      child: Text(folder.name),
                    )),
                  ],
                  onChanged: (int? folderId) {
                    setState(() {
                      _selectedFolderId = folderId;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'fileName': _fileNameController.text,
                'description': _descriptionController.text,
                'category': _selectedCategory,
                'folderId': _selectedFolderId,
              });
            }
          },
          child: const Text('Télécharger'),
        ),
      ],
    );
  }
}

class DocumentViewer extends StatelessWidget {
  final String url;
  final String mimeType;

  const DocumentViewer({
    Key? key,
    required this.url,
    required this.mimeType,
  }) : super(key: key);

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              Navigator.pop(context, true); // Return true to trigger download
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getAuthHeaders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final headers = snapshot.data!;
          
          if (mimeType.startsWith('image/')) {
            return PhotoView(
              imageProvider: NetworkImage(
                url,
                headers: headers,
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          } else if (mimeType == 'application/pdf') {
            return SfPdfViewer.network(
              url,
              headers: headers,
            );
          } else {
            return const Center(
              child: Text('This file type cannot be previewed'),
            );
          }
        },
      ),
    );
  }
} 