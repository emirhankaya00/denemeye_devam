// lib/screens/favorites_screen.dart
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';

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
    return Consumer<FavoritesViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColorLight,
          appBar: AppBar(
            automaticallyImplyLeading: false, // Otomatik geri tuşunu kaldır
            title: const Text('Favorilerim'),
            centerTitle: true,
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.favoriteSaloons.isEmpty
              ? const Center(child: Text('Henüz favori salonunuz yok.'))
              : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.favoriteSaloons.length,
            itemBuilder: (context, index) {
              final salon = viewModel.favoriteSaloons[index];
              return FavoriteSalonCard(
                salon: salon,
                onRemoveFavorite: () => viewModel.toggleFavorite(salon.saloonId),
                onBookAppointment: () => viewModel.navigateToSalonDetail(context, salon),
              );
            },
          ),
        );
      },
    );
  }
}

// FavoriteSalonCard artık direkt SaloonModel alıyor
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
              child: salon.titlePhotoUrl != null
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