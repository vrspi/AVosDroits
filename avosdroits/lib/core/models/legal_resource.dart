class LegalResource {
  final String title;
  final String type; // 'letter_template', 'form', 'guide', 'video', etc.
  final String description;
  final String category;
  final String? fileUrl;
  final String? thumbnailUrl;
  final List<String> languages;
  final DateTime lastUpdated;

  LegalResource({
    required this.title,
    required this.type,
    required this.description,
    required this.category,
    this.fileUrl,
    this.thumbnailUrl,
    required this.languages,
    required this.lastUpdated,
  });

  factory LegalResource.fromJson(Map<String, dynamic> json) {
    return LegalResource(
      title: json['title'],
      type: json['type'],
      description: json['description'],
      category: json['category'],
      fileUrl: json['fileUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      languages: List<String>.from(json['languages']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'description': description,
      'category': category,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'languages': languages,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
} 