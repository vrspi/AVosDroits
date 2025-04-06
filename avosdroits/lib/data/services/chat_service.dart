import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import '../../domain/models/chat_response.dart';
import '../../utils/constants.dart';

class ChatService {
  final String baseUrl;

  ChatService({required this.baseUrl});

  // Helper method for better logging
  void _log(String message) {
    print('CHAT_SERVICE: $message');
    
    // Use developer.log for browser console
    if (kIsWeb) {
      developer.log('CONSOLE_DEBUG: $message', name: 'ChatService');
    }
  }

  Future<ChatResponse> sendMessage(String message, List<Map<String, String>> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Only add authorization header if token exists
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        _log('Using auth token: ${token.substring(0, min(10, token.length))}...');
      } else {
        _log('No authentication token found - proceeding without authentication');
      }

      // Format history to match backend ChatMessageDTO exactly
      final formattedHistory = history.map((msg) => {
        'role': msg['role'] ?? '',
        'content': msg['content'] ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      }).toList();

      final requestBody = {
        'message': message,
        'history': formattedHistory,
      };

      _log('=== ChatService Request ===');
      _log('URL: $baseUrl/api/Chatbot/chat');
      _log('Headers: $headers');
      _log('Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/Chatbot/chat'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      _log('=== ChatService Response ===');
      _log('Status code: ${response.statusCode}');
      _log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          _log('Parsed JSON response: $jsonResponse');
          
          if (jsonResponse['success'] == true) {
            try {
              final responseData = jsonResponse['response'];
              _log('Response data: $responseData');
              
              _log('Raw options from response: ${responseData['options']}');
              _log('Options type: ${responseData['options'].runtimeType}');
              
              // Add extra debug info about options
              final rawOptions = responseData['options'] ?? [];
              _log('OPTIONS COUNT: ${rawOptions.length}');
              for (int i = 0; i < rawOptions.length; i++) {
                _log('OPTION $i: ${rawOptions[i]}');
              }
              
              final List<dynamic> rawOptionsList = rawOptions;
              _log('Raw options after conversion: $rawOptionsList');
              
              final options = rawOptionsList.map((option) {
                _log('Processing option object: $option');
                _log('Option type: ${option.runtimeType}');
                
                if (option is! Map<String, dynamic>) {
                  _log('Converting option to map: $option');
                  // Try to handle the case where option might not be a map
                  try {
                    if (option is String) {
                      return ChatOption(
                        id: '0',
                        text: option,
                        icon: '',
                        description: '',
                      );
                    }
                  } catch (e) {
                    _log('Error converting option: $e');
                  }
                  return null;
                }
                
                // Ensure all fields are properly converted to the expected types
                try {
                  final chatOption = ChatOption(
                    id: option['id']?.toString() ?? '',
                    text: option['text']?.toString() ?? '',
                    icon: option['icon']?.toString() ?? '',
                    description: option['description']?.toString() ?? '',
                  );
                  _log('Created ChatOption: $chatOption');
                  return chatOption;
                } catch (e) {
                  _log('Error creating ChatOption: $e');
                  return null;
                }
              }).where((option) => option != null).cast<ChatOption>().toList();
              
              _log('Final processed options list: $options');
              _log('Final options count: ${options.length}');

              final chatResponse = ChatResponse(
                message: responseData['message'] as String,
                options: options,
                context: responseData['context'] as String?,
                expectingChoice: responseData['expectingChoice'] as bool? ?? false,
              );
              _log('Created ChatResponse object: $chatResponse');
              return chatResponse;
            } catch (e) {
              _log('Error processing response data: $e');
              // Return a simplified response without options to prevent app crash
              return ChatResponse(
                message: jsonResponse['response']['message'] as String? ?? 
                         'Désolé, une erreur est survenue lors du traitement de la réponse.',
                options: [],
                context: null,
                expectingChoice: false,
              );
            }
          } else {
            _log('API returned success: false with message: ${jsonResponse['message']}');
            throw Exception(jsonResponse['message'] ?? 'Unknown error');
          }
        } catch (e) {
          _log('JSON parsing error: $e');
          // Return a fallback response if JSON parsing fails
          return ChatResponse(
            message: 'Désolé, une erreur est survenue lors du traitement de la réponse du serveur.',
            options: [],
            context: null,
            expectingChoice: false,
          );
        }
      } else if (response.statusCode == 401) {
        _log('Authentication error: 401 Unauthorized');
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else {
        _log('API error: Status ${response.statusCode}');
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Une erreur est survenue';
          _log('Parsed error message: $errorMessage');
        } catch (e) {
          errorMessage = 'Une erreur est survenue (${response.statusCode})';
          _log('Failed to parse error body: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _log('Error in ChatService.sendMessage: $e');
      rethrow;
    }
  }
} 