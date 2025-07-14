// lib/screens/root_screen.dart
import 'package:denemeye_devam/features/auth/screens/home_page.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';

// Ekran importları
import 'package:denemeye_devam/screens/dashboard_screen.dart';
import 'package:denemeye_devam/features/appointments/screens/appointments_screen.dart';
import 'package:denemeye_devam/screens/search_screen.dart';
import 'package:denemeye_devam/screens/favorites_screen.dart';
import 'package:denemeye_devam/screens/profile_screen.dart';

/// Bu widget artık bir yönlendirici (router) görevi görüyor.
/// Tek işi, kullanıcının giriş durumunu dinleyip doğru ekranı göstermek.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthViewModel'daki değişiklikleri dinle ve kullanıcı durumunu al.
    final authViewModel = context.watch<AuthViewModel>();

    // Eğer kullanıcı giriş yapmamışsa (user null ise) HomePage'i göster.
    // Giriş yapmışsa, ana uygulama yapısını (MainApp) göster.
    return authViewModel.user == null ? const HomePage() : const MainApp();
  }
}

/// Bu widget, kullanıcı giriş yaptıktan sonra gösterilen ana uygulama yapısını içerir.
/// BottomNavigationBar ve sayfa yönetimi burada yapılır.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  // Alt navigasyon barında gösterilecek ekranların listesi
  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const AppointmentsScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        selectedItemColor: AppColors.textOnPrimary,
        unselectedItemColor: AppColors.textOnPrimary.withOpacity(0.7),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryColor,
        elevation: 10,
        selectedLabelStyle: AppFonts.bodySmall(color: AppColors.textOnPrimary),
        unselectedLabelStyle: AppFonts.bodySmall(
          color: AppColors.textOnPrimary.withOpacity(0.7),
        ),
      ),
    );
  }
}
