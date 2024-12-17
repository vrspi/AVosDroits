import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // Colors
  static const primaryGreen = Color(0xFF2E7D32);
  static const secondaryGreen = Color(0xFF388E3C);
  static const neutralGray = Color(0xFFF5F5F5);
  static const darkText = Color(0xFF212121);
  static const mediumText = Color(0xFF757575);
  static const lightText = Color(0xFFBDBDBD);

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // Radius
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusExtraLarge = 24;

  // Typography
  static final TextStyle headingLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static final TextStyle headingMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static final TextStyle headingSmall = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
  );

  static final TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static final TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Spacing
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingExtraLarge = 32;

  // Elevation
  static const double elevationSmall = 2;
  static const double elevationMedium = 4;
  static const double elevationLarge = 8;
  static const double elevationExtraLarge = 16;

  // Border Width
  static const double borderWidthThin = 1;
  static const double borderWidthMedium = 2;
  static const double borderWidthThick = 3;
} 