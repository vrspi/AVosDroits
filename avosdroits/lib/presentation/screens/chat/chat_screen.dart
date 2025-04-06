import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import '../../../data/services/chat_service.dart';
import '../../../domain/models/chat_response.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isRetrying = false;
  final ChatService _chatService = ChatService(baseUrl: Constants.apiUrl);
  String? _lastError;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/sign-in');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Add a dedicated method for rendering the options
  Widget _buildOptionsWidget(List<dynamic> options) {
    // Log to console for better web debugging
    developer.log('CONSOLE_DEBUG: Building options widget for ${options.length} options', name: 'ChatScreen');
    print('Building options widget for ${options.length} options');
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
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
          const Divider(color: Colors.green, height: 1),
          const SizedBox(height: 8),
          ...options.map<Widget>((optionData) {
            final String optionText = optionData['text']?.toString() ?? 'Option';
            final String optionIcon = optionData['icon']?.toString() ?? '';
            final bool isReturnOption = optionText.toLowerCase().contains('retour');
            
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  print('Option selected: $optionText');
                  developer.log('CONSOLE_DEBUG: Option selected: $optionText', name: 'ChatScreen');
                  _messageController.text = optionText;
                  _handleSendMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReturnOption ? Colors.grey[200] : const Color(0xFF4CAF50),
                  foregroundColor: isReturnOption ? Colors.black87 : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  alignment: Alignment.centerLeft,
                  elevation: 1,
                ),
                child: Row(
                  children: [
                    if (optionIcon.isNotEmpty) ...[
                      Text(
                        optionIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        optionText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (!_isRetrying && !error.contains('Session expirée'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _retryLastMessage();
              },
              child: const Text('Réessayer'),
            ),
          if (error.contains('Session expirée'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/sign-in');
              },
              child: const Text('Se reconnecter'),
            ),
        ],
      ),
    );
  }

  Future<void> _retryLastMessage() async {
    if (_messages.isEmpty) return;

    final lastUserMessage = _messages.lastWhere(
      (m) => m['isUser'] == true,
      orElse: () => {'content': ''},
    );

    if (lastUserMessage['content'].isEmpty) return;

    setState(() => _isRetrying = true);
    try {
      await _handleSendMessage();
    } finally {
      setState(() => _isRetrying = false);
    }
  }

  // Add a method to show options in a dialog
  void _showOptionsDialog(List<dynamic> options) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Options disponibles:'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map<Widget>((option) {
                final String text = option['text']?.toString() ?? 'Option';
                final String icon = option['icon']?.toString() ?? '';
                
                return ListTile(
                  leading: Text(icon, style: const TextStyle(fontSize: 20)),
                  title: Text(text),
                  onTap: () {
                    Navigator.of(context).pop();
                    _messageController.text = text;
                    _handleSendMessage();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    print('=== STARTING NEW MESSAGE SEND ===');
    print('Sending message: $message');
    print('Current message history: $_messages');

    setState(() {
      _messages.add({
        'isUser': true,
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isLoading = true;
      _isTyping = true;
    });

    print('Added user message to history. New length: ${_messages.length}');
    _messageController.clear();
    _scrollToBottom();

    try {
      final history = _messages.where((m) => m['content'] != null).map((m) => {
        'role': m['isUser'] ? 'user' : 'assistant',
        'content': m['content'] as String,
      }).toList();

      print('Formatted history for API: $history');

      if (_messages.length == 1) {
        history.insert(0, {
          'role': 'system',
          'content': 'Vous êtes un assistant juridique spécialisé dans le droit français. '
              'Votre rôle est d\'aider les utilisateurs à comprendre leurs droits et les procédures juridiques. '
              'Vos réponses doivent être structurées avec des options claires et des émojis pertinents.',
        });
      }

      final response = await _chatService.sendMessage(message, history);
      print('Received ChatResponse: $response');
      print('Response message: ${response.message}');
      print('Response options: ${response.options}');
      
      developer.log('CONSOLE_DEBUG: Received API response:', name: 'ChatScreen');
      developer.log('CONSOLE_DEBUG: Response message: ${response.message}', name: 'ChatScreen');
      for (int i = 0; i < response.options.length; i++) {
        developer.log('CONSOLE_DEBUG: Response option $i: ${response.options[i].toJson()}', name: 'ChatScreen');
      }
      
      if (mounted) {
        try {
          // Get options directly from the response data as raw maps
          final optionsData = response.options.map((opt) => {
            'id': opt.id,
            'text': opt.text,
            'icon': opt.icon,
            'description': opt.description,
          }).toList();
          
          print('Raw options data for message: $optionsData');
          
          final messageData = {
            'isUser': false,
            'content': response.message,
            'options': optionsData,
            'expectingChoice': response.expectingChoice,
            'timestamp': DateTime.now().toIso8601String(),
          };
          
          // If we have options, show them in a dialog immediately
          if (optionsData.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // REMOVE THIS: Don't show dialog automatically
                // _showOptionsDialog(optionsData);
                
                // Instead, log that options were found
                print('Found ${optionsData.length} options - will display inline');
                developer.log('CONSOLE_DEBUG: Found ${optionsData.length} options - will display inline', name: 'ChatScreen');
              }
            });
          }
          
          print('=== ADDING BOT RESPONSE TO MESSAGES ===');
          print('Adding message data to list: $messageData');
          print('Options in message data: ${messageData['options'].length}');
          print('First option: ${messageData['options'].isNotEmpty ? messageData['options'][0] : "No options"}');
          print('Message data options type: ${messageData['options'].runtimeType}');
          
          setState(() {
            print('Inside setState before adding bot message, current length: ${_messages.length}');
            _messages.add(messageData);
            print('Inside setState after adding bot message, new length: ${_messages.length}');
            _isLoading = false;
            _isTyping = false;
          });
          print('After setState, message list length: ${_messages.length}');
          _scrollToBottom();
        } catch (e) {
          print('Error creating message data: $e');
          // Add message without options as fallback
          setState(() {
            _messages.add({
              'isUser': false,
              'content': response.message,
              'timestamp': DateTime.now().toIso8601String(),
            });
            _isLoading = false;
            _isTyping = false;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('Error in _handleSendMessage: $e');
      String errorMessage;
      if (e.toString().contains('401')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Le service est temporairement indisponible. Veuillez réessayer dans quelques instants.';
      } else {
        errorMessage = 'Une erreur est survenue: ${e.toString()}';
      }

      if (mounted) {
        setState(() => _lastError = errorMessage);
        _showErrorDialog(errorMessage);

        // Remove the user's message if there was an error
        setState(() {
          _messages.removeLast();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isTyping = false;
        });
        _messageController.clear();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Before the build method, add a debug method to test option display
  void _testOptionsDisplay() {
    print('Testing options display...');
    developer.log('CONSOLE_DEBUG: Testing options display...', name: 'ChatScreen');
    
    final testOptions = [
      {
        'id': 'test1',
        'text': 'Test Option 1',
        'icon': '📚',
        'description': 'This is a test option'
      },
      {
        'id': 'test2',
        'text': 'Test Option 2',
        'icon': '🔍',
        'description': 'This is another test option'
      }
    ];
    
    // Find the last non-user message and add options to it
    Map<String, dynamic>? lastBotMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i]['isUser'] == false) {
        lastBotMessage = _messages[i];
        break;
      }
    }
    
    if (lastBotMessage != null) {
      // Add options to the last bot message
      setState(() {
        lastBotMessage['options'] = testOptions;
      });
      
      print('Added test options to last bot message');
      developer.log('CONSOLE_DEBUG: Added test options to last bot message', name: 'ChatScreen');
    } else {
      // Add a test message with options if no bot message exists
      setState(() {
        _messages.add({
          'isUser': false,
          'content': 'This is a test message with options.',
          'options': testOptions,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      
      print('Added new test message with options');
      developer.log('CONSOLE_DEBUG: Added new test message with options', name: 'ChatScreen');
    }
    
    // Force scroll to bottom after adding options
    _scrollToBottom();
  }
  
  // Add a method to directly display options
  void _displayBotOptions(BuildContext context) {
    // Find the last bot message with options
    Map<String, dynamic>? messageWithOptions;
    
    for (int i = _messages.length - 1; i >= 0; i--) {
      final msg = _messages[i];
      if (msg['isUser'] == false && 
          msg.containsKey('options') && 
          msg['options'] != null && 
          (msg['options'] as List).isNotEmpty) {
        messageWithOptions = msg;
        break;
      }
    }
    
    if (messageWithOptions != null) {
      List<dynamic> options = messageWithOptions['options'] as List<dynamic>;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Options disponibles:'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${options.length} options trouvées:'),
                const SizedBox(height: 16),
                // Display options directly using _buildOptionsWidget
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 400,
                  ),
                  child: _buildOptionsWidget(options),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune option disponible dans les messages récents'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildOptionItem(String text, String icon, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            print('Test option selected: $text');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.green[700],
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add a method to force add options to the most recent bot message
  void _forceAddOptionsToLastBotMessage() {
    print('Forcing options to last bot message...');
    developer.log('CONSOLE_DEBUG: Forcing options to last bot message...', name: 'ChatScreen');
    
    // Hard coded test options that should definitely work
    final List<Map<String, dynamic>> testOptions = [
      {
        'id': '1', 
        'text': 'Congés payés', 
        'icon': '🏖️', 
        'description': 'Informations sur les congés payés annuels'
      },
      {
        'id': '2', 
        'text': 'Congés maternité', 
        'icon': '👶', 
        'description': 'Informations sur les congés liés à la naissance'
      },
      {
        'id': '3', 
        'text': 'Congés maladie', 
        'icon': '🤒', 
        'description': 'Informations sur les arrêts maladie'
      },
      {
        'id': '4', 
        'text': 'Retour au menu principal', 
        'icon': '⬅️', 
        'description': 'Revenir au menu principal'
      },
    ];
    
    // Find the last bot message
    Map<String, dynamic>? lastBotMessage;
    int lastBotMessageIndex = -1;
    
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i]['isUser'] == false) {
        lastBotMessage = _messages[i];
        lastBotMessageIndex = i;
        break;
      }
    }
    
    if (lastBotMessage != null) {
      print('Found last bot message: ${lastBotMessage['content']}');
      
      // Create a completely new message with the same content plus options
      if (lastBotMessageIndex >= 0) {
        final originalContent = lastBotMessage['content'];
        
        setState(() {
          // First remove the old message
          _messages.removeAt(lastBotMessageIndex);
          
          // Then add a new one with options
          _messages.insert(lastBotMessageIndex, {
            'isUser': false,
            'content': originalContent,
            'options': testOptions,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        
        print('Replaced bot message with new one containing options');
        developer.log('CONSOLE_DEBUG: Replaced bot message with forced options', name: 'ChatScreen');
      }
    } else {
      // If no bot message, create one
      setState(() {
        _messages.add({
          'isUser': false,
          'content': 'Voici des options concernant les congés:',
          'options': testOptions,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      print('Created new bot message with forced options');
    }
    
    // Force rebuild and scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {}); // Force rebuild
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('CONSOLE_DEBUG: === BUILDING CHAT SCREEN ===', name: 'ChatScreen');
    print('=== BUILDING CHAT SCREEN ===');
    print('Message list length in build: ${_messages.length}');
    
    // Examine all messages and options
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      print('Message $i: isUser=${msg['isUser']}, hasOptions=${msg.containsKey('options')}');
      if (msg.containsKey('options') && msg['options'] != null) {
        print('  Options for message $i: ${msg['options']}');
        print('  Options type: ${msg['options'].runtimeType}');
        print('  Options count: ${msg['options'].length}');
      }
    }
    
    // Build debug info string
    String debugInfo = 'Messages: ${_messages.length}\n';
    int optionsCount = 0;
    for (var msg in _messages) {
      if (!msg['isUser'] && msg.containsKey('options') && msg['options'] != null) {
        optionsCount += (msg['options'] as List).length;
        debugInfo += 'Bot message with ${(msg['options'] as List).length} options\n';
      }
    }
    debugInfo += 'Total options: $optionsCount';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Juridique'),
        centerTitle: true,
      ),
      // Add debug overlay
      floatingActionButton: kIsWeb ? FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Debug Info'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(debugInfo),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Force rebuild
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Force Rebuild'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _testOptionsDisplay();
                      Navigator.pop(context);
                    },
                    child: const Text('Test Options Display'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.info_outline),
      ) : null,
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          print('Building StatefulBuilder with ${_messages.length} messages');
          return Column(
            children: [
              if (_lastError != null)
                Container(
                  color: Colors.red[100],
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lastError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => this.setState(() => _lastError = null),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              // Add a direct way to view options at the top of the page
              if (_messages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Voir les options'),
                        onPressed: () => _displayBotOptions(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // EMERGENCY TEST BUTTON - Directly inserts options into UI
                      ElevatedButton.icon(
                        icon: const Icon(Icons.bug_report),
                        label: const Text('TEST OPTIONS NOW'),
                        onPressed: () {
                          // Directly add to UI without any database or state changes
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Test Options'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('These are hardcoded test options:'),
                                      const SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.touch_app, color: Colors.green[700]),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Options disponibles (3)',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.green[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(color: Colors.green),
                                            const SizedBox(height: 8),
                                            _buildOptionItem('Option 1', '📋', 'This is option 1'),
                                            _buildOptionItem('Option 2', '📝', 'This is option 2'),
                                            _buildOptionItem('Option 3', '📌', 'This is option 3'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // FORCE ADD options to last bot message
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle),
                        label: const Text('FORCE ADD'),
                        onPressed: _forceAddOptionsToLastBotMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  key: ValueKey<int>(_messages.length),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + 1, // +1 for the options access widget
                  itemBuilder: (context, index) {
                    // Special widget at index 0 for quick access to all options
                    if (index == 0) {
                      // Build list of all options from all messages
                      final allOptions = <Map<String, dynamic>>[];
                      for (final msg in _messages) {
                        if (!msg['isUser'] && msg.containsKey('options') && 
                            msg['options'] != null && (msg['options'] as List).isNotEmpty) {
                          allOptions.addAll(msg['options'] as List<dynamic>);
                        }
                      }
                      
                      // If no options, just return a small spacer
                      if (allOptions.isEmpty) {
                        return const SizedBox(height: 4);
                      }
                      
                      // Return a widget to show all available options
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, color: Colors.amber),
                                  SizedBox(width: 8),
                                  Text(
                                    "Options disponibles:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Simple list of option buttons
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: allOptions.map<Widget>((option) {
                                  final text = option['text']?.toString() ?? 'Option';
                                  
                                  return ActionChip(
                                    label: Text(text),
                                    backgroundColor: Colors.lightGreen.shade50,
                                    onPressed: () {
                                      _messageController.text = text;
                                      _handleSendMessage();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Regular message display
                    final message = _messages[index - 1]; // -1 because we added a widget at index 0
                    print('=== RENDERING MESSAGE AT INDEX ${index - 1} ===');
                    print('Message content: ${message['content']}');
                    print('Is user message: ${message['isUser']}');
                    print('Has options: ${message.containsKey('options')}');
                    if (message.containsKey('options')) {
                      print('Options length: ${message['options']?.length}');
                      print('Options data: ${message['options']}');
                    }
                    
                    final isUser = message['isUser'] as bool;
    
                    return Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: isUser 
                                ? null 
                                : Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['content'] as String,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              
                              // Add refresh options button for bot messages
                              if (!isUser && (!message.containsKey('options') || 
                                  message['options'] == null || 
                                  (message['options'] as List).isEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Afficher les options'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    onPressed: () async {
                                      // Create demo options if none exist
                                      developer.log('CONSOLE_DEBUG: Creating demo options for refresh', name: 'ChatScreen');
                                      
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const AlertDialog(
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 16),
                                              Text('Récupération des options...'),
                                            ],
                                          ),
                                        ),
                                      );
                                      
                                      try {
                                        // Get the last user message
                                        final lastUserMessage = _messages.lastWhere(
                                          (m) => m['isUser'] == true,
                                          orElse: () => {'content': ''},
                                        );
                                        
                                        if (lastUserMessage['content'].isNotEmpty) {
                                          final history = _messages.where((m) => m['content'] != null).map((m) => {
                                            'role': m['isUser'] ? 'user' : 'assistant',
                                            'content': m['content'] as String,
                                          }).toList();
                                          
                                          // Add system message if needed
                                          if (_messages.length == 1) {
                                            history.insert(0, {
                                              'role': 'system',
                                              'content': 'Vous êtes un assistant juridique spécialisé dans le droit français. '
                                                  'Votre rôle est d\'aider les utilisateurs à comprendre leurs droits et les procédures juridiques. '
                                                  'Vos réponses doivent être structurées avec des options claires et des émojis pertinents.',
                                            });
                                          }
                                          
                                          // Fresh API call to get options
                                          final response = await _chatService.sendMessage(
                                            lastUserMessage['content'] as String, 
                                            history
                                          );
                                          
                                          // Update message with new options
                                          if (response.options.isNotEmpty) {
                                            final optionsData = response.options.map((opt) => {
                                              'id': opt.id,
                                              'text': opt.text,
                                              'icon': opt.icon,
                                              'description': opt.description,
                                            }).toList();
                                            
                                            setState(() {
                                              message['options'] = optionsData;
                                            });
                                            
                                            developer.log('CONSOLE_DEBUG: Updated options: $optionsData', name: 'ChatScreen');
                                          } else {
                                            // Create some fallback options if none were returned
                                            setState(() {
                                              message['options'] = [
                                                {
                                                  'id': '1',
                                                  'text': 'En savoir plus',
                                                  'icon': '📚',
                                                  'description': 'Obtenir plus d\'informations sur ce sujet',
                                                },
                                                {
                                                  'id': '2',
                                                  'text': 'Poser une autre question',
                                                  'icon': '❓',
                                                  'description': 'Reformuler votre question ou poser une question différente',
                                                },
                                              ];
                                            });
                                          }
                                        }
                                      } catch (e) {
                                        print('Error refreshing options: $e');
                                        // Create some fallback options
                                        setState(() {
                                          message['options'] = [
                                            {
                                              'id': '1',
                                              'text': 'En savoir plus',
                                              'icon': '📚',
                                              'description': 'Obtenir plus d\'informations sur ce sujet',
                                            },
                                            {
                                              'id': '2',
                                              'text': 'Poser une autre question',
                                              'icon': '❓',
                                              'description': 'Reformuler votre question ou poser une question différente',
                                            },
                                          ];
                                        });
                                      } finally {
                                        Navigator.of(context).pop(); // Close loading dialog
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isUser && message.containsKey('options') && message['options'] != null && (message['options'] as List).isNotEmpty) ...[
                          // PROMINENT OPTIONS DISPLAY - Always visible
                          Builder(
                            builder: (context) {
                              final options = message['options'] as List<dynamic>;
                              print('DISPLAYING OPTIONS: ${options.length} options found');
                              developer.log('CONSOLE_DEBUG: DISPLAYING OPTIONS: ${options.length} options found', name: 'ChatScreen');
                              
                              // Test option print
                              for (var opt in options) {
                                print('Option text: ${opt['text']}');
                                developer.log('CONSOLE_DEBUG: Option to display: ${opt['text']}', name: 'ChatScreen');
                              }
                              
                              // Directly call _buildOptionsWidget here instead of using a custom container
                              return _buildOptionsWidget(options);
                            }
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (kIsWeb && _messages.isNotEmpty) 
                      IconButton(
                        icon: const Icon(Icons.bug_report, color: Colors.red),
                        onPressed: () {
                          developer.log('CONSOLE_DEBUG: Test options button clicked', name: 'ChatScreen');
                          // Create test options directly in UI
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Test Options'),
                              content: Container(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Test option buttons:'),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Test Button 1'),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Test Button 2'),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Posez votre question...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _handleSendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _handleSendMessage(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
} 