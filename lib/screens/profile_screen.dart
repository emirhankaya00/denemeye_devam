// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart'; // Senin renk tanımların
import 'package:denemeye_devam/core/app_fonts.dart';   // Senin font tanımların

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorLight, // Görseldeki açık gri arka plan
      // AppBar'ı buradan kaldırdık. Artık RootScreen'daki MainApp yönetecek.
      body: SingleChildScrollView( // İçerik uzun olursa kaydırılabilir olsun diye
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Genel boşluk
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Tüm içeriği yatayda ortala
            children: [
              // Profil Resmi ve Arka Planı
              Center( // Profil resmini yatayda ortalamak için Center
                child: Container(
                  width: 130, // Profil resmi boyutu (görselle uyumlu)
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor, // Kırmızı arka plan
                    border: Border.all(color: Colors.white, width: 5), // Beyaz çerçeve (daha belirgin)
                    boxShadow: [ // Hafif bir gölge
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15), // withValues yerine withOpacity kullanıldı
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 85, // İkon boyutu
                    color: Colors.white, // Beyaz ikon
                  ),
                ),
              ),
              const SizedBox(height: 25), // Profil resmi ile isim arasında boşluk
              // İsim
              Text(
                'Emirhan Kaya', // Buraya dinamik olarak kullanıcı adı gelecek
                style: AppFonts.poppinsBold(fontSize: 26, color: AppColors.textColorDark), // Kalın ve belirgin
              ),
              const SizedBox(height: 8), // İsim ile telefon arasında boşluk
              // Telefon Numarası
              Text(
                '555 555 55 55', // Buraya dinamik olarak telefon numarası gelecek
                style: AppFonts.bodyMedium(color: AppColors.textColorLight), // Daha küçük ve açık gri
              ),
              const SizedBox(height: 30), // Telefon ile buton arasında boşluk
              // Profili Düzenle Butonu
              SizedBox(
                width: 220, // Buton genişliği (görselle uyumlu)
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Profil düzenleme sayfasına yönlendirme veya dialog açma
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profili Düzenleme Ekranına Git')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor, // Canlı pembe/kırmızı buton rengi
                    foregroundColor: AppColors.textOnPrimary, // Beyaz metin
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Daha yuvarlak köşeler
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14), // Dikey padding
                    elevation: 6, // Biraz daha belirgin gölge
                  ),
                  child: Text(
                    'Profili düzenle',
                    style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textOnPrimary), // Kalın ve beyaz metin
                  ),
                ),
              ),
              const SizedBox(height: 40), // Buton ile kart arasında boşluk
              // İstatistik Kartı
              Card(
                color: AppColors.cardColor, // Beyaz kart
                elevation: 5, // Hafif gölge
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Yuvarlak köşeler
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0), // Kart içi boşluk
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Metinleri sola hizala
                    children: [
                      Text(
                        'Toplam randevu sayısı : 12', // Dinamik veri gelecek
                        style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                      ),
                      const SizedBox(height: 12), // Satırlar arası boşluk
                      Text(
                        'Favori salon sayısı : 12', // Dinamik veri gelecek
                        style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                      ),
                      const SizedBox(height: 12), // Satırlar arası boşluk
                      Text(
                        'İstatistikler ve ileride sadakat puanları', // Dinamik veri gelecek
                        style: AppFonts.bodyMedium(color: AppColors.textColorDark),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20), // Ekranın en altına doğru boşluk
            ],
          ),
        ),
      ),
    );
  }
}