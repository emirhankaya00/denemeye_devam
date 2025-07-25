import 'package:flutter/material.dart';

class AppColors {
  // --- YENİ TASARIM RENK PALETİ ---

  // Ana Renkler
  static const Color primaryColor = Color(0xFF5271FF); // Ana marka rengi (eski adıyla 'primary')
  static const Color background = Color(0xFFFFFFFF);     // Genel sayfa arka planı

  // Metin Renkleri
  static const Color textPrimary = Color(0xFF000000);   // Ana metinler, başlıklar (Siyah)
  static const Color textSecondary = Color(0xFF9E9E9E); // İkincil, yardımcı metinler (Gri)
  static const Color textButton = Color(0xFF5271FF);     // Metin şeklindeki butonlar
  static const Color textOnPrimary = Colors.white;      // Ana rengin üzerindeki metinler (örn. Buton yazısı)

  // Fonksiyonel Renkler
  static const Color starColor = Colors.amber;             // Puanlama yıldızları için ⭐
  static const Color cardColor = Color(0xFFFFFFFF);        // Kartların arka plan rengi (gölgeli)
  static const Color borderColor = Color(0xFFE8E8E8);      // Ayırıcılar ve kenarlıklar için genel renk
  static const Color iconColor = Color(0xFF9E9E9E);        // Genel ikon rengi
}