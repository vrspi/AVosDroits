import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/social_auth_button.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
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
                    onPressed: () {
                      // TODO: Implement Google Sign In
                    },
                  ),
                  const SizedBox(height: 16),
                  SocialAuthButton(
                    icon: Icons.facebook,
                    label: 'Continuer avec Facebook',
                    onPressed: () {
                      // TODO: Implement Facebook Sign In
                    },
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Implement email sign in
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignSystem.radiusMedium,
                          ),
                        ),
                      ),
                      child: Text(
                        'Se connecter',
                        style: DesignSystem.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
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
                    onPressed: () {
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
    );
  }
} 