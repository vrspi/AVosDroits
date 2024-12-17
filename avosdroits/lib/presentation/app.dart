import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import 'screens/home_screen.dart';

class AVosDroitsApp extends StatelessWidget {
  const AVosDroitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'À Vos Droits',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: AppTheme.lightTheme.colorScheme,
        cardTheme: AppTheme.lightTheme.cardTheme,
        appBarTheme: AppTheme.lightTheme.appBarTheme,
        elevatedButtonTheme: AppTheme.lightTheme.elevatedButtonTheme,
        scaffoldBackgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 