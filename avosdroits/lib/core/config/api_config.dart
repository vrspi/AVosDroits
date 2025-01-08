class ApiConfig {
  static const String baseUrl = 'https://localhost:7076/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String socialLogin = '/auth/social-login';
  static const String forgotPassword = '/auth/forgot-password';

  // User Profile endpoints
  static const String userProfile = '/user/profile';

  // Questionnaire endpoints
  static const String questionnaireTemplate = '/questionnaire/template';
  static const String questionnaireResponses = '/questionnaire/responses';
  static String questionnaireResponse(String responseId) => '/questionnaire/responses/$responseId';
  static const String myResponses = '/questionnaire/responses/my';
  static const String myQuestionnaire = '/questionnaire/my';

  // Chatbot endpoint
  static const String chatbot = '/Chatbot/message';
} 