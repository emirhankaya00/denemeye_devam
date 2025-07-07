import 'package:flutter/material.dart';
import 'package:denemeye_devam/app_colors.dart'; // AppColors sınıfını import ettik
import 'package:denemeye_devam/app_fonts.dart';   // AppFonts sınıfını import ettik
import 'package:denemeye_devam/screens/home_page.dart'; // Login ekranı, logout için
import 'package:denemeye_devam/screens/search_screen.dart'; // Arama sayfası
import 'package:denemeye_devam/screens/appointments_screen.dart'; // Randevu sayfası
import 'package:denemeye_devam/screens/lib/screens/favorites_screen.dart'; // Favoriler sayfası (yeni!)
// Diğer ekranlarınız (örneğin profil sayfası)



import 'package:denemeye_devam/widgets/salon_card.dart';

import 'favorites_screen.dart';
// Salon Detay sayfanız eğer ana root içinde değilse (önceki kodda lib/screens/lib/salon_detail_screen.dart gibiydi, yolu düzeltildi)
// import 'package:denemeye_devam/screens/salon_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Seçili olan BottomNavigationBar öğesinin indeksi

  late final List<Widget> _pages; // BottomNavigationBar'a bağlı sayfalar

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      // 0. İndeks: Ana Sayfa İçeriği (DashboardContent)
      // Bu sayfa kendi içinde Arama ekranına geçiş yapabilir
      _DashboardContent(
        onSearchTap: () {
          setState(() {
            _selectedIndex = 2; // Arama ikonunun indeksi
          });
        },
      ),
      // 1. İndeks: Randevular Sayfası
      const AppointmentsScreen(),
      // 2. İndeks: Arama Sayfası
      const SearchScreen(),
      // 3. İndeks: Favoriler Sayfası (Görseldeki gibi dizayn edilmiş halini kullandık!)
      const FavoritesScreen(),
      // 4. İndeks: Profil Sayfası (Geçici olarak Text widget'ı)
      Center(
        child: Text(
          'Profil Sayfası',
          style: AppFonts.poppinsBold(fontSize: 24, color: AppColors.textColorDark),
        ),
      ),
    ];
  }

  // BottomNavigationBar öğesine tıklandığında çağrılır
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar bu ekranın genelinde kullanılmayacak, her sayfa kendi AppBar'ını yönetecek (Favoriler gibi)
      // Bu sayede DashboardContent'teki özel arama çubuğu ve menü de yerinde kalır.

      body: Stack(
        children: [
          // Arka plan gradyanı
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundColorLight,
                  AppColors.backgroundColorDark,
                ],
              ),
            ),
          ),
          // Seçili olan sayfayı göster
          IndexedStack( // Sayfaların durumunu korur ve daha akıcı geçişler sağlar
            index: _selectedIndex,
            children: _pages,
          ),
        ],
      ),

      // Alt navigasyon çubuğu
    );
  }
}

// Dashboard'ın Ana İçerik Bölümü (_DashboardContent)
// Bu kısım, BottomNavigationBar'ın ilk sekmesine karşılık gelir.
class _DashboardContent extends StatelessWidget {
  final VoidCallback onSearchTap;

  const _DashboardContent({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Üst Kısım: Arama Çubuğu ve Ayarlar Menüsü
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16, bottom: 10),
          color: AppColors.primaryColor, // Senin ana rengin
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onSearchTap, // Arama çubuğuna tıklayınca arama sayfasına geçiş
                  child: Container(
                    height: 45, // Arama çubuğu yüksekliği (görselle uyumlu)
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor, // Beyaz arama çubuğu
                      borderRadius: BorderRadius.circular(30), // Tam yuvarlak köşeler
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row( // TextField yerine Row içinde ikon ve metin göster
                      children: [
                        Icon(Icons.search, color: AppColors.textColorLight),
                        const SizedBox(width: 8),
                        Text(
                          'Ara...',
                          style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (String value) {
                  if (value == 'logout') {
                    // Çıkış yap ve login sayfasına dön
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                          (Route<dynamic> route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Başarıyla çıkış yapıldı.')),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppColors.textColorDark),
                        const SizedBox(width: 8),
                        Text(
                          'Çıkış Yap',
                          style: AppFonts.bodyMedium(color: AppColors.textColorDark), // Font stilini kullandık
                        ),
                      ],
                    ),
                  ),
                ],
                color: AppColors.cardColor, // Pop-up menünün arka plan rengi
              ),
            ],
          ),
        ),

        // Kalan İçerik: Harita, Salon Listeleri
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Harita Placeholder
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'lib/assets/map_placeholder.png', // Harita görsel yolu
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: AppColors.backgroundColorDark,
                        child: Center(
                            child: Text(
                              'Harita Yüklenemedi',
                              style: AppFonts.bodyMedium(color: AppColors.textColorLight), // Font stilini kullandık
                            )),
                      ),
                    ),
                  ),
                ),
                // Yakınlarda bulunan salonlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Yakınlarda bulunan salonlar',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark), // Font stilini kullandık
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 5, // Örnek veri sayısı
                    itemBuilder: (context, index) {
                      return SalonCard(
                        name: 'Mustafa Güzellik Salonu ${index + 1}',
                        rating: '4.5',
                        services: const ['Saç Kesimi', 'Manikür'],
                        // imagePath: 'lib/assets/salon_placeholder.png', // Eğer resim yolun varsa ekleyebilirsin
                      );
                    },
                  ),
                ),
                // Ayırıcı Çizgi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Divider(color: AppColors.dividerColor, thickness: 1),
                ),
                // En yüksek puanlı salonlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'En yüksek puanlı salonlar',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark), // Font stilini kullandık
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return SalonCard(
                        name: 'Premium Salon ${index + 1}',
                        rating: '4.8',
                        services: const ['Spa', 'Masaj'],
                      );
                    },
                  ),
                ),
                // Ayırıcı Çizgi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Divider(color: AppColors.dividerColor, thickness: 1),
                ),
                // Kampanyadaki salonlar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Kampanyadaki salonlar',
                    style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark), // Font stilini kullandık
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return SalonCard(
                        name: 'Fırsat Salonu ${index + 1}',
                        rating: '4.2',
                        services: const ['İndirimli Kesim'],
                        hasCampaign: true,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}