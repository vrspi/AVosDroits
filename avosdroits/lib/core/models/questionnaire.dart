class Section {
  final String id;
  final String title;
  final int order;
  final List<Question> questions;

  Section({
    required this.id,
    required this.title,
    required this.order,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String sectionId;
  final String question;
  final String type;
  final bool required;
  final String? validationRules;
  final int order;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.sectionId,
    required this.question,
    required this.type,
    required this.required,
    this.validationRules,
    required this.order,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    try {
      return Question(
        id: json['id']?.toString() ?? '',
        sectionId: json['sectionId']?.toString() ?? '',
        question: json['question']?.toString() ?? '',
        type: json['type']?.toString() ?? 'text',
        required: json['required'] as bool? ?? true,
        validationRules: json['validationRules']?.toString(),
        order: json['order'] as int? ?? 0,
        options: json['options'] != null
            ? (json['options'] as List)
                .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
                .toList()
            : [],
      );
    } catch (e) {
      print('Error parsing question: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class QuestionOption {
  final int id;
  final String value;
  final String label;
  final int order;

  QuestionOption({
    required this.id,
    required this.value,
    required this.label,
    required this.order,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as int? ?? 0,
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class QuestionResponse {
  final String id;
  final String questionId;
  final String answer;
  final String sessionId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  QuestionResponse({
    required this.id,
    required this.questionId,
    required this.answer,
    required this.sessionId,
    required this.createdAt,
    this.updatedAt,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
      sessionId: json['sessionId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    );
  }
}

class QuestionnaireSession {
  final String sessionId;
  final List<QuestionResponse> responses;
  final DateTime createdAt;
  final bool isCompleted;

  QuestionnaireSession({
    required this.sessionId,
    required this.responses,
    required this.createdAt,
    required this.isCompleted,
  });

  factory QuestionnaireSession.fromJson(Map<String, dynamic> json) {
    return QuestionnaireSession(
      sessionId: json['sessionId'] as String,
      responses: (json['responses'] as List)
        .map((e) => QuestionResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool,
    );
  }
} 