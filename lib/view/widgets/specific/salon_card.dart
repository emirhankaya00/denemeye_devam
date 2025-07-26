import 'package:flutter/material.dart';
// Gerekli importları ekliyoruz
import '../../../data/repositories/supabase_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../screens/appointments/salon_detail_screen.dart';

class SalonCard extends StatelessWidget {
  final String salonId;
  final String name;
  final String description;
  final String rating;
  final String location;
  final String distance;
  final List<String> services;
  final String? imagePath;
  // YENİ: Resim yükleme fonksiyonunu göstermek/gizlemek için bir bayrak
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
    this.showEditButton = false, // Varsayılan olarak gizli
  });

  @override
  Widget build(BuildContext context) {
    // Repository'den bir nesne oluşturuyoruz
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
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Bilgi Kartı (Alt Katman)
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.cardColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 65, 16, 16),
                  child: _buildInfoColumn(),
                ),
              ),
            ),

            // Resim Alanı (Üst Katman)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand, // Stack'in tüm alanı kaplamasını sağlar
                children: [
                  // Resmin kendisi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: imagePath != null && imagePath!.isNotEmpty
                        ? (imagePath!.startsWith('http')
                        ? Image.network(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder)
                        : Image.asset(imagePath!, fit: BoxFit.cover, errorBuilder: _errorBuilder))
                        : _errorBuilder(context, null, null),
                  ),

                  // --- DEĞİŞİKLİK BURADA: RESİM YÜKLEME BUTONU ---
                  // Eğer showEditButton true ise, butonu göster
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
                            // Tıklandığında resim yükleme fonksiyonunu çağır
                            supabaseRepo.uploadSalonImageAndUpdate(salonId);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
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

  // Bilgi sütununu oluşturan yardımcı metot (Değişiklik yok)
  Widget _buildInfoColumn() {
    // ... Bu metodun içeriği aynı kalıyor ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          name,
          style: AppFonts.poppinsSemiBold(fontSize: 20, color: AppColors.textPrimary),
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
        const Spacer(),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services.take(3).map((service) => _buildServiceTag(service)).toList(),
        ),
      ],
    );
  }

  // Hizmet etiketini oluşturan fonksiyon (Değişiklik yok)
  Widget _buildServiceTag(String service) {
    // ... Bu metodun içeriği aynı kalıyor ...
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        service,
        style: AppFonts.bodySmall(color: AppColors.primaryColor)
            .copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Resim yüklenemediğinde gösterilecek yedek widget (Değişiklik yok)
  Widget _errorBuilder(BuildContext context, Object? error, StackTrace? stackTrace) {
    // ... Bu metodun içeriği aynı kalıyor ...
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: const Center(child: Icon(Icons.store, size: 50, color: AppColors.iconColor)),
    );
  }
}