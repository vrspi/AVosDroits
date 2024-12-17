import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getCardWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) {
      return screenWidth * 0.2; // 20% of screen width on desktop
    } else if (isTablet(context)) {
      return screenWidth * 0.4; // 40% of screen width on tablet
    } else {
      return screenWidth * 0.8; // 80% of screen width on mobile
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 4; // 4 cards per row on desktop
    } else if (isTablet(context)) {
      return 2; // 2 cards per row on tablet
    } else {
      return 1; // 1 card per row on mobile
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }
} 