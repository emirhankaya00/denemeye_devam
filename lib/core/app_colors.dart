import 'package:flutter/material.dart';

class AppColors {
  // Uygulamanızın ana renk paleti - (Gri tonlarına çevrildi)
  static const Color primary = Color(0xFF424242); // Koyu gri (Eskiden mor tonu)
  static const Color primaryLight = Color(0xFFBDBDBD); // Açık gri (Eskiden daha açık mor tonu)
  static const Color primaryDark = Color(0xFF212121); // Çok koyu gri/neredeyse siyah (Eskiden daha koyu mor tonu)

  static const Color secondary = Color(0xFF757575); // Orta gri (Eskiden turkuaz tonu)
  static const Color secondaryLight = Color(0xFFE0E0E0); // Çok açık gri (Eskiden daha açık turkuaz tonu)
  static const Color secondaryDark = Color(0xFF424242); // Koyu gri (Eskiden daha koyu turkuaz tonu)

  static const Color primaryColor = Color(0xFF212121); // Ana siyah/çok koyu gri (Eskiden bordo/kırmızı)
  static const Color accentColor = Color(0xFF757575); // Orta gri (Eskiden canlı pembe/kırmızı vurgu)
  static const Color backgroundColorLight = Color(0xFFF9F9F9); // Çok açık gri arka plan
  static const Color backgroundColorDark = Color(0xFFF0F0F0); // Biraz daha koyu gri arka plan
  static const Color cardColor = Color(0xFFFFFFFF); // Saf beyaz kart
  static const Color textFieldFillColor = Color(0xFFF9F9F9); // Input içi için hafif açık gri
  static const Color borderColor = Color(0xFFD0D0D0); // Orta açık gri border
  static const Color textColorDark = Color(0xFF212121); // Koyu gri metin
  static const Color textColorLight = Color(0xFF757575); // Açık gri metin
  static const Color iconColor = Color(0xFF9E9E9E); // Orta gri ikon
  static const Color starColor = Color(0xFFFFCC00); // Sarı yıldız rengi (Altın sarısı, genel algıyı bozmamak için korundu)
  static const Color tagColorActive = Color(0xFF616161); // Aktif etiket (Koyu gri)
  static const Color tagColorPassive = Color(0xFFE5E5E5); // Pasif etiket (Açık gri)
  static const Color dividerColor = Color(0xFFCCCCCC); // Ayırıcı çizgiler (Orta açık gri)

  // Metin renkleri (Gri tonlarına çevrildi)
  static const Color textPrimary = Color(0xFF212121); // Koyu metin rengi
  static const Color textSecondary = Color(0xFF757575); // Açık gri metin rengi
  static const Color textOnPrimary = Colors.white; // Primary rengi üzerindeki metin (beyaz)
  static const Color textOnError = Colors.white; // Hata rengi üzerindeki metin (beyaz)

  // Durum renkleri (Tonları ayarlandı)
  static const Color error = Color(0xFFDC3545); // Kırmızı hata (daha uyumlu ton)
  static const Color success = Color(0xFF28A745); // Yeşil başarı (daha uyumlu ton)
  static const Color warning = Color(0xFFFFC107); // Turuncu uyarı (daha uyumlu ton)

  // Arka plan ve yüzey renkleri (Gri tonlarına çevrildi)
  static const Color background = Color(0xFFF5F5F5); // Genel arka plan rengi
  static const Color surface = Colors.white; // Kartlar, dialoglar gibi yüzey rengi

  // Gri tonlar (isteğe bağlı - tanımları değiştirilmedi, sadece renk kodları yeni palete uygun)
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);

// Marka özel renkler (eğer varsa, bunları da gri tonlarına uydurabiliriz ya da nötr tutabiliriz)
// static const Color brandBlue = Color(0xFF1A73E8);
// static const Color brandGreen = Color(0xFF34A853);
}