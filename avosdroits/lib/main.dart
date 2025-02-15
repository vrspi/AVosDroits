import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/api_service.dart';
import 'core/services/together_ai_service.dart';
import 'core/config/api_config.dart';
import 'presentation/app.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  
  // Initialize services in the correct order
  ApiService.initialize(authProvider);
  TogetherAIService.initialize(authProvider: authProvider);
  
  await ApiConfig.initializeBaseUrl();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const App(),
    ),
  );
}
