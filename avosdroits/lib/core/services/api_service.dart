import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  late final Dio dio;
  late final AuthProvider _authProvider;

  ApiService._internal() {
    dio = ApiConfig.createDio();
  }

  static void initialize(AuthProvider authProvider) {
    _instance._authProvider = authProvider;
    _instance._initializeDio();
  }

  void _initializeDio() {
    dio.options.baseUrl = ApiConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Allow self-signed certificates for development
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    // Add auth token interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authProvider.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<void> updateBaseUrl(String ip) async {
    await ApiConfig.updateBaseUrl(ip);
    dio.options.baseUrl = ApiConfig.baseUrl;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(endpoint);
          break;
        case 'POST':
          response = await dio.post(endpoint, data: data);
          break;
        case 'PUT':
          response = await dio.put(endpoint, data: data);
          break;
        case 'DELETE':
          response = await dio.delete(endpoint);
          break;
        default:
          throw ApiException(
            message: 'Method $method not supported',
            statusCode: 500,
          );
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Une erreur réseau s\'est produite: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    String message;
    int statusCode = error.response?.statusCode ?? 500;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Délai d\'attente dépassé';
        break;
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            if (data['errors'] != null && data['errors'] is Map) {
              final errors = data['errors'] as Map<String, dynamic>;
              final errorMessages = <String>[];
              
              errors.forEach((key, value) {
                if (value is List) {
                  errorMessages.addAll(value.cast<String>());
                } else if (value is String) {
                  errorMessages.add(value);
                }
              });
              
              message = errorMessages.join('\n');
            } else if (data['error'] is Map) {
              message = data['error']['message'] ?? 'Une erreur est survenue';
            } else if (data['message'] != null) {
              message = data['message'];
            } else if (data['error'] is String) {
              message = data['error'];
            } else {
              message = 'Une erreur est survenue';
            }
          } else {
            message = 'Une erreur est survenue';
          }
        } else {
          message = 'Une erreur est survenue';
        }
        break;
      default:
        message = 'Une erreur réseau s\'est produite';
    }

    return ApiException(message: message, statusCode: statusCode);
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Une erreur est survenue',
        statusCode: response.statusCode!,
      );
    }
  }

  // Auth Methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String password_confirmation,
  }) async {
    final result = await _makeRequest(
      'POST',
      ApiConfig.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'PasswordConfirmation': password_confirmation,
      },
    );

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      await _authProvider.setAuthenticationStatus(
        true,
        token: data['accessToken'],
        userId: data['user']['id'].toString(),
      );
    }

    return result;
  }

  Future<void> completeRegistration(Map<String, dynamic> registrationData) async {
    // Ensure we have the data
    if (registrationData['data'] == null || registrationData['data']['accessToken'] == null) {
      throw ApiException(
        message: 'Token d\'authentification manquant',
        statusCode: 401,
      );
    }

    final data = registrationData['data'];
    // Set the authentication status
    await _authProvider.setAuthenticationStatus(
      true,
      token: data['accessToken'],
      userId: data['user']['id'].toString(),
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResult = await _makeRequest(
        'POST',
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (loginResult['success'] == true) {
        await _authProvider.setAuthenticationStatus(
          true,
          token: loginResult['data']['accessToken'],
          userId: loginResult['data']['userId'],
        );
      }

      return loginResult;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String accessToken,
  }) async {
    final result = await _makeRequest(
      'POST',
      ApiConfig.socialLogin,
      data: {
        'provider': provider,
        'accessToken': accessToken,
      },
    );

    if (result['success'] == true) {
      await _authProvider.setAuthenticationStatus(
        true,
        token: result['data']['accessToken'],
        userId: result['data']['userId'],
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return _makeRequest(
      'POST',
      ApiConfig.forgotPassword,
      data: {'email': email},
    );
  }

  // Questionnaire Methods
  Future<Map<String, dynamic>> getQuestionnaireTemplate() async {
    print('Fetching questionnaire template...');
    return _makeRequest('GET', ApiConfig.questionnaireTemplate);
  }

  Future<Map<String, dynamic>> createResponse({
    required String questionId,
    required String answer,
    required String sessionId,
  }) async {
    return _makeRequest(
      'POST',
      ApiConfig.questionnaireResponses,
      data: {
        'questionId': questionId,
        'answer': answer,
        'sessionId': sessionId,
      },
    );
  }

  Future<Map<String, dynamic>> updateResponse({
    required String responseId,
    required String answer,
    required String sessionId,
  }) async {
    return _makeRequest(
      'PUT',
      ApiConfig.questionnaireResponse(responseId),
      data: {
        'answer': answer,
        'sessionId': sessionId,
      },
    );
  }

  Future<void> deleteResponse(String responseId) async {
    await _makeRequest('DELETE', ApiConfig.questionnaireResponse(responseId));
  }

  Future<Map<String, dynamic>> getResponse(String responseId) async {
    return _makeRequest('GET', ApiConfig.questionnaireResponse(responseId));
  }

  Future<Map<String, dynamic>> getMyResponses() async {
    return _makeRequest('GET', ApiConfig.myResponses);
  }

  Future<Map<String, dynamic>> getMyQuestionnaire() async {
    return _makeRequest('GET', ApiConfig.myQuestionnaire);
  }

  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    return _makeRequest('GET', ApiConfig.userProfile);
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    return _makeRequest('PUT', ApiConfig.userProfile, data: data);
  }

  // Verify authentication status
  Future<bool> verifyAuthentication() async {
    try {
      final token = await _authProvider.getToken();
      if (token == null) return false;

      final response = await _makeRequest('GET', ApiConfig.userProfile);
      return response['success'] == true;
    } catch (e) {
      print('Authentication verification failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _authProvider.logout();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
} 