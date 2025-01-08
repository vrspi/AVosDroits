import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class TogetherAIService {
  final AuthProvider _authProvider;

  TogetherAIService({required AuthProvider authProvider}) : _authProvider = authProvider;

  Future<String> getChatResponse(String userMessage) async {
    try {
      final token = await _authProvider.getToken();
      final url = '${ApiConfig.baseUrl}${ApiConfig.chatbot}';
      print('Making request to: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('Error response: ${response.body}');
        throw Exception('Erreur de l\'API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Une erreur inattendue s\'est produite: $e');
    }
  }
} 