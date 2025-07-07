// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:denemeye_devam/app_colors.dart'; // Renkler için
import 'package:denemeye_devam/app_fonts.dart';   // Fontlar için

// Eğer favori salon için bir modelin varsa onu import et
// import 'package:denemeye_devam/data/models/salon.dart';

// FavoriteSalonCard sınıfı BURADA TANIMLI!
class FavoriteSalonCard extends StatelessWidget {
  final String name;
  final String description; // "Randevu İçin", "Şimdi Dokun" gibi metin
  final String rating;
  final String? imageUrl; // Salon resmi URL'si
  final VoidCallback onRemoveFavorite; // Favoriden çıkarma callback'i
  final VoidCallback onBookAppointment; // Randevu al/İletişim kur callback'i

  const FavoriteSalonCard({
    Key? key,
    required this.name,
    required this.description,
    required this.rating,
    this.imageUrl,
    required this.onRemoveFavorite,
    required this.onBookAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol Kısım: Resim veya Placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80, // Görseldeki gibi daha büyük bir kare resim alanı
                height: 80,
                color: AppColors.backgroundColorDark, // Gri placeholder
                child: Center(
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.store, size: 40, color: AppColors.iconColor), // Hata durumunda ikon
                  )
                      : Icon(Icons.store, size: 40, color: AppColors.iconColor), // Resim yoksa ikon
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Orta Kısım: Metinler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textColorDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppFonts.bodySmall(color: AppColors.textColorLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.starColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sağ Kısım: Aksiyonlar (Dolu Kalp ve Buton)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Butonları dikeyde yay
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onRemoveFavorite,
                  child: Icon(
                    Icons.favorite, // Dolu kalp ikonu
                    color: AppColors.accentColor, // Canlı pembe/kırmızı
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20), // Görseldeki boşluğu yakalamak için
                SizedBox(
                  height: 35, // Buton yüksekliği
                  child: ElevatedButton(
                    onPressed: onBookAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor, // Kırmızı buton
                      foregroundColor: AppColors.textOnPrimary, // Beyaz metin
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Yuvarlak köşeler
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), // İç boşluk
                      minimumSize: const Size(0, 0), // Kendi boyutunu almasını sağlar
                    ),
                    child: Text(
                      'Randevu Al /\nİletişim Kur', // Çift satır metin
                      textAlign: TextAlign.center,
                      style: AppFonts.bodySmall(color: AppColors.textOnPrimary), // Küçük ve beyaz metin
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Ana Favoriler Sayfası
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Mock Favori Verileri (Gerçek veriyi burada API'dan çekeceksin)
  final List<Map<String, dynamic>> _favoriteSalons = [
    {
      'id': '1',
      'name': 'Mustafa Güzellik Salonu',
      'description': 'Randevu İçin Şimdi Dokun',
      'rating': '4.8 (89 yorum)',
      'imageUrl': 'https://via.placeholder.com/150/FF6347/FFFFFF?text=Salon1', // Örnek resim
    },
    {
      'id': '2',
      'name': 'Deniz Kuaför ve Güzellik',
      'description': 'Hemen Randevu Oluştur',
      'rating': '4.5 (124 yorum)',
      'imageUrl': 'https://via.placeholder.com/150/4682B4/FFFFFF?text=Salon2',
    },
    {
      'id': '3',
      'name': 'Elit Saç & Bakım',
      'description': 'Bugüne Özel Fırsatlar',
      'rating': '4.9 (210 yorum)',
      'imageUrl': 'https://via.placeholder.com/150/32CD32/FFFFFF?text=Salon3',
    },
    {
      'id': '4',
      'name': 'Ayşe\'nin Tırnak Stüdyosu',
      'description': 'Son Boş Yerler!',
      'rating': '4.7 (75 yorum)',
      'imageUrl': 'https://via.placeholder.com/150/FFD700/FFFFFF?text=Salon4',
    },
  ];

  void _removeFavorite(String id) {
    setState(() {
      _favoriteSalons.removeWhere((salon) => salon['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorilerden başarıyla kaldırıldı.')),
    );
  }

  void _bookAppointment(String salonName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$salonName için randevu/iletişim ekranına yönlendiriliyorsunuz.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textFieldFillColor, // Set the background color of the whole screen to red/pink
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // AppBar background color to match the design
        elevation: 0, // No shadow
        toolbarHeight: 80.0, // Adjust height if needed
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary, // White background for the back button
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0), // Padding inside the white circle
            child: Icon(
              Icons.arrow_back,
              color: AppColors.primaryColor, // Back arrow color (e.g., dark red/pink)
              size: 20,
            ),
          ),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0, // Remove default spacing to fit content tightly
        title: Container(
          height: 48.0, // Height of the search bar
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Rounded corners for search bar
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Randevu ara...',
              hintStyle: AppFonts.bodyMedium(color: AppColors.textColorLight),
              prefixIcon: Icon(Icons.search, color: AppColors.textColorLight),
              border: InputBorder.none, // Remove default border
              contentPadding: EdgeInsets.symmetric(vertical: 12.0), // Adjust text vertical alignment
            ),
            style: AppFonts.bodyMedium(color: AppColors.textColorDark),
          ),
        ),
        actions: [
          // You can add more actions here if needed, like a filter icon
          const SizedBox(width: 16.0), // Add some spacing on the right
        ],
      ),
      body: _favoriteSalons.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.iconColor.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz favori salonunuz yok.',
              style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight),
            ),
            const SizedBox(height: 10),
            Text(
              'Beğendiğiniz salonları favorilerinize ekleyin ve tekrar ziyaret edin!',
              textAlign: TextAlign.center,
              style: AppFonts.bodyMedium(color: AppColors.textColorLight),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: Text('Keşfetmeye Başla', style: AppFonts.poppinsBold(color: AppColors.textOnPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textFieldFillColor,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _favoriteSalons.length,
        itemBuilder: (context, index) {
          final salon = _favoriteSalons[index];
          return FavoriteSalonCard(
            name: salon['name'],
            description: salon['description'],
            rating: salon['rating'],
            imageUrl: salon['imageUrl'],
            onRemoveFavorite: () => _removeFavorite(salon['id']),
            onBookAppointment: () => _bookAppointment(salon['name']),
          );
        },
      ),
    );
  }
}