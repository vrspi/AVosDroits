import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.darkText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.darkText,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.mediumText.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.mediumText.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.mediumText.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.primaryGreen,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: Colors.red.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 