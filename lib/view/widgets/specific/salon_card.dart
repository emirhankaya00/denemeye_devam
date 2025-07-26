import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../screens/appointments/salon_detail_screen.dart';
import '../../../data/repositories/supabase_repository.dart';

/// Salonları listeleyen ekranlarda kullanılan, standart ve yeniden kullanılabilir kart widget'ı.
class SalonCard extends StatelessWidget {
  final String salonId;
  final String name;
  final String description;
  final double rating; // DÜZELTME: Veri tipi 'double' olarak doğru şekilde tanımlı.
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
    return GestureDetector(
      onTap: () {
        // Karta tıklandığında, salonun ID'si ile detay sayfasına yönlendir.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SalonDetailScreen(salonId: salonId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        height: 360, // Sabit yükseklik, taşma sorunlarını engeller.
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Kartın alt beyaz kısmı
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
            // Kartın üst resim kısmı
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
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            // TODO: Bu repository'yi doğrudan burada oluşturmak yerine
                            // Provider veya GetIt gibi bir DI (Dependency Injection) yapısıyla
                            // yönetmek daha iyi bir pratiktir.
                            SupabaseRepository().uploadSalonImageAndUpdate(salonId);
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

  /// Kartın içindeki bilgi sütununu oluşturan yardımcı metod.
  Widget _buildInfoColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Salon Adı, Açıklama ve Puan Bilgileri
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
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
                // --- DÜZELTME: 'double' olan puanı 'String'e çeviriyoruz. ---
                // .toStringAsFixed(1) metodu, 4.0 gibi bir sayıyı "4.0" metnine çevirir.
                Text(rating.toStringAsFixed(1), style: AppFonts.bodyMedium(color: AppColors.textPrimary)),
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
        // Hizmet Rozetleri
        if (services.isNotEmpty)
          SizedBox(
            height: 30,
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

  /// Hizmet etiketlerini (rozetlerini) oluşturan fonksiyon.
  Widget _buildServiceTag(String service) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
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

  /// Resim yüklenemediğinde veya resim yolu boş olduğunda gösterilecek yedek widget.
  Widget _errorBuilder(BuildContext context, Object? error, StackTrace? stackTrace) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
    );
  }
}