import 'package:denemeye_devam/view/screens/profile/profile_screen.dart';
import 'package:denemeye_devam/view/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ekran importları
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';
import '../view_models/auth_viewmodel.dart';
import '../view_models/search_viewmodel.dart';
import 'appointments/appointments_screen.dart';
import 'auth/home_page.dart';
import 'dashboard/dashboard_screen.dart';
import 'favorites/favorites_screen.dart';

/// Kullanıcının giriş durumuna göre `HomePage` veya `MainApp` gösteren yönlendirici.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    return authViewModel.user == null ? const HomePage() : const MainApp();
  }
}

/// Giriş yapıldıktan sonraki ana uygulama yapısı (AppBar ve BottomNavBar burada).
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const AppointmentsScreen(),
    const SearchScreen(), // Ortadaki ikon artık arama değil ama sayfa hala duruyor.
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchController.addListener(() {
      Provider.of<SearchViewModel>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Provider.of<SearchViewModel>(context, listen: false).toggleSearch(false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Arama ekranı artık 2. index'te değil, ana sayfadaki arama barından gidiliyor.
    // Eğer ortadaki butona basıldığında yine de arama sayfasına gidilmesi isteniyorsa
    // bu mantık değiştirilebilir. Şimdilik arama sayfasını 2. index'te tutuyorum.
    setState(() {
      if (_selectedIndex == 2 && index != 2) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        Provider.of<SearchViewModel>(context, listen: false).setSearchQuery('');
      }
      _selectedIndex = index;
    });
  }

  AppBar _buildDynamicAppBar(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final String userName = authViewModel.user?.userMetadata?['name'] ?? '';
    final String userSurname =
        authViewModel.user?.userMetadata?['surname'] ?? '';
    String fullName = '$userName $userSurname'.trim();

    if (fullName.isEmpty) {
      fullName = 'Iris';
    }

    if (_selectedIndex == 0) {
      return AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset(
              'assets/logos/2.png',
              height: 32,
            ),
            const SizedBox(width: 12),
            Text(
              fullName,
              style: AppFonts.poppinsBold(
                  fontSize: 20, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _onItemTapped(2);
            },
            child: Container(
              height: 40,
              width: 140,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search,
                      color: AppColors.textSecondary.withValues(alpha: 0.7), size: 20),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    String titleText = '';
    bool showSearchField = false;
    switch (_selectedIndex) {
      case 1:
        titleText = 'Randevularım';
        break;
      case 2:
        showSearchField = true;
        break;
      case 3:
        titleText = 'Favorilerim';
        break;
      case 4:
        titleText = 'Profilim';
        break;
    }

    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      title: showSearchField
          ? _buildSearchField()
          : Text(titleText,
          style: AppFonts.poppinsBold(
              color: AppColors.textPrimary, fontSize: 22)),
      actions: [
        if (_selectedIndex != 4 && _selectedIndex != 0)
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppColors.iconColor),
            onPressed: () => authViewModel.signOut(),
          )
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Salon, hizmet veya konum ara...',
        hintStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.iconColor),
        filled: true,
        fillColor: AppColors.borderColor.withValues(alpha: 0.5),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: AppFonts.bodyMedium(color: AppColors.textPrimary),
    );
  }

  // --- YENİ WIDGET: Süzülen Navigasyon Çubuğu ---
  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 0),
            _buildNavItem(Icons.calendar_today_outlined, 1),
            _buildNavItem(null, 2, isLogo: true), // Logo için özel durum
            _buildNavItem(Icons.favorite_border, 3),
            _buildNavItem(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  // --- YENİ WIDGET: Navigasyon Elemanı ---
  Widget _buildNavItem(IconData? icon, int index, {bool isLogo = false}) {
    bool isSelected = _selectedIndex == index;

    // Logo butonu için özel yapı
    if (isLogo) {
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/logos/3.png', // Beyaz logo
              width: 28,
              height: 28,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Diğer butonlar için genel yapı
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildDynamicAppBar(context),
      // --- DEĞİŞİKLİK: Scaffold'u bir Stack içine alıyoruz ---
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          _buildFloatingNavBar(), // Yeni navigasyon çubuğumuzu ekliyoruz
        ],
      ),
      // Eski bottomNavigationBar'ı kaldırıyoruz.
      // bottomNavigationBar: null,
    );
  }
}