import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart'; // Renkler için AppColors kullanıyorsan

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final FocusNode? focusNode;
  final bool isFocused; // Input'un odaklanıp odaklanmadığını dışarıdan alacağız

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.focusNode,
    required this.isFocused, // Artık zorunlu parametre
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.obscureText;

    // Focus durumuna göre border ve shadow renklerini ayarla
    final Color borderColor = widget.isFocused ? AppColors.primaryColor : AppColors.borderColor;
    final Color shadowColor = widget.isFocused ? AppColors.primaryColor.withValues(alpha: 0.3) : Colors.transparent;
    final double elevation = widget.isFocused ? 8.0 : 3.0; // Focuslandığında daha belirgin yükselsin

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250), // Animasyon süresi
      decoration: BoxDecoration(
        color: AppColors.textPrimary, // İç dolgu rengi
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: widget.isFocused ? 2.0 : 1.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: elevation,
            spreadRadius: elevation / 4,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        cursorColor: AppColors.primaryColor, // İmleç rengi

        style: TextStyle(
          color: AppColors.textPrimary, // Yazı rengi
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          labelStyle: TextStyle(
            color: widget.isFocused ? AppColors.primaryColor : AppColors.textSecondary,
          ),
          hintStyle: TextStyle(
            color: AppColors.textOnPrimary.withValues(alpha:0.6),
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: widget.isFocused ? AppColors.primaryColor : AppColors.iconColor,
          )
              : null,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              // Şifre gösterme/gizleme ikonu (İstersen ekleyebiliriz)
              Icons.visibility,
              color: AppColors.iconColor,
            ),
            onPressed: () {
              // Bu kısımda şifre gösterme/gizleme mantığı eklenebilir
            },
          )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none, // Varsayılan TextField border'ını kaldırıyoruz
          // İç dolguyu daha yumuşak göstermek için
          filled: true,
          fillColor: Colors.transparent, // Zaten dışarıda background veriyoruz
        ),
      ),
    );
  }
}