class Document {
  final String id;
  final String fileName;
  final String contentType;
  final int fileSize;
  final DateTime uploadDate;
  final String? description;
  final String? category;
  final int? folderId;
  final String? folderName;

  Document({
    required this.id,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.uploadDate,
    this.description,
    this.category,
    this.folderId,
    this.folderName,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileName: json['fileName'],
      contentType: json['contentType'],
      fileSize: json['fileSize'],
      uploadDate: DateTime.parse(json['uploadDate']),
      description: json['description'],
      category: json['category'],
      folderId: json['folderId'],
      folderName: json['folderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'contentType': contentType,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'description': description,
      'category': category,
      'folderId': folderId,
      'folderName': folderName,
    };
  }
}

class UserFolder {
  final int id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserFolder({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserFolder.fromJson(Map<String, dynamic> json) {
    return UserFolder(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
} 