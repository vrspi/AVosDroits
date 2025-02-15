import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import 'auth/sign_in_screen.dart';
import 'main/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthProvider _authProvider;
  late ApiService _apiService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _apiService = ApiService.instance;
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = await _apiService.verifyAuthentication();
      
      if (isAuthenticated) {
        authProvider.setAuthenticationStatus(true);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        authProvider.setAuthenticationStatus(false);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/sign-in');
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      _authProvider.setAuthenticationStatus(false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sign-in');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 