import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/search_viewmodel.dart';
import '../../widgets/specific/salon_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          // 1. Arka plan rengi güncellendi.
          backgroundColor: AppColors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KATEGORİLER BÖLÜMÜ ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  'Kategoriler',
                  // 2. Başlık rengi güncellendi.
                  style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    final isSelected = viewModel.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          viewModel.selectCategory(category);
                        },
                        // 3. Chip renkleri güncellendi.
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: AppColors.cardColor,
                        labelStyle: AppFonts.bodyMedium(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : AppColors.borderColor,
                          ),
                        ),
                        elevation: 0,
                        pressElevation: 0,
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Divider(color: AppColors.borderColor, height: 1),
              ),

              // --- ARAMA SONUÇLARI BÖLÜMÜ ---
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                    : viewModel.filteredSaloons.isEmpty
                    ? _buildNoResultsFound(viewModel)
                    : _buildSearchResultsList(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  // "Sonuç Bulunamadı" mesajını gösteren widget
  Widget _buildNoResultsFound(SearchViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 4. İkon rengi güncellendi.
            Icon(Icons.search_off, size: 80, color: AppColors.iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              // Arama sorgusu varsa daha anlamlı bir mesaj göster
              viewModel.searchQuery.isNotEmpty
                  ? '"${viewModel.searchQuery}" için sonuç bulunamadı'
                  : 'Sonuç bulunamadı',
              // 5. Metin renkleri güncellendi.
              style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı bir kelime veya kategoriyle aramayı deneyin.',
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // Arama sonuçlarını listeleyen widget
  Widget _buildSearchResultsList(SearchViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: viewModel.filteredSaloons.length,
      itemBuilder: (context, index) {
        final salon = viewModel.filteredSaloons[index];
        // **DÜZELTME:** serviceNames değişkeni burada tanımlandı.
        final serviceNames = salon.services.map((s) => s.serviceName).toList();

        return SalonCard(
          salonId: salon.saloonId,
          name: salon.saloonName,
          description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
          rating: '4.1', // Bu değer dinamik olarak modelden gelmeli
          location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
          distance: '5 Km', // Bu değer dinamik olarak hesaplanmalı
          // `serviceNames` artık doğru bir şekilde `SalonCard`'a gönderiliyor.
          services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
          imagePath: salon.titlePhotoUrl,
        );
      },
    );
  }
}