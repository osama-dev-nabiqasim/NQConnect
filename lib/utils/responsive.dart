import 'package:flutter/material.dart';

class Responsive {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double font(BuildContext context, double size) =>
      (width(context) / 390) * size; // base iPhone 12 width reference
}

double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenWidth(BuildContext context) => MediaQuery.of(context).size.height;

class AppColors {
  static List<Color> get appbarColor => [
    const Color(0xFF0072CF),
    Colors.blue.shade500.withOpacity(0.6),
  ];

  static List<Color> get primaryColor => [
    Colors.blue.shade900,
    Colors.blue.shade700.withOpacity(0.6),
  ];

  static LinearGradient get primaryLinearGradient => LinearGradient(
    colors: primaryColor,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Gradient Colors
  static List<Color> get secondaryColor => [
    const Color(0xFF14B8A6).withOpacity(0.9),
    const Color(0xFF4DD0E1).withOpacity(0.6),
  ];

  static LinearGradient get secondaryLinearGradient => LinearGradient(
    colors: secondaryColor,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Gradient Colors
  static List<Color> get backgroundColor => [
    const Color.fromARGB(255, 181, 181, 181),
    const Color(0xFFF4F6F9),
  ];

  static LinearGradient get backgroundLinearGradient => LinearGradient(
    colors: backgroundColor,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<Color> get buttonPrimary => [
    Colors.blue.shade900.withOpacity(0.9),
    Colors.blue.shade400.withOpacity(0.9),
  ];

  static LinearGradient get buttonPrimaryLinearGradient => LinearGradient(
    colors: buttonPrimary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<Color> get buttonDisabled => [
    Colors.grey.shade500,
    Colors.grey.shade400,
  ];

  static LinearGradient get buttonDisabledLinearGradient => LinearGradient(
    colors: buttonDisabled,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
