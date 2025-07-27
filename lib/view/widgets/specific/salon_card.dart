import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../screens/appointments/salon_detail_screen.dart';
import '../../../data/repositories/supabase_repository.dart';

/// Salon kartı
class SalonCard extends StatelessWidget {
  final String  salonId;
  final String  name;
  final String  description;
  final double  rating;
  final String  location;
  final String  distance;
  final List<String> services;
  final String? imagePath;
  final bool  showEditButton;

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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SalonDetailScreen(salonId: salonId)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 360,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Alt beyaz kısım
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.cardColor,
                ),
                padding: const EdgeInsets.fromLTRB(16, 65, 16, 16),
                child: _buildInfoColumn(context),
              ),
            ),
            // Üst görsel
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _buildImage(context),
                  ),
                  if (showEditButton) _buildEditButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resim – network/asset/yedek
  Widget _buildImage(BuildContext context) {
    return imagePath != null && imagePath!.isNotEmpty
        ? (imagePath!.startsWith('http')
        ? Image.network(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder)
        : Image.asset(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder))
        : _errorBuilder(context, null, null);
  }

  /// Düzenle butonu (isteğe bağlı)
  Positioned _buildEditButton() => Positioned(
    top: 8,
    right: 8,
    child: Material(
      color: Colors.black45,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => SupabaseRepository().uploadSalonImageAndUpdate(salonId),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
    ),
  );

  /// Kart içi bilgiler
  Widget _buildInfoColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Başlık + açıklama + puan satırı
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: AppFonts.poppinsCardTitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(description,
              style: AppFonts.bodySmall(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          _buildRatingRow(),
        ],
      ),
      // Hizmet rozetleri
      if (services.isNotEmpty)
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (_, i) => _buildServiceTag(services[i]),
          ),
        ),
    ],
  );

  /// ⭐⭐⭐⭐☆  + 4.5  + konum/distance
  Widget _buildRatingRow() {
    // 0-5 arası dolu / yarım / boş yıldız listesi
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, size: 18, color: AppColors.starColor));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half,
            size: 18, color: AppColors.starColor));
      } else {
        stars.add(const Icon(Icons.star_border,
            size: 18, color: AppColors.starColor));
      }
    }

    return Row(
      children: [
        ...stars,
        const SizedBox(width: 6),
        Text(rating.toStringAsFixed(1),
            style: AppFonts.bodyMedium(color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        const Text('•', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(location,
              style: AppFonts.bodyMedium(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        const Text('•', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Text(distance, style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
      ],
    );
  }

  /// Hizmet rozetleri
  Widget _buildServiceTag(String service) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primaryColor.withOpacity(.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(service,
        style: AppFonts.bodySmall(color: AppColors.primaryColor)
            .copyWith(fontWeight: FontWeight.bold)),
  );

  /// Görsel gelmezse fallback
  Widget _errorBuilder(BuildContext _, __, ___) => Container(
    decoration: BoxDecoration(
      color: AppColors.borderColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Center(
        child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
  );
}
