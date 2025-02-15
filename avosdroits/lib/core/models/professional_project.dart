class ProfessionalProject {
  final String title;
  final String description;
  final String category; // 'business_creation', 'training', 'career_change', etc.
  final List<String> requirements;
  final List<String> steps;
  final List<String> availableAids;
  final Map<String, String> usefulLinks;
  final DateTime lastUpdated;
  final List<String> supportPrograms;
  final Map<String, double> estimatedCosts;

  ProfessionalProject({
    required this.title,
    required this.description,
    required this.category,
    required this.requirements,
    required this.steps,
    required this.availableAids,
    required this.usefulLinks,
    required this.lastUpdated,
    required this.supportPrograms,
    required this.estimatedCosts,
  });

  factory ProfessionalProject.fromJson(Map<String, dynamic> json) {
    return ProfessionalProject(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      requirements: List<String>.from(json['requirements']),
      steps: List<String>.from(json['steps']),
      availableAids: List<String>.from(json['availableAids']),
      usefulLinks: Map<String, String>.from(json['usefulLinks']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      supportPrograms: List<String>.from(json['supportPrograms']),
      estimatedCosts: Map<String, double>.from(json['estimatedCosts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'requirements': requirements,
      'steps': steps,
      'availableAids': availableAids,
      'usefulLinks': usefulLinks,
      'lastUpdated': lastUpdated.toIso8601String(),
      'supportPrograms': supportPrograms,
      'estimatedCosts': estimatedCosts,
    };
  }
} 