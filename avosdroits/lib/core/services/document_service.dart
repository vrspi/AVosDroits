import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/document.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class DocumentService {
  final Dio _dio;

  DocumentService() : _dio = ApiService.instance.dio {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<List<UserFolder>> getUserFolders() async {
    await _initializeDio();
    try {
      final response = await _dio.get('/Folder');
      return (response.data as List)
          .map((json) => UserFolder.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user folders: $e');
    }
  }

  Future<UserFolder> createFolder(String folderName) async {
    await _initializeDio();
    try {
      final response = await _dio.post(
        '/Folder',
        queryParameters: {'folderName': folderName},
      );
      return UserFolder.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  Future<void> deleteFolder(int folderId) async {
    await _initializeDio();
    try {
      await _dio.delete('/Folder/$folderId');
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  Future<Document> uploadDocument(
    PlatformFile file,
    String description,
    String category, {
    int? folderId,
  }) async {
    await _initializeDio();
    try {
      FormData formData;
      
      if (kIsWeb) {
        // Handle web upload
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            file.bytes!,
            filename: file.name,
          ),
          'description': description,
          'category': category,
          if (folderId != null) 'folderId': folderId,
        });
      } else {
        // Handle mobile upload
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
          ),
          'description': description,
          'category': category,
          if (folderId != null) 'folderId': folderId,
        });
      }

      final response = await _dio.post(
        '/Document/upload',
        data: formData,
      );

      if (response.data['success']) {
        return Document.fromJson(response.data['document']);
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<List<Document>> getUserDocuments({int? folderId}) async {
    await _initializeDio();
    try {
      final response = await _dio.get(
        '/Document/list',
        queryParameters: folderId != null ? {'folderId': folderId} : null,
      );
      return (response.data as List)
          .map((json) => Document.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user documents: $e');
    }
  }

  Future<void> deleteDocument(String id) async {
    await _initializeDio();
    try {
      await _dio.delete('/Document/$id');
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<void> downloadDocument(String id, String savePath) async {
    await _initializeDio();
    try {
      final response = await _dio.get(
        '/Document/$id',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );

      if (kIsWeb) {
        // Handle web download (you might want to use a different approach for web)
        throw Exception('Download not supported on web platform yet');
      } else {
        File(savePath).writeAsBytesSync(response.data);
      }
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  Future<String> getDocumentUrl(String id) async {
    await _initializeDio();
    try {
      final baseUrl = ApiConfig.baseUrl;
      return '$baseUrl/Document/$id';
    } catch (e) {
      throw Exception('Failed to get document URL: $e');
    }
  }
} 