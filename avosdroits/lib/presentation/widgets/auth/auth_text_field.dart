import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: DesignSystem.bodySmall.copyWith(
                color: DesignSystem.mediumText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: DesignSystem.bodyMedium.copyWith(
            color: enabled ? DesignSystem.darkText : DesignSystem.mediumText,
          ),
          decoration: InputDecoration(
            labelText: enabled ? label : null,
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? Colors.white : DesignSystem.neutralGray.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.lightText.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.lightText.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.primaryGreen,
                width: 2,
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
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.lightText.withOpacity(0.1),
              ),
            ),
            labelStyle: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.mediumText,
            ),
            hintStyle: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.lightText,
            ),
            errorStyle: DesignSystem.bodySmall.copyWith(
              color: Colors.red.shade400,
            ),
          ),
        ),
      ],
    );
  }
} 