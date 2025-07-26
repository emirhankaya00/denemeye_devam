import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../view_models/appointments_viewmodel.dart';
import '../../view_models/auth_viewmodel.dart';
import '../../view_models/favorites_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthViewModel, AppointmentsViewModel, FavoritesViewModel>(
      builder: (context, authViewModel, appointmentsViewModel, favoritesViewModel, child) {
        final user = authViewModel.user;
        final appointmentCount = appointmentsViewModel.allAppointments.length;
        final favoriteCount = favoritesViewModel.favoriteSaloons.length;
        final String userName = user?.userMetadata?['name'] ?? 'Misafir';
        final String userSurname = user?.userMetadata?['surname'] ?? 'Kullanıcı';
        final String fullName = '$userName $userSurname';

        return Scaffold(
          // 1. Arka plan rengi güncellendi
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 65,
                    // 2. Profil fotoğrafı arka planı güncellendi
                    backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primaryColor,
                      // 3. İkon rengi güncellendi
                      child: const Icon(Icons.person, size: 80, color: AppColors.textOnPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // 4. Metin renkleri güncellendi
                Text(fullName, style: AppFonts.poppinsBold(fontSize: 26, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(user?.email ?? 'E-posta adresi yok', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Profil düzenleme
                      },
                      // 5. Buton stil ve renkleri güncellendi
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Profili Düzenle', style: AppFonts.poppinsBold(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // İstatistik Kartı ve Liste Öğeleri
                _buildStatCard('Randevularım', Icons.calendar_today_outlined, '$appointmentCount Randevu'),
                _buildStatCard('Favorilerim', Icons.favorite_border, '$favoriteCount Salon'),
                _buildStatCard('Ayarlar', Icons.settings_outlined, 'Uygulama Ayarları'),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextButton.icon(
                    onPressed: () => authViewModel.signOut(),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: Text('Çıkış Yap', style: AppFonts.bodyMedium(color: Colors.red)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0)
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Yeni, daha basit ve şık liste görünümü için helper metot
  Widget _buildStatCard(String title, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primaryColor, size: 24),
          title: Text(title, style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
          subtitle: Text(subtitle, style: AppFonts.bodySmall(color: AppColors.textSecondary)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.iconColor),
          onTap: () {
            // TODO: İlgili sayfaya yönlendirme
          },
        ),
      ),
    );
  }
}