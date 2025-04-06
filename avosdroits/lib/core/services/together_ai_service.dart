import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import 'api_service.dart';

class ChatMessage {
  final String role;  // 'user', 'assistant', or 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}

class TogetherAIService {
  final AuthProvider _authProvider;
  static TogetherAIService? _instance;
  final List<ChatMessage> _messageHistory = [];
  String? _systemContext;
  Map<String, dynamic>? _lastApiResponseData;

  TogetherAIService._({required AuthProvider authProvider}) : _authProvider = authProvider;

  static TogetherAIService get instance {
    if (_instance == null) {
      throw Exception('TogetherAIService not initialized. Call TogetherAIService.initialize() first.');
    }
    return _instance!;
  }

  static void initialize({required AuthProvider authProvider}) {
    _instance = TogetherAIService._(authProvider: authProvider);
  }

  List<ChatMessage> get messageHistory => List.unmodifiable(_messageHistory);

  void clearHistory() {
    _messageHistory.clear();
    _systemContext = null;
  }

  String _getNetworkErrorMessage() {
    if (kIsWeb) {
      return 'Impossible de se connecter au serveur. Veuillez vérifier que:\n'
             '1. Le serveur est en cours d\'exécution\n'
             '2. L\'adresse du serveur est correcte (${ApiConfig.baseUrl})\n'
             '3. Votre connexion Internet est active\n\n'
             'Note: Si vous utilisez HTTPS, assurez-vous que le certificat est valide.\n'
             'Si le problème persiste, contactez le support technique.';
    } else {
      return 'Impossible de se connecter au serveur. Veuillez vérifier que:\n'
             '1. Votre appareil est connecté au même réseau que le serveur\n'
             '2. Le serveur est en cours d\'exécution\n'
             '3. L\'adresse IP du serveur est correcte (${ApiConfig.baseUrl})\n\n'
             'Si le problème persiste, contactez le support technique.';
    }
  }

  // Get the last API response data
  Map<String, dynamic>? getLastApiResponseData() {
    return _lastApiResponseData;
  }

  Future<String> getChatResponse(String userMessage) async {
    try {
      developer.log('TOGETHER_AI: Getting chat response for message: $userMessage', name: 'TogetherAIService');

      // Add user message to history
      _messageHistory.add(ChatMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ));

      developer.log('TOGETHER_AI: Sending API request with history size: ${_messageHistory.length}', name: 'TogetherAIService');
      
      final response = await ApiService.instance.dio.post(
        '/Chatbot/chat',
        data: {
          'message': userMessage,
          'history': _messageHistory.map((msg) => msg.toJson()).toList(),
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      developer.log('TOGETHER_AI: Received response with status: ${response.statusCode}', name: 'TogetherAIService');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data;
        developer.log('TOGETHER_AI: Response data: $data', name: 'TogetherAIService');
        
        // Store the full API response data for later use
        _lastApiResponseData = Map<String, dynamic>.from(data);
        
        final assistantMessage = data['response']['message'] as String;
        
        // Check for options in the response
        List<dynamic>? options;
        try {
          if (data['response'].containsKey('options')) {
            options = data['response']['options'];
            developer.log('TOGETHER_AI: Found options in response: $options', name: 'TogetherAIService');
            
            // Append options to the message for the chatbot to extract
            if (options != null && options.isNotEmpty) {
              final optionsText = options.map((opt) => "- ${opt.toString()}").join("\n");
              developer.log('TOGETHER_AI: Options text: $optionsText', name: 'TogetherAIService');
              
              // Add options marker and list to the end of the message
              String messageWithOptions = assistantMessage;
              if (!messageWithOptions.contains("OPTIONS:")) {
                messageWithOptions += "\n\nOPTIONS:\n$optionsText";
              }
              
              // Add assistant response to history with options
              _messageHistory.add(ChatMessage(
                role: 'assistant',
                content: messageWithOptions,
                timestamp: DateTime.now(),
              ));
              
              print('Full response message with options: $messageWithOptions'); // Debug log
              return messageWithOptions;
            }
          } else {
            developer.log('TOGETHER_AI: No options found in response', name: 'TogetherAIService');
          }
        } catch (e) {
          developer.log('TOGETHER_AI: Error processing options: $e', name: 'TogetherAIService');
        }
        
        // Add assistant response to history (without options if not found or error)
        _messageHistory.add(ChatMessage(
          role: 'assistant',
          content: assistantMessage,
          timestamp: DateTime.now(),
        ));

        print('Full response message: $assistantMessage'); // Debug log
        return assistantMessage;
      } else {
        developer.log('TOGETHER_AI: Error response: ${response.data}', name: 'TogetherAIService');
        print('Error response: ${response.data}');
        throw Exception('Erreur de l\'API: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      developer.log('TOGETHER_AI: DioException caught: $e', name: 'TogetherAIService');
      print('DioException caught: $e');
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(_getNetworkErrorMessage());
      }
      throw Exception('Une erreur réseau s\'est produite: ${e.message}');
    } catch (e) {
      developer.log('TOGETHER_AI: Exception caught: $e', name: 'TogetherAIService');
      print('Exception caught: $e');
      throw Exception('Une erreur inattendue s\'est produite: $e');
    }
  }

  // Helper method to add system messages or context
  void addSystemContext(String context) {
    _systemContext = context;
    _messageHistory.add(ChatMessage(
      role: 'system',
      content: context,
      timestamp: DateTime.now(),
    ));
  }

  // Get the current system context
  String? get systemContext => _systemContext;
} 