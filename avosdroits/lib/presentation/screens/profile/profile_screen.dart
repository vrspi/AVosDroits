import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/profile.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/auth_provider.dart';
import '../../widgets/auth/auth_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ApiService _apiService;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  Profile? _profile;
  bool _isLoading = true;
  bool _isEditing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService.instance;
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.getUserProfile();
      final profileData = response['data']['user'];
      
      setState(() {
        _profile = Profile.fromJson(profileData);
        _nameController.text = _profile!.name;
        _phoneController.text = _profile!.phone ?? '';
        _addressController.text = _profile!.address ?? '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
      );

      final updatedProfileData = response['data']['user'];
      setState(() {
        _profile = Profile.fromJson(updatedProfileData);
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Une erreur est survenue',
                style: DesignSystem.headingLarge.copyWith(
                  color: DesignSystem.darkText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: DesignSystem.bodyLarge.copyWith(
                  color: DesignSystem.mediumText,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mon Profil',
          style: DesignSystem.headingLarge.copyWith(
            color: DesignSystem.darkText,
            fontSize: isMobile ? 24 : 32,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              color: DesignSystem.primaryGreen,
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignSystem.primaryGreen.withOpacity(0.1),
                    DesignSystem.primaryGreen.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignSystem.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 48 : 56,
                      backgroundColor: Colors.white,
                      child: Text(
                        _profile!.name.substring(0, 1).toUpperCase(),
                        style: DesignSystem.headingLarge.copyWith(
                          color: DesignSystem.primaryGreen,
                          fontSize: isMobile ? 32 : 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Info Summary
                  Text(
                    _profile!.name,
                    style: DesignSystem.headingMedium.copyWith(
                      color: DesignSystem.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _profile!.email,
                    style: DesignSystem.bodyMedium.copyWith(
                      color: DesignSystem.mediumText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Membre depuis ${_profile!.createdAt.year}',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.lightText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Section Title
            if (!_isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Informations personnelles',
                  style: DesignSystem.headingMedium.copyWith(
                    color: DesignSystem.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Profile Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                boxShadow: [
                  if (!_isEditing)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: _nameController,
                      label: 'Nom complet',
                      hintText: 'Entrez votre nom complet',
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: TextEditingController(text: _profile!.email),
                      label: 'Email',
                      hintText: 'Votre email',
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Téléphone',
                      hintText: 'Entrez votre numéro de téléphone',
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _addressController,
                      label: 'Adresse',
                      hintText: 'Entrez votre adresse',
                      enabled: _isEditing,
                      maxLines: 3,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _nameController.text = _profile!.name;
                                  _phoneController.text = _profile!.phone ?? '';
                                  _addressController.text = _profile!.address ?? '';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: DesignSystem.primaryGreen,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    DesignSystem.radiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Annuler',
                                style: DesignSystem.buttonLarge.copyWith(
                                  color: DesignSystem.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.primaryGreen,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    DesignSystem.radiusMedium,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Enregistrer',
                                style: DesignSystem.buttonLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 