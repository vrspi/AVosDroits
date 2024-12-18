import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_auth_button.dart';
import '../questionnaire/questionnaire_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        // Store token
        _apiService.setToken(response['data']['accessToken']);

        // Navigate to questionnaire screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const QuestionnaireScreen(),
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

      // Store token
      _apiService.setToken(response['data']['accessToken']);

      // Navigate to questionnaire screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const QuestionnaireScreen(),
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
                        'Créer un compte',
                        style: DesignSystem.headingLarge.copyWith(
                          color: DesignSystem.darkText,
                          fontSize: isMobile ? 32 : 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Rejoignez À Vos Droits',
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
                  // Sign Up Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          hintText: 'Entrez votre nom complet',
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                          hintText: 'Créez votre mot de passe',
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
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmer le mot de passe',
                          hintText: 'Confirmez votre mot de passe',
                          obscureText: !_isConfirmPasswordVisible,
                          enabled: !_isLoading,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: DesignSystem.mediumText,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Terms and Conditions
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _acceptTerms = value ?? false;
                                      });
                                    },
                              activeColor: DesignSystem.primaryGreen,
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: "J'accepte les ",
                                  style: DesignSystem.bodySmall.copyWith(
                                    color: DesignSystem.mediumText,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'conditions d\'utilisation',
                                      style: DesignSystem.bodySmall.copyWith(
                                        color: DesignSystem.primaryGreen,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const TextSpan(text: ' et la '),
                                    TextSpan(
                                      text: 'politique de confidentialité',
                                      style: DesignSystem.bodySmall.copyWith(
                                        color: DesignSystem.primaryGreen,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Button
                        ElevatedButton(
                          onPressed: (!_acceptTerms || _isLoading)
                              ? null
                              : _handleRegister,
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
                                  'Créer un compte',
                                  style: DesignSystem.buttonLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.mediumText,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          'Se connecter',
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