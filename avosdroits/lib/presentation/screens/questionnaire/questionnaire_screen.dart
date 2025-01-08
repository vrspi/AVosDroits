import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/questionnaire.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/auth_provider.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final ApiService _apiService;
  List<Section>? _sections;
  Map<String, String> _answers = {};
  String? _sessionId;
  bool _isLoading = true;
  String? _error;
  int _currentSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(authProvider: context.read<AuthProvider>());
    _verifyAuthAndLoadQuestionnaire();
  }

  Future<void> _verifyAuthAndLoadQuestionnaire() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Verify authentication first
      final isAuthenticated = await _apiService.verifyAuthentication();
      if (!isAuthenticated) {
        throw ApiException(
          message: 'Session expired. Please log in again.',
          statusCode: 401,
        );
      }

      await _loadQuestionnaire();
    } catch (e) {
      print('Error in questionnaire initialization: $e');
      setState(() {
        _error = e.toString();
      });
      
      // If authentication failed, redirect to login
      if (e is ApiException && e.statusCode == 401) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/sign-in');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadQuestionnaire() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiService.getQuestionnaireTemplate();
      print('Response data: $response');

      if (response['data'] == null) {
        throw Exception('No data received from the server');
      }

      final sectionsData = response['data']['sections'];
      if (sectionsData == null) {
        throw Exception('No sections found in the response');
      }

      final sections = (sectionsData as List)
          .map((s) => Section.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      setState(() {
        _sections = sections;
        _sessionId = DateTime.now().millisecondsSinceEpoch.toString(); // Temporary session ID
      });
    } catch (e) {
      print('Error loading questionnaire: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAnswer(String questionId, String answer) async {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  Future<void> _submitAnswers() async {
    try {
      // Submit all answers for the current section
      final currentSection = _sections![_currentSectionIndex];
      for (var question in currentSection.questions) {
        if (_answers.containsKey(question.id)) {
          await _apiService.createResponse(
            questionId: question.id,
            answer: _answers[question.id]!,
            sessionId: _sessionId!,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case 'select':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _answers[question.id],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              items: question.options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.value,
                  child: Text(option.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _saveAnswer(question.id, value);
                }
              },
            ),
          ],
        );
      
      case 'boolean':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Oui'),
                    value: 'true',
                    groupValue: _answers[question.id],
                    onChanged: (value) {
                      if (value != null) {
                        _saveAnswer(question.id, value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Non'),
                    value: 'false',
                    groupValue: _answers[question.id],
                    onChanged: (value) {
                      if (value != null) {
                        _saveAnswer(question.id, value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      
      case 'number':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _answers[question.id],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Votre réponse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              onChanged: (value) {
                _saveAnswer(question.id, value);
              },
            ),
          ],
        );

      case 'date':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _answers[question.id],
              decoration: InputDecoration(
                hintText: 'JJ/MM/AAAA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              onChanged: (value) {
                _saveAnswer(question.id, value);
              },
            ),
          ],
        );
      
      case 'text':
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: DesignSystem.headingMedium.copyWith(
                color: DesignSystem.darkText,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _answers[question.id],
              decoration: InputDecoration(
                hintText: 'Votre réponse',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                ),
              ),
              onChanged: (value) {
                _saveAnswer(question.id, value);
              },
            ),
          ],
        );
    }
  }

  void _nextSection() async {
    if (_currentSectionIndex < (_sections?.length ?? 0) - 1) {
      // Submit answers before moving to next section
      await _submitAnswers();
      setState(() {
        _currentSectionIndex++;
      });
    }
  }

  void _previousSection() async {
    if (_currentSectionIndex > 0) {
      // Submit answers before moving to previous section
      await _submitAnswers();
      setState(() {
        _currentSectionIndex--;
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
                onPressed: _loadQuestionnaire,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final currentSection = _sections![_currentSectionIndex];

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Questionnaire',
          style: DesignSystem.headingLarge.copyWith(
            color: DesignSystem.darkText,
            fontSize: isMobile ? 24 : 32,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: screenPadding,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Étape ${_currentSectionIndex + 1} sur ${_sections!.length}',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(((_currentSectionIndex + 1) / _sections!.length) * 100).round()}%',
                      style: DesignSystem.bodyMedium.copyWith(
                        color: DesignSystem.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentSectionIndex + 1) / _sections!.length,
                  backgroundColor: DesignSystem.lightText.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    DesignSystem.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentSection.title,
                    style: DesignSystem.headingLarge.copyWith(
                      color: DesignSystem.darkText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...currentSection.questions
                      .map((question) => Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: _buildQuestionWidget(question),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
          Padding(
            padding: screenPadding,
            child: Row(
              children: [
                if (_currentSectionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousSection,
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
                if (_currentSectionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentSectionIndex < _sections!.length - 1
                        ? _nextSection
                        : () async {
                            try {
                              // Submit answers for the final section
                              await _submitAnswers();
                              
                              // Show success message
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Questionnaire soumis avec succès'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                
                                // Navigate to home screen after a short delay
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/');
                                  }
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().contains('400')
                                          ? 'Veuillez répondre à toutes les questions'
                                          : 'Une erreur est survenue lors de la soumission',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
                      _currentSectionIndex < _sections!.length - 1
                          ? 'Suivant'
                          : 'Terminer',
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
} 