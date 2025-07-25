import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../screens/appointments/salon_detail_screen.dart';

class SalonCard extends StatelessWidget {
  final String salonId;
  final String name;
  final String rating;
  final List<String> services;
  final bool hasCampaign;
  final String? imagePath;

  const SalonCard({
    super.key,
    required this.salonId,
    required this.name,
    required this.rating,
    required this.services,
    this.hasCampaign = false,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;

    // --- DEĞİŞİKLİKLER BURADA BAŞLIYOR ---

    // 1. En dışa Card widget'ını koyduk. Bu bizim TUVALİMİZ.
    // Gölgeyi (elevation), şekli (shape) ve rengi (color) artık o yönetiyor.
    return Card(
      margin: const EdgeInsets.only(right: 15, bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.cardColor,
      elevation: 5,
      clipBehavior: Clip.antiAlias, // Bu, tıklama efektinin kart dışına taşmasını engeller. Çok şık durur.

      // 2. InkWell'i Card'ın içine, Stack'in dışına koyduk.
      // Artık üzerine mürekkebi damlatacağı bir tuvali var!
      // Stack'i sarmalamasının sebebi, kartın tamamının tıklanabilir olmasını sağlamak.
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalonDetailScreen(salonId: salonId),
            ),
          );
        },
        child: SizedBox( // Sadece boyut vermek için artık Container yerine daha hafif olan SizedBox kullanıyoruz.
          width: cardWidth,
          height: 220,
          child: Stack(
            children: [
              // Salon Resmi (Kartı kaplayacak şekilde)
              // Bu kısım aynı kalıyor, mükemmel çalışıyor.
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0), // Card'ın köşeleriyle uyumlu olsun
                  child: imagePath != null && imagePath!.isNotEmpty
                      ? (imagePath!.startsWith('http')
                      ? Image.network(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder)
                      : Image.asset(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder))
                      : _errorBuilder(context, null, null),
                ),
              ),

              // Siyah Gradient Overlay (Bu da mükemmel)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Metin İçeriği (Bu da mükemmel)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textOnPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.starColor, size: 16),
                        const SizedBox(width: 4),
                        Text(rating, style: AppFonts.bodyMedium(color: AppColors.textOnPrimary)),
                        const SizedBox(width: 8),
                        if (hasCampaign)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tagColorActive,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text('Kampanya', style: AppFonts.bodySmall(color: AppColors.textOnPrimary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: services.map((service) => _buildServiceTag(service)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hizmet Etiketi Oluşturucu Fonksiyon (Bu da mükemmel)
  Widget _buildServiceTag(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tagColorPassive.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service,
        style: AppFonts.bodySmall(color: AppColors.textColorDark),
      ),
    );
  }

  // Resim yüklenemediğinde gösterilecek yedek widget (Kod tekrarını önlemek için)
  Widget _errorBuilder(BuildContext context, Object? error, StackTrace? stackTrace) {
    return Container(
      color: AppColors.backgroundColorDark,
      child: Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
    );
  }
}