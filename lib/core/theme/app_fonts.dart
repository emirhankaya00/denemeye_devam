import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppFonts {



  static TextStyle poppinsCardTitle({
    double fontSize = 20,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: FontWeight.w700, // Poppins-Bold
      color: color,
    );
  }

  static TextStyle poppinsHeaderTitle({
    double fontSize = 20,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: FontWeight.w200, // Poppins-Bold
      color: color,
    );
  }

  static const String _fontFamily = 'Poppins';

  static TextStyle poppinsBold({
    double fontSize = 18,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.bold, // w700
      color: color,
    );
  }

  static TextStyle bodyMedium({
    double fontSize = 14,
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w200, // w400
      color: color,
    );
  }

  static TextStyle bodySmall({
    double fontSize = 12,
    Color color = AppColors.textSecondary,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w200, // w400
      color: color,
    );
  }
}