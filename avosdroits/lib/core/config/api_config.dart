class ApiConfig {
  static const String baseUrl = 'https://localhost:7076';

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String socialLogin = '/api/auth/social-login';
  static const String forgotPassword = '/api/auth/forgot-password';

  // Questionnaire endpoints
  static const String getQuestionnaire = '/api/questionnaire';
  static const String submitQuestionnaire = '/api/questionnaire/submit';
  static String updateQuestionnaire(String userId) => '/api/questionnaire/$userId';

  // User Profile endpoints
  static const String userProfile = '/api/user/profile';
} 