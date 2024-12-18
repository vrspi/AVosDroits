import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;
  String? _token;

  // Set token after login/registration
  void setToken(String token) {
    _token = token;
  }

  // Headers for authenticated requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth Methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String password_confirmation,
  }) async {
    final requestBody = {
      'name': name,
      'email': email,
      'password': password,
      'passwordConfirmation': password_confirmation,
    };
    
    print('Register Request URL: $baseUrl${ApiConfig.register}');
    print('Register Request Headers: $_headers');
    print('Register Request Body: ${jsonEncode(requestBody)}');
    
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.register}'),
      headers: _headers,
      body: jsonEncode(requestBody),
    );

    print('Register Response Status Code: ${response.statusCode}');
    print('Register Response Body: ${response.body}');

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.login}'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String accessToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.socialLogin}'),
      headers: _headers,
      body: jsonEncode({
        'provider': provider,
        'accessToken': accessToken,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.forgotPassword}'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    return _handleResponse(response);
  }

  // Questionnaire Methods
  Future<Map<String, dynamic>> getQuestionnaire() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.getQuestionnaire}'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> submitQuestionnaire({
    required List<Map<String, dynamic>> sections,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.submitQuestionnaire}'),
      headers: _headers,
      body: jsonEncode({
        'sections': sections,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateQuestionnaire({
    required String userId,
    required List<Map<String, dynamic>> sections,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl${ApiConfig.updateQuestionnaire(userId)}'),
      headers: _headers,
      body: jsonEncode({
        'sections': sections,
      }),
    );

    return _handleResponse(response);
  }

  // User Profile Methods
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiConfig.userProfile}'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl${ApiConfig.userProfile}'),
      headers: _headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      }),
    );

    return _handleResponse(response);
  }

  // Helper method to handle API responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage;
      if (body['error'] is Map) {
        errorMessage = body['error']['message'] ?? 'An error occurred';
      } else if (body['message'] != null) {
        errorMessage = body['message'];
      } else if (body['error'] is String) {
        errorMessage = body['error'];
      } else {
        errorMessage = 'An error occurred';
      }
      
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
} 