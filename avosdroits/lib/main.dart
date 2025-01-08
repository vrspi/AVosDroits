import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'presentation/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const App(),
    ),
  );
}
