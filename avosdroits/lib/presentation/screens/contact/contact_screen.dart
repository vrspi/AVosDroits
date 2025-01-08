import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/utils/responsive_helper.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Container(
      color: DesignSystem.neutralGray,
      padding: screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Contactez-nous',
            style: DesignSystem.headingLarge.copyWith(
              color: DesignSystem.darkText,
              fontSize: isMobile ? 24 : 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nous sommes là pour vous aider',
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.mediumText,
            ),
          ),
          const SizedBox(height: 32),
          _buildContactCard(
            icon: Icons.email,
            title: 'Email',
            content: 'support@avosdroits.fr',
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.phone,
            title: 'Téléphone',
            content: '+33 1 23 45 67 89',
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.location_on,
            title: 'Adresse',
            content: '123 Rue de la Justice\n75001 Paris, France',
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignSystem.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: DesignSystem.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignSystem.bodyLarge.copyWith(
                    color: DesignSystem.darkText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: DesignSystem.bodyMedium.copyWith(
                    color: DesignSystem.mediumText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 