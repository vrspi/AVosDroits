import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../widgets/auth/auth_text_field.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form keys for each step
  final List<GlobalKey<FormState>> _formKeys = List.generate(
    5,
    (index) => GlobalKey<FormState>(),
  );

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressDurationController = TextEditingController();
  final _sectorController = TextEditingController();
  final _contractTypeController = TextEditingController();
  final _incomeController = TextEditingController();

  // Dropdown values
  String? _familyStatus;
  int? _childrenCount;
  String? _housingType;
  String? _employmentStatus;
  bool? _isPoleEmploiRegistered;
  bool? _hasHealthIssues;
  bool? _isDisabled;
  bool? _isImmigrant;
  bool? _receivesAid;
  bool? _hasDebts;
  bool? _receivesHousingAid;
  bool? _hasRequestedFamilyAid;
  bool? _hasOtherIncome;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _nationalityController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _addressDurationController.dispose();
    _sectorController.dispose();
    _contractTypeController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      if (_formKeys[_currentStep].currentState?.validate() ?? false) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Submit questionnaire
      if (_formKeys[_currentStep].currentState?.validate() ?? false) {
        // TODO: Handle questionnaire submission
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
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
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: screenPadding,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Étape ${_currentStep + 1} sur $_totalSteps',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: DesignSystem.lightText.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignSystem.primaryGreen,
                  ),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Questionnaire Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Personal Information
                _buildPersonalInfoStep(screenPadding),
                // Step 2: Family Status
                _buildFamilyStatusStep(screenPadding),
                // Step 3: Housing
                _buildHousingStep(screenPadding),
                // Step 4: Employment
                _buildEmploymentStep(screenPadding),
                // Step 5: Social Benefits
                _buildSocialBenefitsStep(screenPadding),
              ],
            ),
          ),
          // Navigation Buttons
          Padding(
            padding: screenPadding,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
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
                        'Précédent',
                        style: DesignSystem.buttonLarge.copyWith(
                          color: DesignSystem.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
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
                      _currentStep == _totalSteps - 1 ? 'Terminer' : 'Suivant',
                      style: DesignSystem.buttonLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations Personnelles',
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: _nameController,
              label: 'Nom complet',
              hintText: 'Entrez votre nom complet',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _ageController,
              label: 'Âge',
              hintText: 'Entrez votre âge',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre âge';
                }
                if (int.tryParse(value) == null) {
                  return 'Veuillez entrer un âge valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _nationalityController,
              label: 'Nationalité',
              hintText: 'Entrez votre nationalité',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nationalité';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _birthDateController,
              label: 'Date de naissance',
              hintText: 'JJ/MM/AAAA',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre date de naissance';
                }
                // TODO: Add date validation
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyStatusStep(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Situation Familiale',
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _familyStatus,
              decoration: InputDecoration(
                labelText: 'Situation familiale',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              items: [
                'Célibataire',
                'Marié(e)',
                'Pacsé(e)',
                'Divorcé(e)',
                'Veuf/Veuve',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _familyStatus = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner votre situation familiale';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _childrenCount,
              decoration: InputDecoration(
                labelText: 'Nombre d\'enfants à charge',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              items: List.generate(10, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(index.toString()),
                );
              }),
              onChanged: (int? value) {
                setState(() {
                  _childrenCount = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner le nombre d\'enfants';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHousingStep(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logement',
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _housingType,
              decoration: InputDecoration(
                labelText: 'Type de logement',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              items: [
                'Propriétaire',
                'Locataire',
                'Hébergé',
                'Sans domicile fixe',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _housingType = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner votre type de logement';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _addressController,
              label: 'Adresse actuelle',
              hintText: 'Entrez votre adresse complète',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre adresse';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _addressDurationController,
              label: 'Durée d\'habitation',
              hintText: 'Depuis combien de temps habitez-vous à cette adresse?',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la durée';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentStep(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emploi',
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _employmentStatus,
              decoration: InputDecoration(
                labelText: 'Statut d\'emploi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              items: [
                'Employé(e)',
                'Indépendant(e)',
                'Sans emploi',
                'Étudiant(e)',
                'Retraité(e)',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _employmentStatus = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner votre statut d\'emploi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _sectorController,
              label: 'Secteur d\'activité',
              hintText: 'Dans quel secteur travaillez-vous?',
              validator: (value) {
                if (_employmentStatus == 'Employé(e)' ||
                    _employmentStatus == 'Indépendant(e)') {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre secteur d\'activité';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _contractTypeController,
              label: 'Type de contrat',
              hintText: 'Quel est votre type de contrat?',
              validator: (value) {
                if (_employmentStatus == 'Employé(e)') {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre type de contrat';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _incomeController,
              label: 'Revenu mensuel brut',
              hintText: 'Entrez votre revenu mensuel brut',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_employmentStatus == 'Employé(e)' ||
                    _employmentStatus == 'Indépendant(e)') {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre revenu';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Inscrit à Pôle Emploi',
                style: DesignSystem.bodyMedium,
              ),
              value: _isPoleEmploiRegistered ?? false,
              onChanged: (bool value) {
                setState(() {
                  _isPoleEmploiRegistered = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialBenefitsStep(EdgeInsets padding) {
    return SingleChildScrollView(
      padding: padding,
      child: Form(
        key: _formKeys[4],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Situation Sociale',
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                'Problèmes de santé nécessitant une assistance',
                style: DesignSystem.bodyMedium,
              ),
              value: _hasHealthIssues ?? false,
              onChanged: (bool value) {
                setState(() {
                  _hasHealthIssues = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'En situation de handicap',
                style: DesignSystem.bodyMedium,
              ),
              value: _isDisabled ?? false,
              onChanged: (bool value) {
                setState(() {
                  _isDisabled = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Statut d\'immigrant ou réfugié',
                style: DesignSystem.bodyMedium,
              ),
              value: _isImmigrant ?? false,
              onChanged: (bool value) {
                setState(() {
                  _isImmigrant = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Bénéficiaire d\'allocations ou aides sociales',
                style: DesignSystem.bodyMedium,
              ),
              value: _receivesAid ?? false,
              onChanged: (bool value) {
                setState(() {
                  _receivesAid = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Dettes ou crédits en cours',
                style: DesignSystem.bodyMedium,
              ),
              value: _hasDebts ?? false,
              onChanged: (bool value) {
                setState(() {
                  _hasDebts = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Bénéficiaire de l\'aide au logement (APL)',
                style: DesignSystem.bodyMedium,
              ),
              value: _receivesHousingAid ?? false,
              onChanged: (bool value) {
                setState(() {
                  _receivesHousingAid = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Demande d\'allocations familiales effectuée',
                style: DesignSystem.bodyMedium,
              ),
              value: _hasRequestedFamilyAid ?? false,
              onChanged: (bool value) {
                setState(() {
                  _hasRequestedFamilyAid = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Autres sources de revenus',
                style: DesignSystem.bodyMedium,
              ),
              value: _hasOtherIncome ?? false,
              onChanged: (bool value) {
                setState(() {
                  _hasOtherIncome = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
} 