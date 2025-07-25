// lib/view/widgets/common/custom_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; // Yeni dosya yoluna göre import

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color ?? AppColors.cardColor, // Varsayılan kart rengi
          borderRadius: borderRadius ?? BorderRadius.circular(15), // Varsayılan yuvarlaklık
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5), // Gölge pozisyonu
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}