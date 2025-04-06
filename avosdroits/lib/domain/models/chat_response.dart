class ChatOption {
  final String id;
  final String text;
  final String icon;
  final String description;

  ChatOption({
    required this.id,
    required this.text,
    required this.icon,
    required this.description,
  });

  factory ChatOption.fromJson(Map<String, dynamic> json) {
    return ChatOption(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'icon': icon,
    'description': description,
  };

  @override
  String toString() => 'ChatOption(id: $id, text: $text, icon: $icon, description: $description)';
}

class ChatResponse {
  final String message;
  final List<ChatOption> options;
  final String? context;
  final bool expectingChoice;

  ChatResponse({
    required this.message,
    required this.options,
    this.context,
    required this.expectingChoice,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      message: json['message'] as String,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ChatOption.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      context: json['context'] as String?,
      expectingChoice: json['expectingChoice'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'options': options.map((e) => e.toJson()).toList(),
    'context': context,
    'expectingChoice': expectingChoice,
  };

  @override
  String toString() => 'ChatResponse(message: $message, options: $options, context: $context, expectingChoice: $expectingChoice)';
} 