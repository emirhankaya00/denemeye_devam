// lib/view/screens/favorites/favorites_screen.dart

import 'package:denemeye_devam/view/screens/appointments/salon_detail_screen.dart';
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
    // Sayfa ilk açıldığında favori salonları çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesViewModel>(context, listen: false).fetchFavoriteSaloons();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'leri dinleyerek arayüzü güncel tut
    return Consumer2<FavoritesViewModel, SearchViewModel>(
      builder: (context, favoritesViewModel, searchViewModel, child) {
        // Arama çubuğuna yazılan metne göre favorileri filtrele
        final List<SaloonModel> displaySaloons = searchViewModel.searchQuery.isEmpty
            ? favoritesViewModel.favoriteSaloons
            : favoritesViewModel.favoriteSaloons.where((saloon) {
          final query = searchViewModel.searchQuery.toLowerCase();
          return saloon.saloonName.toLowerCase().contains(query) ||
              (saloon.saloonAddress?.toLowerCase().contains(query) ?? false);
        }).toList();

        // RootScreen zaten bir Scaffold sağladığı için burada tekrar kullanmıyoruz.
        // Sadece sayfanın gövdesini oluşturuyoruz.
        return Container(
          color: AppColors.background,
          child: favoritesViewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
              : displaySaloons.isEmpty
              ? _buildEmptyFavorites(context, searchViewModel.searchQuery.isNotEmpty)
              : _buildFavoritesList(favoritesViewModel, displaySaloons),
        );
      },
    );
  }

  // Favori listesi boş olduğunda gösterilecek widget (Bu kısım aynı kalıyor)
  Widget _buildEmptyFavorites(BuildContext context, bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSearching ? Icons.search_off : Icons.favorite_border, size: 80, color: AppColors.iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              isSearching ? 'Arama sonucunuz bulunamadı.' : 'Henüz favori salonunuz yok.',
              style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              isSearching ? 'Farklı bir arama terimi deneyin.' : 'Beğendiğiniz salonları kalbe dokunarak favorilerinize ekleyin!',
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // Favori salonların listesini oluşturan widget (Bu kısım aynı kalıyor)
  Widget _buildFavoritesList(FavoritesViewModel viewModel, List<SaloonModel> saloonsToDisplay) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: saloonsToDisplay.length,
      itemBuilder: (context, index) {
        final salon = saloonsToDisplay[index];
        return FavoriteSalonCard(
          salon: salon,
          onFavoriteToggle: () => viewModel.toggleFavorite(salon.saloonId),
        );
      },
    );
  }
}


// --- YENİ TASARIMA GÖRE TAMAMEN YENİLENEN KART WIDGET'I ---
class FavoriteSalonCard extends StatelessWidget {
  final SaloonModel salon;
  final VoidCallback onFavoriteToggle;

  const FavoriteSalonCard({
    super.key,
    required this.salon,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Hizmet isimlerini modelden alıp bir listeye dönüştürüyoruz.
    final serviceNames = salon.services.map((s) => s.serviceName).take(3).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05), // Hafif mor/mavi arka plan
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol Taraf: Salon Resmi
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: salon.titlePhotoUrl != null && salon.titlePhotoUrl!.isNotEmpty
                ? Image.network(
              salon.titlePhotoUrl!,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),
          // Sağ Taraf: Bilgiler ve Buton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salon Adı ve Favori İkonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        salon.saloonName,
                        style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: AppColors.primaryColor),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: onFavoriteToggle, // Favoriden çıkarma işlemi
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Puan, Konum ve Mesafe
                _buildDetailsRow(),
                const SizedBox(height: 6),
                // Hizmet Etiketleri
                if (serviceNames.isNotEmpty)
                  Text(
                    serviceNames.join(' • '),
                    style: AppFonts.bodySmall(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                // Randevu Oluştur Butonu
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SalonDetailScreen(saloonId: salon.saloonId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Randevu Oluştur', style: AppFonts.bodySmall(color: AppColors.primaryColor)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Resim olmadığında gösterilecek olan yer tutucu
  Widget _buildPlaceholderImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.store, color: AppColors.iconColor),
    );
  }

  // Puan, konum gibi detayları içeren satır
  Widget _buildDetailsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: AppColors.starColor, size: 16),
        const SizedBox(width: 4),
        Text(
          salon.rating.toStringAsFixed(1),
          style: AppFonts.bodyMedium(color: AppColors.textPrimary),
        ),
        const SizedBox(width: 6),
        Text('•', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
        const SizedBox(width: 6),
        // Adresin sadece ilk kısmını (genellikle ilçe) alıyoruz
        Expanded(
          child: Text(
            salon.saloonAddress?.split(',').first ?? 'Konum',
            style: AppFonts.bodyMedium(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // TODO: Mesafe hesaplaması entegre edilecek
        Text('• 5 Km', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
      ],
    );
  }
}