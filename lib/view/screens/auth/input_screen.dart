import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart'; // Fontları kullanmak için ekliyoruz

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Scaffold'un arka plan rengi güncellendi
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // 2. AppBar renkleri güncellendi
        title: Text('Giriş Alanları', style: AppFonts.poppinsBold(color: AppColors.textOnPrimary)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bilgileri Doldur',
              style: AppFonts.poppinsBold(
                fontSize: 26,
                // 3. Başlık rengi güncellendi
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 30),

            // CustomTextField yerine standart TextField kullanımı (yeni tasarıma uygun)
            _buildTextField(
              controller: _nameController,
              labelText: 'Adınız Soyadınız',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              labelText: 'E-posta Adresiniz',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              labelText: 'Şifreniz',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 40),

            // Buton renkleri ve stili güncellendi
            ElevatedButton(
              onPressed: () {
                debugPrint('Ad: ${_nameController.text}');
                debugPrint('Email: ${_emailController.text}');
                debugPrint('Şifre: ${_passwordController.text}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giriş Denemesi Yapıldı!')),
                );
              },
              style: ElevatedButton.styleFrom(
                // 4. Buton renkleri güncellendi
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Giriş Yap',
                style: AppFonts.poppinsBold(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Diğer sayfalardaki tasarımla tutarlı, yeniden kullanılabilir TextField widget'ı
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
        prefixIcon: Icon(prefixIcon, color: AppColors.iconColor),
        // Underline stili yerine Outline stili daha modern olabilir
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}