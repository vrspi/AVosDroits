import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart' show Characters;
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/services/together_ai_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/config/api_config.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? options;
  final bool showInput;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.options,
    this.showInput = false,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late final TogetherAIService _aiService;
  bool _isLoading = false;
  bool _isTyping = false;
  bool _showInput = false;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _aiService = TogetherAIService.instance;
    
    // Add initial system context
    _aiService.clearHistory();
    _aiService.addSystemContext(
      'Vous êtes un assistant juridique spécialisé dans le droit français. '
      'Votre rôle est d\'aider les utilisateurs à comprendre leurs droits et '
      'les procédures juridiques. Vos réponses doivent être précises, '
      'professionnelles et adaptées au contexte français.'
    );
    
    _showWelcomeMessage();
  }

  void _showWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: 'Bonjour! Je suis votre assistant juridique. Je peux vous aider avec des questions concernant le droit français. '
              'Pour vous fournir les meilleures réponses possibles, je garderai en mémoire notre conversation et j\'ai accès à vos documents. '
              'Comment puis-je vous aider aujourd\'hui?',
        isUser: false,
        timestamp: DateTime.now(),
        options: [
          'Questions sur mes documents',
          'Droit du travail',
          'Droit de la famille',
          'Droit de la santé',
          'Droit du logement',
          'Autre',
        ],
      ),
    );
    setState(() {});
  }

  void _handleOptionSelected(String option) async {
    // Log the selected option
    developer.log('CHATBOT: Option selected: "$option"', name: 'ChatbotScreen');
    
    // Clean up option text - if it starts with an emoji (typically followed by a space)
    String cleanOption = option;
    
    // Try to detect emoji at the start of the option
    if (option.isNotEmpty) {
      // Check if the first character might be an emoji
      final firstChar = option.characters.first;
      
      if (firstChar.codeUnitAt(0) > 127 || firstChar == '👤' || firstChar == '🏢' || firstChar == '🚑' || 
          firstChar == '📝' || firstChar == '❓' || firstChar == '⬅️') {
        
        // Find the first space after the emoji
        int spaceIndex = option.indexOf(' ');
        if (spaceIndex > 0) {
          cleanOption = option.substring(spaceIndex + 1).trim();
          developer.log('CHATBOT: Cleaned option from "$option" to "$cleanOption"', name: 'ChatbotScreen');
        } else {
          developer.log('CHATBOT: Option starts with emoji but has no space after it: "$option"', name: 'ChatbotScreen');
        }
      } else {
        developer.log('CHATBOT: No emoji detected at start of option: "$option"', name: 'ChatbotScreen');
      }
    }

    setState(() {
      // Add user's selection as a message
      _messages.add(ChatMessage(
        text: option, // Show original option with icon in the message
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      String followUpMessage;
      List<String>? followUpOptions;

      // Use the cleaned option text for the switch statement
      developer.log('CHATBOT: Processing option with clean text: "$cleanOption"', name: 'ChatbotScreen');
      
      // Check for "Retour au menu principal" option first, regardless of emoji
      if (cleanOption.toLowerCase().contains('retour au menu') || 
          cleanOption.toLowerCase().contains('return to main')) {
        
        developer.log('CHATBOT: Handling return to main menu option', name: 'ChatbotScreen');
        followUpMessage = 'Bien sûr, comment puis-je vous aider?';
        followUpOptions = [
          '📄 Questions sur mes documents',
          '👔 Droit du travail',
          '👪 Droit de la famille',
          '🏥 Droit de la santé',
          '🏠 Droit du logement',
          '❓ Autre'
        ];
      } else {
        // Handle other options or send to AI
        switch (cleanOption) {
          case 'Questions sur mes documents':
            followUpMessage = 'Je peux vous aider à comprendre vos documents. '
                'Que souhaitez-vous savoir à propos de vos documents?';
            followUpOptions = [
              '📄 Résumer mes documents',
              '🔍 Chercher un document spécifique',
              '📊 Analyser un document',
              '⬅️ Retour au menu principal'
            ];
            break;
          case 'Droit de la famille':
            followUpMessage = 'Certainement, je peux vous aider avec des informations sur le droit de la famille. '
                'Pouvez-vous préciser votre demande? Avez-vous besoin d\'informations sur le mariage, le divorce, la '
                'garde des enfants, l\'adoption ou autre chose?';
            followUpOptions = [
              '💍 Le mariage',
              '📝 Le divorce',
              '👪 La garde des enfants',
              '👶 L\'adoption',
              '❓ Autre sujet',
              '⬅️ Retour au menu principal'
            ];
            break;
          case 'Droit du travail':
            followUpMessage = 'Je peux vous aider avec vos questions sur le droit du travail. '
                'Quel aspect du droit du travail vous intéresse?';
            followUpOptions = [
              '📝 Contrat de travail',
              '🔄 Licenciement',
              '🏖️ Congés',
              '💰 Salaire',
              '⚠️ Harcèlement',
              '⬅️ Retour au menu principal'
            ];
            break;
          case 'Droit de la santé':
            followUpMessage = 'Je peux vous aider avec vos questions sur le droit de la santé. '
                'Quel aspect vous intéresse?';
            followUpOptions = [
              '🏥 Droits des patients',
              '⚕️ Responsabilité médicale',
              '💉 Assurance maladie',
              '🚑 Accident médical',
              '❓ Autre sujet',
              '⬅️ Retour au menu principal'
            ];
            break;
          case 'Droit du logement':
            followUpMessage = 'Je peux vous aider avec vos questions sur le droit du logement. '
                'Quel aspect vous intéresse?';
            followUpOptions = [
              '🏠 Location',
              '🏢 Achat immobilier',
              '🔑 Copropriété',
              '📤 Expulsion',
              '❓ Autre sujet',
              '⬅️ Retour au menu principal'
            ];
            break;
          default:
            // For all other options, get AI response
            developer.log('CHATBOT: Sending option to AI: $cleanOption', name: 'ChatbotScreen');
            final response = await _aiService.getChatResponse(cleanOption);
            
            // Process the API response
            // Clean the message to remove OPTIONS, CONTEXT, and EXPECTING CHOICE sections
            followUpMessage = response;
            
            // Remove OPTIONS section
            if (response.contains("\n\nOPTIONS:")) {
              followUpMessage = response.split("\n\nOPTIONS:")[0].trim();
              developer.log('CHATBOT: Removed OPTIONS section from option response', name: 'ChatbotScreen');
            }
            
            // Remove CONTEXT section if present
            if (followUpMessage.contains("\n\nCONTEXT:")) {
              followUpMessage = followUpMessage.split("\n\nCONTEXT:")[0].trim();
              developer.log('CHATBOT: Removed CONTEXT section from option response', name: 'ChatbotScreen');
            }
            
            // Remove EXPECTING CHOICE section if present
            if (followUpMessage.contains("\n\nEXPECTING CHOICE:")) {
              followUpMessage = followUpMessage.split("\n\nEXPECTING CHOICE:")[0].trim();
              developer.log('CHATBOT: Removed EXPECTING CHOICE section from option response', name: 'ChatbotScreen');
            }
            
            // Check if there are options in the API response
            final apiResponseData = _aiService.getLastApiResponseData();
            if (apiResponseData != null && 
                apiResponseData.containsKey('response') &&
                apiResponseData['response'] is Map<String, dynamic> &&
                apiResponseData['response'].containsKey('options') &&
                apiResponseData['response']['options'] is List) {
              
              final apiOptions = apiResponseData['response']['options'] as List;
              if (apiOptions.isNotEmpty) {
                developer.log('CHATBOT: Extracted options from API response for option selection', name: 'ChatbotScreen');
                followUpOptions = _formatOptionsWithIcons(apiOptions);
                
                // Ensure there's a return option
                bool hasReturnOption = followUpOptions.any((opt) => 
                  opt.toLowerCase().contains('retour au menu') || 
                  opt.toLowerCase().contains('return to main'));
                  
                if (!hasReturnOption) {
                  followUpOptions.add('⬅️ Retour au menu principal');
                }
              } else {
                // Check for embedded options in the message text
                final embeddedOptions = _extractEmbeddedOptions(response);
                if (embeddedOptions.isNotEmpty) {
                  developer.log('CHATBOT: Found ${embeddedOptions.length} embedded options in the message', name: 'ChatbotScreen');
                  followUpOptions = embeddedOptions;
                } else {
                  followUpOptions = ['⬅️ Retour au menu principal'];
                }
              }
            } else {
              // Check for embedded options in the message text when no API options
              final embeddedOptions = _extractEmbeddedOptions(response);
              if (embeddedOptions.isNotEmpty) {
                developer.log('CHATBOT: Found ${embeddedOptions.length} embedded options in the message', name: 'ChatbotScreen');
                followUpOptions = embeddedOptions;
              } else {
                followUpOptions = ['⬅️ Retour au menu principal'];
              }
            }
        }
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: followUpMessage,
            isUser: false,
            timestamp: DateTime.now(),
            options: followUpOptions,
            showInput: true,
          ));
          _isLoading = false;
          _isTyping = false;
          _showInput = true;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        developer.log('CHATBOT: Error handling option selection: $e', name: 'ChatbotScreen');
        setState(() {
          _messages.add(ChatMessage(
            text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
            options: [
              '📄 Questions sur mes documents',
              '👔 Droit du travail',
              '👪 Droit de la famille',
              '🏥 Droit de la santé',
              '🏠 Droit du logement',
              '❓ Autre'
            ],
            showInput: true,
          ));
          _isLoading = false;
          _isTyping = false;
        });
        _scrollToBottom();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    developer.log('CHATBOT: Sending message: $message', name: 'ChatbotScreen');
    print('CHATBOT: Sending message: $message');

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      developer.log('CHATBOT: Calling AI service', name: 'ChatbotScreen');
      final response = await _aiService.getChatResponse(message);
      developer.log('CHATBOT: Received response: $response', name: 'ChatbotScreen');
      print('CHATBOT: Received response from AI service');
      
      // Get the original API response data to extract options
      final Map<String, dynamic>? apiResponseData = _aiService.getLastApiResponseData();
      developer.log('CHATBOT: API response data: $apiResponseData', name: 'ChatbotScreen');
      
      // Try to extract options from the response - first try the API response data
      List<String>? extractedOptions;
      
      if (apiResponseData != null && 
          apiResponseData.containsKey('response') &&
          apiResponseData['response'] is Map<String, dynamic>) {
        
        final responseObj = apiResponseData['response'] as Map<String, dynamic>;
        developer.log('CHATBOT: Response object: $responseObj', name: 'ChatbotScreen');
        
        if (responseObj.containsKey('options') && responseObj['options'] is List) {
          developer.log('CHATBOT: Found options in API response data', name: 'ChatbotScreen');
          final List<dynamic> apiOptions = responseObj['options'];
          
          // Log the raw options for debugging
          developer.log('CHATBOT: Raw API options count: ${apiOptions.length}', name: 'ChatbotScreen');
          for (var i = 0; i < apiOptions.length; i++) {
            developer.log('CHATBOT: Raw option $i: ${apiOptions[i]}', name: 'ChatbotScreen');
          }
          
          // Extract the API options with formatting
          extractedOptions = _formatOptionsWithIcons(apiOptions);
          
          // Always add a "Return to main menu" option if not already present
          bool hasReturnOption = extractedOptions.any((option) => 
            option.toLowerCase().contains('retour au menu') || 
            option.toLowerCase().contains('return to main'));
            
          if (!hasReturnOption) {
            extractedOptions.add('⬅️ Retour au menu principal');
          }
          
          developer.log('CHATBOT: Extracted ${extractedOptions.length} options from API response: $extractedOptions', name: 'ChatbotScreen');
        } else {
          developer.log('CHATBOT: No options field found in response object', name: 'ChatbotScreen');
        }
      } else {
        developer.log('CHATBOT: Invalid API response data structure for options extraction', name: 'ChatbotScreen');
      }
      
      // If no options extracted from API data, try to extract embedded options from the message text
      if (extractedOptions == null || extractedOptions.isEmpty) {
        // Look for embedded options like "1. {id: 1, text: "Option text"}" in the message
        final embeddedOptions = _extractEmbeddedOptions(response);
        if (embeddedOptions.isNotEmpty) {
          developer.log('CHATBOT: Found ${embeddedOptions.length} embedded options in message text', name: 'ChatbotScreen');
          extractedOptions = embeddedOptions;
        } else if (response.contains("OPTIONS:")) {
          // Try to extract options from the message text with OPTIONS: marker
          try {
            developer.log('CHATBOT: Found OPTIONS marker in response text', name: 'ChatbotScreen');
            final optionsSection = response.split("OPTIONS:")[1].trim();
            final optionLines = optionsSection.split("\n");
            extractedOptions = optionLines
                .map((line) => line.replaceAll(RegExp(r'^\s*-\s*'), '').trim())
                .where((option) => option.isNotEmpty)
                .toList();
            
            // Also add return option if not present
            bool hasReturnOption = extractedOptions.any((option) => 
              option.toLowerCase().contains('retour au menu') || 
              option.toLowerCase().contains('return to main'));
              
            if (!hasReturnOption) {
              extractedOptions.add('⬅️ Retour au menu principal');
            }
            
            developer.log('CHATBOT: Extracted ${extractedOptions.length} options from text: $extractedOptions', name: 'ChatbotScreen');
          } catch (e) {
            developer.log('CHATBOT: Error extracting options from text: $e', name: 'ChatbotScreen');
            print('CHATBOT: Error extracting options from text: $e');
            extractedOptions = null;
          }
        } else {
          developer.log('CHATBOT: No options markers found in response text', name: 'ChatbotScreen');
        }
      }
      
      // If still no options extracted, create fallback options
      if (extractedOptions == null || extractedOptions.isEmpty) {
        developer.log('CHATBOT: Using fallback options', name: 'ChatbotScreen');
        extractedOptions = [
          '📝 En savoir plus',
          '❓ Poser une autre question',
          '⬅️ Retour au menu principal',
        ];
      }
      
      if (mounted) {
        // Better cleaning of the message to remove OPTIONS, CONTEXT, and EXPECTING CHOICE sections
        String cleanedMessage = response;
        
        // Remove OPTIONS section
        if (response.contains("\n\nOPTIONS:")) {
          cleanedMessage = response.split("\n\nOPTIONS:")[0].trim();
          developer.log('CHATBOT: Removed OPTIONS section from message', name: 'ChatbotScreen');
        }
        
        // Remove CONTEXT section if present
        if (cleanedMessage.contains("\n\nCONTEXT:")) {
          cleanedMessage = cleanedMessage.split("\n\nCONTEXT:")[0].trim();
          developer.log('CHATBOT: Removed CONTEXT section from message', name: 'ChatbotScreen');
        }
        
        // Remove EXPECTING CHOICE section if present
        if (cleanedMessage.contains("\n\nEXPECTING CHOICE:")) {
          cleanedMessage = cleanedMessage.split("\n\nEXPECTING CHOICE:")[0].trim();
          developer.log('CHATBOT: Removed EXPECTING CHOICE section from message', name: 'ChatbotScreen');
        }
        
        developer.log('CHATBOT: Displaying cleaned message: $cleanedMessage', name: 'ChatbotScreen');
        developer.log('CHATBOT: With options: $extractedOptions', name: 'ChatbotScreen');
        
        // Ensure extractedOptions is not null before using it
        final List<String> finalOptions = extractedOptions ?? [
          '⬅️ Retour au menu principal'
        ];
        
        setState(() {
          _messages.add(ChatMessage(
            text: cleanedMessage,
            isUser: false,
            timestamp: DateTime.now(),
            options: finalOptions,
            showInput: true,
          ));
          _isLoading = false;
          _isTyping = false;
          
          // Debug information
          developer.log('CHATBOT: Added bot message with ${finalOptions.length} options', name: 'ChatbotScreen');
          print('CHATBOT: Added bot message with ${finalOptions.length} options');
          for (int i = 0; i < finalOptions.length; i++) {
            developer.log('CHATBOT: Option $i: ${finalOptions[i]}', name: 'ChatbotScreen');
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      developer.log('CHATBOT: Error in handleSendMessage: $e', name: 'ChatbotScreen');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
            options: [
              '📄 Questions sur mes documents',
              '👔 Droit du travail',
              '👪 Droit de la famille',
              '🏥 Droit de la santé',
              '🏠 Droit du logement',
              '❓ Autre'
            ],
            showInput: true,
          ));
          _isLoading = false;
          _isTyping = false;
        });
        _scrollToBottom();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Don't clear chat history when disposing the screen
    // _aiService.clearHistory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Debug log for messages and options
    developer.log('CHATBOT: Building UI with ${_messages.length} messages', name: 'ChatbotScreen');
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      developer.log('CHATBOT: Message $i: ${msg.isUser ? "USER" : "BOT"} - options: ${msg.options?.length ?? 0}', name: 'ChatbotScreen');
      if (msg.options != null && msg.options!.isNotEmpty) {
        developer.log('CHATBOT: Options for message $i: ${msg.options}', name: 'ChatbotScreen');
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: DesignSystem.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistant Juridique',
                        style: DesignSystem.headingMedium.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: isMobile ? 18 : 20,
                        ),
                      ),
                      if (_isTyping)
                        Text(
                          'En train d\'écrire...',
                          style: DesignSystem.bodySmall.copyWith(
                            color: DesignSystem.primaryGreen,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: DesignSystem.primaryGreen,
                  ),
                  onPressed: () => _showSettingsDialog(context),
                ),
              ],
            ),
          ),
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: 20,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChatBubble(
                      message: message,
                      showAvatar: index == 0 || _messages[index - 1].isUser != message.isUser,
                    ),
                    if (message.options != null && message.options!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Options:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Divider(color: DesignSystem.primaryGreen, height: 1),
                            const SizedBox(height: 12),
                            ...message.options!.map((option) {
                              final bool isReturnOption = option.toLowerCase().contains('retour');
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ElevatedButton(
                                  onPressed: () => _handleOptionSelected(option),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isReturnOption
                                        ? Colors.grey[200]
                                        : DesignSystem.primaryGreen,
                                    foregroundColor: isReturnOption
                                        ? Colors.black87
                                        : Colors.white,
                                    elevation: 1,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        DesignSystem.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'En train de répondre...',
                    style: DesignSystem.bodyMedium.copyWith(
                      color: DesignSystem.darkText,
                    ),
                  ),
                ],
              ),
            ),
          // Input Area (Always visible)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? DesignSystem.primaryGreen
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            style: TextStyle(color: DesignSystem.darkText),
                            decoration: InputDecoration(
                              hintText: 'Posez votre question juridique...',
                              hintStyle: TextStyle(color: DesignSystem.mediumText),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            enabled: !_isLoading,
                            onSubmitted: (_) => _handleSendMessage(),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        if (_messageController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.close, color: DesignSystem.mediumText),
                            onPressed: () {
                              _messageController.clear();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey : DesignSystem.primaryGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _handleSendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final TextEditingController ipController = TextEditingController(
      text: ApiConfig.baseUrl.replaceAll(RegExp(r'https?://'), '').split(':')[0],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Configuration du serveur',
          style: DesignSystem.headingMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adresse IP du serveur',
              style: DesignSystem.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                hintText: 'Ex: 192.168.1.14',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: DesignSystem.primaryGreen,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: DesignSystem.mediumText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = ipController.text.trim();
              if (newIp.isNotEmpty) {
                ApiConfig.updateBaseUrl(newIp);
                Navigator.pop(context);
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adresse IP mise à jour: $newIp'),
                    backgroundColor: DesignSystem.primaryGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primaryGreen,
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format options with icons when available
  List<String> _formatOptionsWithIcons(List<dynamic> apiOptions) {
    developer.log('CHATBOT: Formatting ${apiOptions.length} options with icons', name: 'ChatbotScreen');
    final formattedOptions = <String>[];
    
    for (int i = 0; i < apiOptions.length; i++) {
      try {
        final option = apiOptions[i];
        developer.log('CHATBOT: Processing option $i: $option', name: 'ChatbotScreen');
        
        if (option is Map<String, dynamic>) {
          // Extract text and handle null safety
          final text = option['text']?.toString();
          final icon = option['icon']?.toString();
          final id = option['id']?.toString();
          
          developer.log('CHATBOT: Option components - id: $id, text: $text, icon: $icon', name: 'ChatbotScreen');
          
          if (text != null && text.isNotEmpty) {
            String formattedOption;
            if (icon != null && icon.isNotEmpty) {
              formattedOption = '$icon $text';
            } else {
              formattedOption = text;
            }
            developer.log('CHATBOT: Added formatted option: $formattedOption', name: 'ChatbotScreen');
            formattedOptions.add(formattedOption);
          } else {
            // If text is missing, add the whole option as string for debugging
            developer.log('CHATBOT: Option missing text, using full object as string', name: 'ChatbotScreen');
            formattedOptions.add(option.toString());
          }
        } else if (option is String) {
          developer.log('CHATBOT: Adding string option directly: $option', name: 'ChatbotScreen');
          formattedOptions.add(option);
        } else {
          developer.log('CHATBOT: Unknown option type: ${option.runtimeType}, converting to string', name: 'ChatbotScreen');
          formattedOptions.add(option.toString());
        }
      } catch (e) {
        developer.log('CHATBOT: Error formatting option at index $i: $e', name: 'ChatbotScreen');
        print('Error formatting option: $e');
        // Don't add anything to formatted options if there was an error
      }
    }
    
    developer.log('CHATBOT: Final formatted options: $formattedOptions', name: 'ChatbotScreen');
    return formattedOptions;
  }

  // Add this helper method to extract embedded options from text
  List<String> _extractEmbeddedOptions(String messageText) {
    final List<String> extractedOptions = [];
    
    developer.log('CHATBOT: Attempting to extract embedded options from message', name: 'ChatbotScreen');
    
    try {
      // Try different patterns for embedded options
      
      // Look for patterns like: 1. {id: 1, text: "Option text", icon: "icon"} 
      // First pattern: text and icon without quotes
      RegExp optionPattern1 = RegExp(
        r'\d+\.\s*\{\s*id\s*:\s*\d+\s*,\s*text\s*:\s*"?([^",]+)"?\s*,\s*icon\s*:\s*"?([^",]+)"?',
        multiLine: true
      );
      
      // Second pattern: text and icon with quotes
      RegExp optionPattern2 = RegExp(
        r'-\s*\{\s*id\s*:\s*\d+\s*,\s*text\s*:\s*"([^"]+)"\s*,\s*icon\s*:\s*"([^"]+)"',
        multiLine: true
      );
      
      // Try first pattern
      var matches = optionPattern1.allMatches(messageText);
      developer.log('CHATBOT: Found ${matches.length} potential embedded options with pattern 1', name: 'ChatbotScreen');
      
      // Process matches from first pattern
      for (final match in matches) {
        if (match.groupCount >= 2) {
          final text = match.group(1)?.trim();
          final icon = match.group(2)?.trim();
          
          if (text != null && text.isNotEmpty) {
            if (icon != null && icon.isNotEmpty) {
              extractedOptions.add('$icon $text');
              developer.log('CHATBOT: Extracted embedded option: $icon $text', name: 'ChatbotScreen');
            } else {
              extractedOptions.add(text);
              developer.log('CHATBOT: Extracted embedded option (no icon): $text', name: 'ChatbotScreen');
            }
          }
        }
      }
      
      // If no matches found with first pattern, try second pattern
      if (extractedOptions.isEmpty) {
        matches = optionPattern2.allMatches(messageText);
        developer.log('CHATBOT: Found ${matches.length} potential embedded options with pattern 2', name: 'ChatbotScreen');
        
        for (final match in matches) {
          if (match.groupCount >= 2) {
            final text = match.group(1)?.trim();
            final icon = match.group(2)?.trim();
            
            if (text != null && text.isNotEmpty) {
              if (icon != null && icon.isNotEmpty) {
                extractedOptions.add('$icon $text');
                developer.log('CHATBOT: Extracted embedded option: $icon $text', name: 'ChatbotScreen');
              } else {
                extractedOptions.add(text);
                developer.log('CHATBOT: Extracted embedded option (no icon): $text', name: 'ChatbotScreen');
              }
            }
          }
        }
      }
      
      // If still no options found, look for the special OPTIONS: block format 
      if (extractedOptions.isEmpty && messageText.contains("OPTIONS:")) {
        developer.log('CHATBOT: Looking for options in OPTIONS block', name: 'ChatbotScreen');
        
        // Try to extract the options block
        final optionsMatch = RegExp(r'OPTIONS:\s*\n([\s\S]*?)(?:\n\s*\n|$)').firstMatch(messageText);
        if (optionsMatch != null && optionsMatch.groupCount >= 1) {
          final optionsBlock = optionsMatch.group(1);
          if (optionsBlock != null) {
            developer.log('CHATBOT: Found options block: $optionsBlock', name: 'ChatbotScreen');
            
            // Extract options with text and icon in quotes
            final optionRegex = RegExp(r'-\s*\{[^}]*text\s*:\s*"([^"]+)"[^}]*icon\s*:\s*"([^"]+)"[^}]*\}');
            final optionMatches = optionRegex.allMatches(optionsBlock);
            
            for (final match in optionMatches) {
              if (match.groupCount >= 2) {
                final text = match.group(1)?.trim();
                final icon = match.group(2)?.trim();
                
                if (text != null && text.isNotEmpty) {
                  if (icon != null && icon.isNotEmpty) {
                    extractedOptions.add('$icon $text');
                    developer.log('CHATBOT: Extracted option from OPTIONS block: $icon $text', name: 'ChatbotScreen');
                  } else {
                    extractedOptions.add(text);
                    developer.log('CHATBOT: Extracted option from OPTIONS block (no icon): $text', name: 'ChatbotScreen');
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log('CHATBOT: Error extracting embedded options: $e', name: 'ChatbotScreen');
    }
    
    // Always add a return option if we found any embedded options
    if (extractedOptions.isNotEmpty && !extractedOptions.any((option) => 
      option.toLowerCase().contains('retour au menu') || 
      option.toLowerCase().contains('return to main'))) {
      extractedOptions.add('⬅️ Retour au menu principal');
    }
    
    developer.log('CHATBOT: Extracted ${extractedOptions.length} embedded options: $extractedOptions', name: 'ChatbotScreen');
    return extractedOptions;
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const _ChatBubble({
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser && showAvatar) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: DesignSystem.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.balance,
                  color: DesignSystem.primaryGreen,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (message.isUser && showAvatar)
            const SizedBox(width: 52),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile
                    ? MediaQuery.of(context).size.width * 0.75
                    : MediaQuery.of(context).size.width * 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? DesignSystem.primaryGreen 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: message.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isUser)
                    SelectableText(
                      message.text,
                      style: DesignSystem.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: 15,
                        ),
                        h1: DesignSystem.headingLarge.copyWith(
                          color: DesignSystem.darkText,
                        ),
                        h2: DesignSystem.headingMedium.copyWith(
                          color: DesignSystem.darkText,
                        ),
                        h3: DesignSystem.headingSmall.copyWith(
                          color: DesignSystem.darkText,
                        ),
                        listBullet: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.darkText,
                        ),
                        code: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.darkText,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: DesignSystem.bodySmall.copyWith(
                          color: message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : DesignSystem.mediumText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser && showAvatar) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: DesignSystem.primaryGreen.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: DesignSystem.primaryGreen,
                size: 22,
              ),
            ),
          ],
          if (!message.isUser && showAvatar)
            const SizedBox(width: 52),
        ],
      ),
    );
  }
} 