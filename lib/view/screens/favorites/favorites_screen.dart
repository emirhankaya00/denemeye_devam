import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../../view_models/search_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavoriteSaloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FavoritesViewModel, SearchViewModel>(
      builder: (context, favoritesViewModel, searchViewModel, child) {
        final List<SaloonModel> displaySaloons = searchViewModel.searchQuery.isEmpty
            ? favoritesViewModel.favoriteSaloons
            : favoritesViewModel.favoriteSaloons.where((saloon) {
          final query = searchViewModel.searchQuery.toLowerCase();
          return saloon.saloonName.toLowerCase().contains(query) ||
              (saloon.saloonAddress?.toLowerCase().contains(query) ?? false);
        }).toList();

        return Scaffold(
          // 1. Arka plan rengi güncellendi.
          backgroundColor: AppColors.background,
          body: favoritesViewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : displaySaloons.isEmpty
              ? _buildEmptyFavorites(context, searchViewModel.searchQuery.isNotEmpty)
              : _buildFavoritesList(favoritesViewModel, displaySaloons),
        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context, bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. İkon rengi güncellendi.
            Icon(isSearching ? Icons.search_off : Icons.favorite_border, size: 80, color: AppColors.iconColor.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'Arama sonucunuz bulunamadı.' : 'Henüz favori salonunuz yok.',
              // 3. Başlık metin rengi güncellendi.
              style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching ? 'Farklı bir arama terimi deneyin.' : 'Beğendiğiniz salonları kalbe dokunarak favorilerinize ekleyin!',
              textAlign: TextAlign.center,
              // 4. Açıklama metin rengi güncellendi.
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesViewModel viewModel, List<SaloonModel> saloonsToDisplay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: saloonsToDisplay.length,
      itemBuilder: (context, index) {
        final salon = saloonsToDisplay[index];
        return FavoriteSalonCard(
          salon: salon,
          onRemoveFavorite: () => viewModel.toggleFavorite(salon.saloonId),
        );
      },
    );
  }
}

class FavoriteSalonCard extends StatelessWidget {
  final SaloonModel salon;
  final VoidCallback onRemoveFavorite;

  const FavoriteSalonCard({
    super.key,
    required this.salon,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // 5. Kart rengi güncellendi.
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                  ? Image.network(salon.titlePhotoUrl!, width: 80, height: 80, fit: BoxFit.cover)
              // 6. Resim yoksa gösterilecek konteyner rengi güncellendi.
                  : Container(width: 80, height: 80, color: AppColors.borderColor, child: const Icon(Icons.store, color: AppColors.iconColor)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 7. Metin renkleri güncellendi.
                  Text(salon.saloonName, style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(salon.saloonAddress ?? 'Adres bilgisi yok', style: AppFonts.bodySmall(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            IconButton(
              // 8. İkon rengi güncellendi.
              icon: Icon(Icons.favorite, color: Colors.red.shade400),
              onPressed: onRemoveFavorite,
            ),
          ],
        ),
      ),
    );
  }
}