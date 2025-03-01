import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static String _baseUrl = 'https://localhost:7076/api'; // Changed to HTTPS and correct port

  // Getter for baseUrl
  static String get baseUrl => _baseUrl;

  // Method to update the base URL
  static Future<void> updateBaseUrl(String ip) async {
    _baseUrl = 'https://$ip:7076/api'; // Using HTTPS
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _baseUrl);
  }

  static Future<void> initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_base_url');
    if (savedUrl != null) {
      _baseUrl = savedUrl;
    }
  }

  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
      validateStatus: (status) {
        return status != null && status < 500;
      },
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Configure to accept self-signed certificates
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return true; // Accept all certificates
        };
        return client;
      };
    }

    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('Error occurred: ${error.type} - ${error.message}');
        print('Error details: ${error.error}');
        
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: 'Le serveur met trop de temps à répondre. Veuillez réessayer.',
          ));
        }
        
        if (error.error is SocketException) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: 'Impossible de se connecter au serveur. Vérifiez votre connexion et l\'adresse IP.',
          ));
        }

        if (error.type == DioExceptionType.badResponse) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: 'Le serveur a retourné une réponse invalide. Veuillez réessayer.',
          ));
        }

        return handler.next(error);
      },
      onRequest: (options, handler) {
        print('Making request to: ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data == null || response.data.toString().isEmpty) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              error: 'Le serveur a retourné une réponse vide',
            ),
          );
        }
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return handler.next(response);
      },
    ));

    return dio;
  }

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String socialLogin = '/auth/social-login';
  static const String forgotPassword = '/auth/forgot-password';

  // User Profile endpoints
  static const String userProfile = '/user/profile';

  // Questionnaire endpoints
  static const String questionnaireTemplate = '/questionnaire/questions/template';
  static const String questionnaireResponses = '/questionnaire/responses';
  static String questionnaireResponse(String responseId) => '/questionnaire/responses/$responseId';
  static const String myResponses = '/questionnaire/responses/my';
  static const String myQuestionnaire = '/questionnaire/my';

  // Chatbot endpoint
  static const String chatbot = '/Chatbot/message';
} 