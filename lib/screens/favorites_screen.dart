// lib/screens/favorites_screen.dart
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart'; // SearchViewModel eklendi

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa her açıldığında listenin güncel olduğundan emin olalım
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavoriteSaloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hem FavoritesViewModel hem SearchViewModel'daki değişiklikleri dinlemek için Consumer2 kullanıyoruz
    return Consumer2<FavoritesViewModel, SearchViewModel>(
      builder: (context, favoritesViewModel, searchViewModel, child) {
        // Arama sorgusuna göre filtrelenmiş listeyi elde et
        final List<SaloonModel> displaySaloons = searchViewModel.searchQuery.isEmpty
            ? favoritesViewModel.favoriteSaloons
            : favoritesViewModel.favoriteSaloons.where((saloon) {
          final query = searchViewModel.searchQuery.toLowerCase();
          return saloon.saloonName.toLowerCase().contains(query) ||
              (saloon.saloonAddress?.toLowerCase().contains(query) ?? false);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          // AppBar'ı buradan kaldırdık. Artık RootScreen'daki MainApp yönetecek.
          body: favoritesViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : displaySaloons.isEmpty
              ? _buildEmptyFavorites(context, searchViewModel.searchQuery.isNotEmpty)
              : _buildFavoritesList(favoritesViewModel, displaySaloons),
        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSearching ? Icons.search_off : Icons.favorite_border, size: 80, color: AppColors.iconColor.withAlpha(128)),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'Arama sonucunuz bulunamadı.' : 'Henüz favori salonunuz yok.',
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight),
          ),
          const SizedBox(height: 10),
          Text(
            isSearching ? 'Farklı bir arama terimi deneyin.' : 'Beğendiğiniz salonları favorilerinize ekleyin!',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
          ),
        ],
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
          onBookAppointment: () => viewModel.navigateToSalonDetail(context, salon),
        );
      },
    );
  }
}

// FavoriteSalonCard değişmedi, sadece SaloonModel aldığı için adı güncel
class FavoriteSalonCard extends StatelessWidget {
  final SaloonModel salon;
  final VoidCallback onRemoveFavorite;
  final VoidCallback onBookAppointment;

  const FavoriteSalonCard({
    super.key,
    required this.salon,
    required this.onRemoveFavorite,
    required this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                  ? Image.network(salon.titlePhotoUrl!, width: 80, height: 80, fit: BoxFit.cover)
                  : Container(width: 80, height: 80, color: AppColors.backgroundColorDark, child: const Icon(Icons.store)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(salon.saloonName, style: AppFonts.poppinsBold(fontSize: 16)),
                  Text(salon.saloonAddress ?? 'Adres yok', style: AppFonts.bodySmall(), maxLines: 1),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.primaryColor),
              onPressed: onRemoveFavorite,
            ),
          ],
        ),
      ),
    );
  }
}