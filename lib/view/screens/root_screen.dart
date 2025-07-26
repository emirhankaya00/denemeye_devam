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
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _searchController.addListener(() {
      Provider.of<SearchViewModel>(context, listen: false).setSearchQuery(_searchController.text);
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
    setState(() {
      // Arama ekranından başka bir ekrana geçildiğinde aramayı temizle
      if (_selectedIndex == 2 && index != 2) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        Provider.of<SearchViewModel>(context, listen: false).setSearchQuery('');
      }
      _selectedIndex = index;
    });
  }

  // YENİ TASARIMA UYGUN APPBAR
  AppBar _buildDynamicAppBar(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    String titleText = '';
    bool showSearchField = false;

    // Sayfa başlıklarını belirle
    switch (_selectedIndex) {
      case 0:
        titleText = 'Ana Sayfa';
        break;
      case 1:
        titleText = 'Randevularım';
        break;
      case 2: // Arama ekranında başlık yerine arama çubuğu gelecek
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
      // 1. AppBar Renkleri ve Stili Güncellendi
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0, // Altındaki çizgi için elevation yerine Border kullanacağız
      title: showSearchField
          ? _buildSearchField() // Arama çubuğu
          : Text(titleText, style: AppFonts.poppinsBold(color: AppColors.textPrimary, fontSize: 22)),
      actions: [
        // Profil ekranı hariç diğerlerinde çıkış butonu göster
        if (_selectedIndex != 4)
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppColors.iconColor),
            onPressed: () => authViewModel.signOut(),
          )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        // 2. AppBar altına ayırıcı çizgi eklendi
        child: Container(color: AppColors.borderColor, height: 1.0),
      ),
    );
  }

  // Arama çubuğu widget'ı
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true, // Arama ekranına gelince klavye direkt açılsın
      decoration: InputDecoration(
        hintText: 'Salon, hizmet veya konum ara...',
        hintStyle: AppFonts.bodyMedium(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.iconColor),
        // 3. Arama çubuğu renkleri ve stili güncellendi
        filled: true,
        fillColor: AppColors.borderColor.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: AppFonts.bodyMedium(color: AppColors.textPrimary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildDynamicAppBar(context),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // 4. BottomNavigationBar tamamen yenilendi
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          _buildNavItem(Icons.home_filled, 'Ana Sayfa', 0),
          _buildNavItem(Icons.event_note, 'Randevular', 1),
          _buildNavItem(Icons.search, 'Ara', 2),
          _buildNavItem(Icons.favorite, 'Favoriler', 3),
          _buildNavItem(Icons.person, 'Profil', 4),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        elevation: 0,
        // 5. Seçili ve seçili olmayan item renkleri güncellendi
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.iconColor,
        selectedLabelStyle: AppFonts.bodySmall(),
        unselectedLabelStyle: AppFonts.bodySmall(),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  // Yeni BottomNavigationBar item'larını oluşturan helper metot
  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}