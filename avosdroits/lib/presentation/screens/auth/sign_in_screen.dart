import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_auth_button.dart';
import 'sign_up_screen.dart';
import '../menu/menu_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final ApiService _apiService;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(authProvider: context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _apiService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Navigate to home screen and remove all previous routes
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement social auth token retrieval
      const accessToken = 'social-auth-token';
      
      final response = await _apiService.socialLogin(
        provider: provider,
        accessToken: accessToken,
      );

      // Navigate to home screen and remove all previous routes
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.forgotPassword(
        email: _emailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un email de réinitialisation a été envoyé'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: DesignSystem.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isMobile ? 60 : 80),
                  // Logo and Title
                  Column(
                    children: [
                      Icon(
                        Icons.balance,
                        size: isMobile ? 64 : 80,
                        color: DesignSystem.primaryGreen,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Connexion',
                        style: DesignSystem.headingLarge.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: isMobile ? 32 : 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bienvenue sur À Vos Droits',
                        style: DesignSystem.bodyLarge.copyWith(
                          color: DesignSystem.mediumText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 40 : 48),
                  // Social Auth Buttons
                  Column(
                    children: [
                      SocialAuthButton(
                        icon: Icons.g_mobiledata,
                        label: 'Continuer avec Google',
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('google'),
                      ),
                      const SizedBox(height: 16),
                      SocialAuthButton(
                        icon: Icons.facebook,
                        label: 'Continuer avec Facebook',
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('facebook'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: DesignSystem.bodyMedium.copyWith(
                            color: DesignSystem.mediumText,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Email Sign In Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Entrez votre email',
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          hintText: 'Entrez votre mot de passe',
                          obscureText: !_isPasswordVisible,
                          enabled: !_isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: DesignSystem.mediumText,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Sign In Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignSystem.radiusMedium,
                              ),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Se connecter',
                                  style: DesignSystem.buttonLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Forgot Password
                        TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          child: Text(
                            'Mot de passe oublié ?',
                            style: DesignSystem.bodyMedium.copyWith(
                              color: DesignSystem.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.mediumText,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Créer un compte',
                          style: DesignSystem.bodyMedium.copyWith(
                            color: DesignSystem.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }
} 