import 'package:flutter/material.dart';
import '../widgets/feature_card.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/theme/design_system.dart';
import 'auth/sign_in_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Scaffold(
      backgroundColor: DesignSystem.neutralGray,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'À Vos Droits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 20 : 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              // TODO: Implement language selection
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                color: DesignSystem.primaryGreen.withOpacity(0.03),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.primaryGreen,
                        DesignSystem.secondaryGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(DesignSystem.radiusExtraLarge),
                      bottomRight: Radius.circular(DesignSystem.radiusExtraLarge),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Hero Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: HeroPatternPainter(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          screenPadding.left,
                          isMobile ? 100 : 120,
                          screenPadding.right,
                          isMobile ? 48 : 64,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Bienvenue sur\nÀ Vos Droits',
                              style: DesignSystem.headingLarge.copyWith(
                                fontSize: isMobile ? 32 : 48,
                                color: Colors.white,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isMobile ? 20 : 24),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 600,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 20 : 32,
                                vertical: isMobile ? 16 : 24,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Votre assistant personnel pour comprendre et faire valoir vos droits',
                                style: DesignSystem.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: isMobile ? 18 : 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Features Grid
                Padding(
                  padding: screenPadding.copyWith(top: isMobile ? 24 : 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          'Nos Services',
                          style: DesignSystem.headingLarge.copyWith(
                            color: DesignSystem.darkText,
                            fontSize: isMobile ? 24 : 32,
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: ResponsiveHelper.getCrossAxisCount(context),
                        mainAxisSpacing: isMobile ? 16 : 24,
                        crossAxisSpacing: isMobile ? 16 : 24,
                        childAspectRatio: isMobile ? 1.1 : 0.85,
                        children: [
                          FeatureCard(
                            title: 'Questionnaire',
                            description: 'Découvrez vos droits en répondant à quelques questions simples',
                            icon: Icons.quiz_outlined,
                            onTap: () {
                              // TODO: Implement questionnaire
                            },
                          ),
                          FeatureCard(
                            title: 'Base de Droits',
                            description: 'Accédez à toutes les informations sur vos droits',
                            icon: Icons.menu_book_outlined,
                            onTap: () {
                              // TODO: Implement rights database
                            },
                          ),
                          FeatureCard(
                            title: 'Courriers',
                            description: 'Générez automatiquement vos courriers administratifs',
                            icon: Icons.description_outlined,
                            onTap: () {
                              // TODO: Implement letter generation
                            },
                          ),
                          FeatureCard(
                            title: 'Services',
                            description: 'Trouvez les structures adaptées près de chez vous',
                            icon: Icons.location_on_outlined,
                            onTap: () {
                              // TODO: Implement local services
                            },
                          ),
                          FeatureCard(
                            title: 'Consultations',
                            description: 'Réservez une consultation avec un expert juridique',
                            icon: Icons.chat_outlined,
                            onTap: () {
                              // TODO: Implement consultations
                            },
                          ),
                          FeatureCard(
                            title: 'Coffre-Fort',
                            description: 'Stockez et organisez vos documents importants',
                            icon: Icons.folder_outlined,
                            onTap: () {
                              // TODO: Implement digital safe
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 16 : 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red, Color(0xFFE53935)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Implement emergency help
            },
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emergency_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Aide urgente',
                    style: DesignSystem.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => false;
}

class HeroPatternPainter extends CustomPainter {
  final Color color;

  HeroPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    const size = 20.0;

    for (var i = -size; i < size * 2; i += spacing) {
      for (var j = -size; j < size * 2; j += spacing) {
        final path = Path()
          ..moveTo(i, j)
          ..lineTo(i + size, j + size)
          ..moveTo(i + size, j)
          ..lineTo(i, j + size);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(HeroPatternPainter oldDelegate) => false;
} 