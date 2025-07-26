import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppFonts {

  static TextStyle ralewayTitle({
    double fontSize = 24, // Daha büyük ve dikkat çekici
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: 'Raleway',
      fontSize: fontSize,
      fontWeight: FontWeight.w300, // Raleway-Light için w300 kullanılır
      color: color,
    );
  }
  static const String _fontFamily = 'Montserrat';

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

  static TextStyle poppinsSemiBold({
    double fontSize = 16,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600, // Semi-bold
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
      fontWeight: FontWeight.normal, // w400
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
      fontWeight: FontWeight.normal, // w400
      color: color,
    );
  }
}