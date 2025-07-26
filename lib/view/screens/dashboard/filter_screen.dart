import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/filter_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';

/// Bu ekran, ana sayfadaki popup'ta seçilen filtrelere göre
/// bulunan salonların sonuçlarını listelemekle görevlidir.
/// Kendi içinde bir filtreleme mantığı veya state'i barındırmaz.
class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FilterViewModel'deki değişiklikleri dinleyerek arayüzü günceller.
    // 'watch' kullanıyoruz çünkü veri değiştiğinde bu ekranın yeniden çizilmesi gerekiyor.
    final viewModel = context.watch<FilterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Filtre Sonuçları', style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  /// Sayfanın gövdesini oluşturan ana metod.
  /// ViewModel'in durumuna göre farklı widget'lar gösterir.
  Widget _buildBody(BuildContext context, FilterViewModel viewModel) {
    // Veriler yükleniyorsa, bir yükleme animasyonu göster.
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    // Yükleme bittiğinde, eğer filtrelenmiş salon listesi boşsa, bir mesaj göster.
    if (viewModel.filteredSaloons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Bu kriterlere uyan salon bulunamadı.',
            style: AppFonts.poppinsHeaderTitle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Salonlar bulunduysa, onları bir liste halinde göster.
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.filteredSaloons.length,
      itemBuilder: (context, index) {
        final salon = viewModel.filteredSaloons[index];
        final serviceNames = salon.services.map((s) => s.serviceName).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SalonCard(
            salonId: salon.saloonId,
            name: salon.saloonName,
            description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
            rating: salon.rating, // TODO: Bu veri modelden gelmeli
            location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
            distance: '5 Km', // TODO: Bu değer hesaplanmalı
            services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
            imagePath: salon.titlePhotoUrl,
          ),
        );
      },
    );
  }
}