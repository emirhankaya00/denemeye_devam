import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // Font stillerini kullanmak için eklendi

import 'package:denemeye_devam/features/appointments/screens/salon_detail_screen.dart'; // Yeni detay sayfamızı import ettik

class SalonCard extends StatelessWidget {
  final String salonId;
  final String name;
  final String rating;
  final List<String> services;
  final bool hasCampaign;
  final String? imagePath; // Opsiyonel hale getirdik, eğer görsel yoksa null olabilir

  const SalonCard({
    super.key,
    required this.salonId,
    required this.name,
    required this.rating,
    required this.services,
    this.hasCampaign = false,
    this.imagePath, // Artık varsayılan bir yol atamıyoruz, dışarıdan gelmezse null kalır.
  });

  @override
  Widget build(BuildContext context) {
    // Ekran genişliğine göre kart genişliğini ayarlıyoruz.
    // Örneğin, ekranın %45'i kadar, bu sayede yan yana iki kart rahat sığabilir ve boşluk kalır.
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45; // Ekran genişliğinin %45'i

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salonId: salonId),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        // Kartın genişliğini ve sağındaki boşluğu ayarlıyoruz.
        margin: const EdgeInsets.only(right: 15, bottom: 15), // Sağdan 15, alttan 15 boşluk
        width: cardWidth, // Responsive genişlik
        height: 220, // Kartın yüksekliğini biraz daha azalttık
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.textColorLight.withValues(alpha: 0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Salon Resmi (Kartı kaplayacak şekilde)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imagePath != null && imagePath!.isNotEmpty
                    ? (imagePath!.startsWith('http')
                    ? Image.network(
                  imagePath!,
                  fit: BoxFit.cover,
                  // Resim yüksekliği Stack tarafından yönetildiği için burada fixed yükseklik kaldırdık.
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        color: AppColors.backgroundColorDark,
                        child: Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
                      ),
                )
                    : Image.asset( // Eğer URL değilse asset olarak dene
                  imagePath!,
                  fit: BoxFit.cover,
                  // Resim yüksekliği Stack tarafından yönetildiği için burada fixed yükseklik kaldırdık.
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        color: AppColors.backgroundColorDark,
                        child: Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
                      ),
                ))
                    : Container(
                  color: AppColors.backgroundColorDark,
                  child: Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
                ),
              ),
            ),

            // Siyah Gradient Overlay (Resmin üzerinde, alttan başlayacak)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // Üst kısım şeffaf
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6), // Alt kısım daha koyu
                    ],
                    stops: const [0.5, 0.7, 1.0], // Gradient'ın dağılımı
                  ),
                ),
              ),
            ),

            // Metin İçeriği (Gradient'in üzerinde)
            Positioned(
              bottom: 12, // Alt padding
              left: 12, // Sol padding
              right: 12, // Sağ padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Adı
                  Text(
                    name,
                    style: AppFonts.poppinsBold(
                      fontSize: 16, // Yazı boyutu biraz küçüldü
                      color: AppColors.textOnPrimary, // Beyaz metin
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Yıldızlar ve Puan
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.starColor, size: 16), // İkon boyutu
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: AppFonts.bodyMedium(
                          color: AppColors.textOnPrimary, // Beyaz metin
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Kampanya Etiketi (Eğer varsa)
                      if (hasCampaign)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tagColorActive,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Kampanya',
                            style: AppFonts.bodySmall( // bodySmall ile devam
                              color: AppColors.textOnPrimary, // Beyaz metin
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8), // Boşluk
                  // Hizmet Etiketleri
                  Wrap(
                    spacing: 5, // Hizmet etiketleri arası boşluk
                    runSpacing: 5, // Satırlar arası boşluk
                    children: services.map((service) => _buildServiceTag(service)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hizmet Etiketi Oluşturucu Fonksiyon
  Widget _buildServiceTag(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.tagColorPassive.withValues(alpha: 0.8), // Hafif şeffaf pasif etiket
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        service,
        style: AppFonts.bodySmall(
          color: AppColors.textColorDark, // Koyu metin
        ),
      ),
    );
  }
}