// lib/view/screens/dashboard/category_saloons_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/dashboard_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';

class CategorySaloonsScreen extends StatefulWidget {
  final String categoryName;

  const CategorySaloonsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategorySaloonsScreen> createState() => _CategorySaloonsScreenState();
}

class _CategorySaloonsScreenState extends State<CategorySaloonsScreen> {
  @override
  void initState() {
    super.initState();
    // Bu widget oluşturulduğunda, arayüzün ilk çiziminden hemen sonra
    // ViewModel'den ilgili kategorideki salonları getirmesi için istek gönderiyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false)
          .fetchSaloonsByCategory(widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // Sayfa başlığında, bir önceki ekrandan gelen kategori adını gösteriyoruz.
        title: Text(widget.categoryName, style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      // `Consumer` widget'ı, `DashboardViewModel`'deki değişiklikleri dinler
      // ve sadece bu bölümün yeniden çizilmesini sağlar. Bu, performansı artırır.
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          // Veriler yükleniyorsa, bir yükleme göstergesi (spinner) gösterilir.
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          // Yükleme bittikten sonra, eğer o kategoride hiç salon bulunamadıysa,
          // kullanıcıya bilgilendirici bir mesaj gösterilir.
          if (viewModel.categorySaloons.isEmpty) {
            return Center(
              child: Text(
                'Bu kategoride salon bulunamadı.',
                style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              ),
            );
          }

          // Salonlar başarıyla bulunduysa, bir liste halinde gösterilir.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.categorySaloons.length,
            itemBuilder: (context, index) {
              final salon = viewModel.categorySaloons[index];
              // `SaloonModel` içindeki hizmet listesini alıyoruz.
              final serviceNames = salon.services.map((s) => s.serviceName).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SalonCard(
                  salonId: salon.saloonId,
                  name: salon.saloonName,
                  description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
                  // TODO: Bu veriler dinamik olarak modelden gelmeli.
                  rating: '4.1',
                  location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
                  distance: '5 Km', // Bu değer hesaplanmalı
                  services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
                  imagePath: salon.titlePhotoUrl,
                ),
              );
            },
          );
        },
      ),
    );
  }
}