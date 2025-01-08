import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7240/api';
  static const String _tokenKey = 'jwt_token';
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        // Handle unauthorized access
        await clearToken();
        throw Exception('Unauthorized access. Please login again.');
      }

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Check if the response contains a token (for auth endpoints)
        if (responseData['data']?['token'] != null) {
          await saveToken(responseData['data']['token']);
        }
        return responseData;
      } else {
        throw Exception(responseData['error']?['message'] ?? 'An error occurred');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Unauthorized access. Please login again.');
      }

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['error']?['message'] ?? 'An error occurred');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
} 