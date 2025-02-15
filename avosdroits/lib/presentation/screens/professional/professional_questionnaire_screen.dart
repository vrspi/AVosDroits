import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/services/api_service.dart';

class ProfessionalQuestionnaireScreen extends StatefulWidget {
  const ProfessionalQuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalQuestionnaireScreen> createState() => _ProfessionalQuestionnaireScreenState();
}

class _ProfessionalQuestionnaireScreenState extends State<ProfessionalQuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectTypeController = TextEditingController();
  final _assistanceTypeController = TextEditingController();
  final _projectStageController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _projectTypeController.dispose();
    _assistanceTypeController.dispose();
    _projectStageController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to submit professional project questionnaire
      await Future.delayed(const Duration(seconds: 1)); // Simulated API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questionnaire soumis avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la soumission: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
      appBar: AppBar(
        title: const Text('Accompagnement Professionnel'),
        backgroundColor: DesignSystem.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accompagnement et Suivi pour les Projets Professionnels',
                        style: DesignSystem.headingMedium.copyWith(
                          color: DesignSystem.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nous offrons des informations sur les droits et les aides pour les projets professionnels, y compris des conseils pour la création d\'entreprise, les subventions disponibles, et les programmes d\'accompagnement. Fournit également un suivi personnalisé pour aider les utilisateurs à atteindre leurs objectifs professionnels.',
                        style: DesignSystem.bodyMedium.copyWith(
                          color: DesignSystem.mediumText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _projectTypeController,
                      decoration: InputDecoration(
                        labelText: 'Quel est votre type de projet professionnel ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez décrire votre projet';
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _assistanceTypeController,
                      decoration: InputDecoration(
                        labelText: 'Quelle assistance spécifique recherchez-vous ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez préciser l\'assistance souhaitée';
                        }
                        return null;
                      },
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _projectStageController,
                      decoration: InputDecoration(
                        labelText: 'À quel stade en êtes-vous dans votre projet ?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez indiquer le stade de votre projet';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _additionalInfoController,
                      decoration: InputDecoration(
                        labelText: 'Informations supplémentaires',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Soumettre',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 