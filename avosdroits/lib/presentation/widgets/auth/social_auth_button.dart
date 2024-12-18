import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

class SocialAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: DesignSystem.darkText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          side: BorderSide(
            color: onPressed == null
                ? DesignSystem.mediumText.withOpacity(0.1)
                : DesignSystem.mediumText.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: onPressed == null
                ? DesignSystem.mediumText
                : DesignSystem.darkText,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: DesignSystem.buttonLarge.copyWith(
              color: onPressed == null
                  ? DesignSystem.mediumText
                  : DesignSystem.darkText,
            ),
          ),
        ],
      ),
    );
  }
} 