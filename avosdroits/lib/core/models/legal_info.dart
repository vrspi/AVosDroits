class LegalInfo {
  final String title;
  final String description;
  final String category;
  final List<String> keywords;
  final DateTime lastUpdated;
  final String? link;

  LegalInfo({
    required this.title,
    required this.description,
    required this.category,
    required this.keywords,
    required this.lastUpdated,
    this.link,
  });

  factory LegalInfo.fromJson(Map<String, dynamic> json) {
    return LegalInfo(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      keywords: List<String>.from(json['keywords']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'keywords': keywords,
      'lastUpdated': lastUpdated.toIso8601String(),
      'link': link,
    };
  }
} 