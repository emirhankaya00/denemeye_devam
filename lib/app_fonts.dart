import 'package:flutter/material.dart';

class AppFonts {
  static const String poppins = 'Poppins';
  static const String montserrat = 'Montserrat';

  // Mevcut stilleriniz...
  static TextStyle displayLarge({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle displayMedium({Color? color}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  // Kalın Poppins için yeni stil
  static TextStyle poppinsBold({Color? color, double? fontSize}) {
    return TextStyle(
      fontFamily: poppins,
      fontSize: fontSize ?? 16, // Varsayılan boyut 16, ancak dışarıdan ayarlanabilir
      fontWeight: FontWeight.w700, // Kalınlık 700 (bold)
      color: color,
    );
  }

  static TextStyle bodyLarge({Color? color}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return TextStyle(
      fontFamily: montserrat,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}