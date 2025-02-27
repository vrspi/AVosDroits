import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../document/document_screen.dart' hide ResponsiveHelper;
import '../legal_info/legal_info_screen.dart';
import '../procedures/procedures_screen.dart';
import '../locations/locations_screen.dart';
import '../professional/professional_questionnaire_screen.dart';
import '../contacts/contacts_directory_screen.dart';
import '../alerts/alerts_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Bienvenue sur À Vos Droits',
              style: DesignSystem.headingLarge.copyWith(
                color: DesignSystem.darkText,
                fontSize: isMobile ? 24 : 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez une fonctionnalité :',
              style: DesignSystem.bodyLarge.copyWith(
                color: DesignSystem.mediumText,
              ),
            ),
            const SizedBox(height: 24),
            if (authProvider.isAuthenticated) ...[
              _buildMenuButton(
                context: context,
                icon: Icons.folder_special,
                text: 'Coffre Fort',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DocumentScreen()),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildMenuButton(
              context: context,
              icon: Icons.question_answer,
              text: 'Questionnaire Personnalisé',
              onPressed: () {
                Navigator.pushNamed(context, '/questionnaire');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.info,
              text: 'Informations sur les Droits',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LegalInfoScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.book,
              text: 'Guide de Procédures',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProceduresScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.location_on,
              text: 'Localisation des Structures',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.contacts,
              text: 'Répertoire des Contacts',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsDirectoryScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.computer,
              text: 'Consultations en Ligne',
              onPressed: () {
                // TODO: Implement when OnlineConsultationScreen is created
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cette fonctionnalité sera bientôt disponible')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.notifications,
              text: 'Alertes et Notifications',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(
              context: context,
              icon: Icons.work,
              text: 'Projets Professionnels',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalQuestionnaireScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.primaryGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: DesignSystem.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 