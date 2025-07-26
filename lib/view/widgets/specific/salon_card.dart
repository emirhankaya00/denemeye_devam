// lib/view/widgets/specific/salon_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../screens/appointments/salon_detail_screen.dart';
import '../../../data/repositories/supabase_repository.dart';

class SalonCard extends StatelessWidget {
  // ... (parametreler aynı kalıyor)
  final String salonId;
  final String name;
  final String description;
  final String rating;
  final String location;
  final String distance;
  final List<String> services;
  final String? imagePath;
  final bool showEditButton;

  const SalonCard({
    super.key,
    required this.salonId,
    required this.name,
    required this.description,
    required this.rating,
    required this.location,
    required this.distance,
    required this.services,
    this.imagePath,
    this.showEditButton = false,
  });


  @override
  Widget build(BuildContext context) {
    // ... (build metodunun üst kısmı aynı kalıyor)
    final supabaseRepo = SupabaseRepository();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salonId: salonId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        height: 350,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.cardColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 65, 16, 16),
                  child: _buildInfoColumn(context),
                ),
              ),
            ),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: imagePath != null && imagePath!.isNotEmpty
                        ? (imagePath!.startsWith('http')
                        ? Image.network(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder)
                        : Image.asset(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder))
                        : _errorBuilder(context, null, null),
                  ),
                  if (showEditButton)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            supabaseRepo.uploadSalonImageAndUpdate(salonId);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              // DEĞİŞİKLİK 1: Kart başlığı KALIN Poppins oldu.
              style: AppFonts.poppinsCardTitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppFonts.bodySmall(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.starColor, size: 18),
                const SizedBox(width: 4),
                Text(rating, style: AppFonts.bodyMedium(color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    location,
                    style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Text(distance, style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 30, // Dikeyde daha ince olması için yükseklik azaltıldı.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceTag(services[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTag(String service) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      // DEĞİŞİKLİK 2: Dikey padding azaltılarak etiket daha ince yapıldı.
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          service,
          style: AppFonts.bodySmall(color: AppColors.primaryColor)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _errorBuilder(BuildContext context, Object? error, StackTrace? stackTrace) {
    // ... (değişiklik yok)
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
    );
  }
}