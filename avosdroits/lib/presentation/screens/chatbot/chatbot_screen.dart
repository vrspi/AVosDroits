import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/services/together_ai_service.dart';
import '../../../core/providers/auth_provider.dart';

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
    _aiService = TogetherAIService(authProvider: context.read<AuthProvider>());
    _showWelcomeMessage();
  }

  void _showWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: 'Bonjour! Comment puis-je vous aider aujourd\'hui?',
        isUser: false,
        timestamp: DateTime.now(),
        options: [
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
    setState(() {
      // Add user's selection as a message
      _messages.add(ChatMessage(
        text: option,
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

      // Handle different options
      switch (option) {
        case 'Droit de la famille':
          followUpMessage = 'Certainement, je peux vous aider avec des informations sur le droit de la famille. '
              'Pouvez-vous préciser votre demande? Avez-vous besoin d\'informations sur le mariage, le divorce, la '
              'garde des enfants, l\'adoption ou autre chose?';
          followUpOptions = [
            'Le mariage',
            'Le divorce',
            'La garde des enfants',
            'L\'adoption',
            'Autre sujet',
            'Retour au menu principal'
          ];
          break;
        case 'Droit du travail':
          followUpMessage = 'Je peux vous aider avec vos questions sur le droit du travail. '
              'Quel aspect du droit du travail vous intéresse?';
          followUpOptions = [
            'Contrat de travail',
            'Licenciement',
            'Congés',
            'Salaire',
            'Harcèlement',
            'Retour au menu principal'
          ];
          break;
        case 'Droit de la santé':
          followUpMessage = 'Je peux vous aider avec vos questions sur le droit de la santé. '
              'Quel aspect vous intéresse?';
          followUpOptions = [
            'Droits des patients',
            'Responsabilité médicale',
            'Assurance maladie',
            'Accident médical',
            'Autre sujet',
            'Retour au menu principal'
          ];
          break;
        case 'Droit du logement':
          followUpMessage = 'Je peux vous aider avec vos questions sur le droit du logement. '
              'Quel aspect vous intéresse?';
          followUpOptions = [
            'Location',
            'Achat immobilier',
            'Copropriété',
            'Expulsion',
            'Autre sujet',
            'Retour au menu principal'
          ];
          break;
        case 'Retour au menu principal':
          followUpMessage = 'Bien sûr, comment puis-je vous aider?';
          followUpOptions = [
            'Droit du travail',
            'Droit de la famille',
            'Droit de la santé',
            'Droit du logement',
            'Autre'
          ];
          break;
        default:
          // Handle specific topics
          followUpMessage = 'Je vous écoute. Quelle est votre question concernant $option?';
          followUpOptions = ['Retour au menu principal'];
          
          // If it's a specific topic, also get AI response
          final response = await _aiService.getChatResponse(option);
          followUpMessage = '$followUpMessage\n\n$response';
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: followUpMessage,
            isUser: false,
            timestamp: DateTime.now(),
            options: followUpOptions,
            showInput: true, // Always show input
          ));
          _isLoading = false;
          _isTyping = false;
          _showInput = true; // Always show input
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
            options: [
              'Droit du travail',
              'Droit de la famille',
              'Droit de la santé',
              'Droit du logement',
              'Autre'
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
      final response = await _aiService.getChatResponse(message);
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
            showInput: true,
          ));
          _isLoading = false;
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
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
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

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
                    if (message.options != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: message.options!.map((option) {
                          return ElevatedButton(
                            onPressed: () => _handleOptionSelected(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: option == 'Retour au menu principal'
                                  ? Colors.grey[300]
                                  : DesignSystem.primaryGreen,
                              foregroundColor: option == 'Retour au menu principal'
                                  ? DesignSystem.darkText
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DesignSystem.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.balance,
                color: DesignSystem.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (message.isUser && showAvatar)
            const SizedBox(width: 48),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile
                    ? MediaQuery.of(context).size.width * 0.75
                    : MediaQuery.of(context).size.width * 0.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? DesignSystem.primaryGreen 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isUser)
                    Text(
                      message.text,
                      style: DesignSystem.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.darkText,
                        ),
                        h1: DesignSystem.headingLarge.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: 20,
                        ),
                        h2: DesignSystem.headingMedium.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: 18,
                        ),
                        h3: DesignSystem.headingSmall.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: 16,
                        ),
                        listBullet: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.darkText,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: DesignSystem.bodySmall.copyWith(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : DesignSystem.mediumText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser && showAvatar) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: DesignSystem.primaryGreen.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: DesignSystem.primaryGreen,
                size: 20,
              ),
            ),
          ],
          if (!message.isUser && showAvatar)
            const SizedBox(width: 48),
        ],
      ),
    );
  }
} 