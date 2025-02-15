import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/questionnaire/questionnaire_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/document/document_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'À Vos Droits',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/main': (context) => const MainScreen(),
        '/questionnaire': (context) => const QuestionnaireScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/documents': (context) => const DocumentScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
} 