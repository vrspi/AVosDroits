import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthProvider authProvider;

  ApiService({required this.authProvider});

  Future<Map<String, dynamic>> _makeRequest(String method, String endpoint, {Map<String, dynamic>? body}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await authProvider.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('Token is present: $token');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw ApiException(
            message: 'Method $method not supported',
            statusCode: 500,
          );
      }

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Une erreur réseau s\'est produite: ${e.toString()}',
        statusCode: 500,
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
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password_confirmation,
      },
    );

    if (result['success'] == true) {
      await authProvider.setAuthenticationStatus(
        true,
        token: result['data']['accessToken'],
        userId: result['data']['userId'],
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResult = await _makeRequest(
        'POST',
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (loginResult['success'] == true) {
        await authProvider.setAuthenticationStatus(
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
      body: {
        'provider': provider,
        'accessToken': accessToken,
      },
    );

    if (result['success'] == true) {
      await authProvider.setAuthenticationStatus(
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
      body: {'email': email},
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
      body: {
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
      body: {
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
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;

    return _makeRequest('PUT', ApiConfig.userProfile, body: body);
  }

  // Verify authentication status
  Future<bool> verifyAuthentication() async {
    try {
      final token = await authProvider.getToken();
      if (token == null) return false;

      final response = await _makeRequest('GET', ApiConfig.userProfile);
      return response['success'] == true;
    } catch (e) {
      print('Authentication verification failed: $e');
      return false;
    }
  }

  // Helper method to handle API responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage;
      
      if (body['errors'] != null && body['errors'] is Map) {
        // Handle validation errors
        final errors = body['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.cast<String>());
          } else if (value is String) {
            errorMessages.add(value);
          }
        });
        
        errorMessage = errorMessages.join('\n');
      } else if (body['error'] is Map) {
        errorMessage = body['error']['message'] ?? 'Une erreur est survenue';
      } else if (body['message'] != null) {
        errorMessage = body['message'];
      } else if (body['error'] is String) {
        errorMessage = body['error'];
      } else {
        errorMessage = 'Une erreur est survenue';
      }
      
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> logout() async {
    await authProvider.logout();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
} 