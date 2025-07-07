// lib/screens/root_screen.dart

import 'package:flutter/material.dart';
import 'package:denemeye_devam/app_colors.dart'; // Renkler için
import 'package:denemeye_devam/app_fonts.dart';   // Fontlar için

// Ekran importları - YOLLAR DÜZELTİLDİ VE PROFİL EKLENDİ!
import 'package:denemeye_devam/screens/lib/screens/dashboard_screen.dart'; // Doğru yol
import 'package:denemeye_devam/screens/appointments_screen.dart'; // Doğru yol
import 'package:denemeye_devam/screens/search_screen.dart'; // Doğru yol
import 'package:denemeye_devam/screens/lib/screens/favorites_screen.dart'; // Doğru yol
import 'package:denemeye_devam/screens/profile_screen.dart'; // <-- PROFİL SAYFASINI BURAYA EKLEDİK VE YOLU DÜZELTTİK!

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // Varsayılan olarak ilk sekme seçili

  // Alt navigasyon barında gösterilecek ekranların listesi
  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const AppointmentsScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(), // <-- PROFİL SAYFASI ARTIK AKTİF!
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        // Seçili ve seçili olmayan öğelerin (ikon + metin) renkleri beyaz/hafif opak beyaz
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: AppColors.textOnPrimary.withOpacity(0.7),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryColor, // Barın arka plan rengi
        elevation: 10, // Gölge efekti
        // Label stilleri de artık beyaz rengi kullanacak
        selectedLabelStyle: AppFonts.bodySmall(color: AppColors.textOnPrimary),
        unselectedLabelStyle: AppFonts.bodySmall(color: AppColors.textOnPrimary.withOpacity(0.7)),
      ),
    );
  }
}