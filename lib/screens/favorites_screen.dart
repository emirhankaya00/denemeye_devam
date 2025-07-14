// lib/screens/favorites_screen.dart
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart'; // Oluşturulacak ViewModel

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında ViewModel'dan favori salonları çekmesini iste
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavoriteSaloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'daki değişiklikleri dinlemek için Consumer widget'ı kullanıyoruz
    return Consumer<FavoritesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          appBar: _buildAppBar(context, viewModel),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.favoriteSaloons.isEmpty
              ? _buildEmptyFavorites(context)
              : _buildFavoritesList(viewModel),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, FavoritesViewModel viewModel) {
    return AppBar(
      backgroundColor: AppColors.primaryColor, //
      elevation: 0,
      toolbarHeight: 80.0,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary, //
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.arrow_back, color: AppColors.primaryColor, size: 20), //
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (query) {
            // Arama fonksiyonunu ViewModel üzerinden çağır
            viewModel.searchFavorites(query);
          },
          decoration: InputDecoration(
            hintText: 'Favorilerde ara...',
            hintStyle: AppFonts.bodyMedium(color: AppColors.textColorLight), //
            prefixIcon: Icon(Icons.search, color: AppColors.textColorLight), //
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          style: AppFonts.bodyMedium(color: AppColors.textColorDark), //
        ),
      ),
      actions: const [SizedBox(width: 16.0)],
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: AppColors.iconColor.withAlpha(128)), //
          const SizedBox(height: 20),
          Text(
            'Henüz favori salonunuz yok.',
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight), //
          ),
          const SizedBox(height: 10),
          Text(
            'Beğendiğiniz salonları favorilerinize ekleyin!',
            textAlign: TextAlign.center,
            style: AppFonts.bodyMedium(color: AppColors.textColorLight), //
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesViewModel viewModel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.filteredFavoriteSaloons.length,
      itemBuilder: (context, index) {
        final salon = viewModel.filteredFavoriteSaloons[index];
        return FavoriteSalonCard(
          salon: salon,
          onRemoveFavorite: () => viewModel.removeFavorite(salon.saloonId),
          onBookAppointment: () => viewModel.bookAppointment(context, salon),
        );
      },
    );
  }
}


// Kart widget'ı artık doğrudan SaloonModel alacak şekilde güncellendi.
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
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.cardColor, //
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.backgroundColorDark, //
                child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                    ? Image.network(
                  salon.titlePhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.store, size: 40, color: AppColors.iconColor), //
                )
                    : Icon(Icons.store, size: 40, color: AppColors.iconColor), //
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.saloonName, //
                    style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textColorDark), //
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salon.saloonAddress ?? 'Adres bilgisi yok', //
                    style: AppFonts.bodySmall(color: AppColors.textColorLight), //
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.starColor, size: 18), //
                      const SizedBox(width: 4),
                      Text(
                        '4.8', // Rating verisi modelde olmadığından şimdilik sabit
                        style: AppFonts.bodyMedium(color: AppColors.textColorLight), //
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onRemoveFavorite,
                  child: Icon(Icons.favorite, color: AppColors.accentColor, size: 28), //
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 35,
                  child: ElevatedButton(
                    onPressed: onBookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, //
                      foregroundColor: AppColors.textOnPrimary, //
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      'Randevu Al',
                      textAlign: TextAlign.center,
                      style: AppFonts.bodySmall(color: AppColors.textOnPrimary), //
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}