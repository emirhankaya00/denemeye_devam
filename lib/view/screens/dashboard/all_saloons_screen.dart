// lib/view/screens/dashboard/all_saloons_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../widgets/specific/salon_card.dart';

class AllSaloonsScreen extends StatelessWidget {
  final String title;
  final List<SaloonModel> saloons;

  const AllSaloonsScreen({
    super.key,
    required this.title,
    required this.saloons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames = salon.services.map((s) => s.serviceName).toList();

          // SalonCard'ı dikey listede düzgün göstermek için bir Padding ekliyoruz.
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SalonCard(
              salonId: salon.saloonId,
              name: salon.saloonName,
              description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
              rating: salon.rating, // Dinamik olarak gelmeli
              location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
              distance: '5 Km', // Bu değer hesaplanmalı
              services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
              imagePath: salon.titlePhotoUrl,
            ),
          );
        },
      ),
    );
  }
}