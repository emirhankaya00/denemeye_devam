import 'package:denemeye_devam/features/auth/screens/home_page.dart';
import 'package:denemeye_devam/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart';

// Ekran importları
import 'package:denemeye_devam/features/appointments/screens/appointments_screen.dart';
import 'package:denemeye_devam/screens/search_screen.dart';
import 'package:denemeye_devam/screens/favorites_screen.dart';
import 'package:denemeye_devam/screens/profile_screen.dart';
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

// Bildirimler ekranı importu
import 'notifications_screen.dart';

import 'dashboard_screen.dart';

/// Bu widget artık bir yönlendirici (router) görevi görüyor.
/// Tek işi, kullanıcının giriş durumunu dinleyip doğru ekranı göstermek.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
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
      Provider.of<SearchViewModel>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        Provider.of<SearchViewModel>(context, listen: false)
            .toggleSearch(false);
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
      _selectedIndex = index;
      if (index != 2) {
        _searchController.clear();
        _searchFocusNode.unfocus();
        Provider.of<SearchViewModel>(context, listen: false).toggleSearch(false);
      }
    });
  }

  AppBar _buildDynamicAppBar(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    switch (_selectedIndex) {
      case 0: // DashboardScreen (Ana Sayfa) için AppBar tasarımı
        final user = authViewModel.user;
        final String userName = user?.userMetadata?['name'] ?? 'Kullanıcı';
        final String userSurname = user?.userMetadata?['surname'] ?? '';
        final String fullName = '$userName $userSurname'.trim();

        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0.0,
          shape: Border(
            bottom: BorderSide(
              color: AppColors.dividerColor,
              width: 1,
            ),
          ),
          toolbarHeight: 80.0,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => _onItemTapped(4),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person_outline,
                    size: 28,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  fullName,
                  style: AppFonts.h5SemiBold(color: AppColors.textColorDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: Container(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Salon ara...',
                            style: AppFonts.bodyMedium(color: AppColors.textColorLight),
                          ),
                        ),
                        Icon(Icons.tune, color: AppColors.textColorLight),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none_outlined, color: AppColors.primaryColor, size: 30),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        );

      case 1:
        return _buildStandardAppBar(
          context,
          titleText: 'Randevularım',
          searchHint: 'Randevu ara...',
          leadingAction: () => _onItemTapped(0),
        );
      case 2:
        return _buildStandardAppBar(
          context,
          titleText: 'Ara',
          searchHint: 'Salon veya hizmet ara...',
          leadingAction: () => _onItemTapped(0),
        );
      case 3:
        return _buildStandardAppBar(
          context,
          titleText: 'Favorilerim',
          searchHint: 'Favorilerde ara...',
          leadingAction: () => _onItemTapped(0),
        );
      case 4:
        return _buildStandardAppBar(
          context,
          titleText: 'Profilim',
          showSearchField: false,
          leadingAction: () => _onItemTapped(0),
        );
      default:
        return AppBar();
    }
  }

  AppBar _buildStandardAppBar(BuildContext context, {
    required String titleText,
    String? searchHint,
    bool showSearchField = true,
    required VoidCallback leadingAction,
  }) {
    final searchViewModel = context.watch<SearchViewModel>();

    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      toolbarHeight: 80.0,
      leading: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.arrow_back, color: AppColors.primaryColor, size: 20),
        ),
        onPressed: leadingAction,
      ),
      titleSpacing: showSearchField ? 0 : null,
      title: showSearchField
          ? Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onTap: () => searchViewModel.toggleSearch(true),
          decoration: InputDecoration(
            hintText: searchHint,
            hintStyle: AppFonts.bodyMedium(color: AppColors.textColorLight),
            prefixIcon: Icon(Icons.search, color: AppColors.textColorLight),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear, color: AppColors.textColorLight),
              onPressed: () {
                _searchController.clear();
                searchViewModel.setSearchQuery('');
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          style: AppFonts.bodyMedium(color: AppColors.textColorDark),
        ),
      )
          : Text(
        titleText,
        style: AppFonts.poppinsBold(fontSize: 20, color: AppColors.textOnPrimary),
      ),
      actions: showSearchField ? const [SizedBox(width: 16.0)] : null,
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.25) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 24, // Ekranın altından boşluk
      left: 35,   // Ekranın solundan boşluk
      right: 35,  // Ekranın sağından boşluk
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Ortadaki butonun dışarı taşmasına izin ver
        children: [
          // Mavi arkaplan barı
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.home_outlined, index: 0),
                _buildNavItem(icon: Icons.calendar_today_outlined, index: 1),
                const SizedBox(width: 56), // Ortadaki buton için boşluk
                _buildNavItem(icon: Icons.favorite_border, index: 3),
                _buildNavItem(icon: Icons.person_outline, index: 4),
              ],
            ),
          ),
          // Ortadaki logo butonu
          Positioned(
            top: -20, // Butonun yukarıdan ne kadar taşacağını belirler
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  // Beyaz, yuvarlak arkaplan
                  shape: BoxShape.circle,
                  color: Colors.white,
                  // Yüzen efekt için gölge
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4)
                    ),
                  ],
                ),
                // Logonun kendisi artık Container'ın içinde
                child: Center(
                  child: Image.asset(
                    'assets/iris_logo.jpg', // JPG dosyanızın yolu
                    width: 36, // Logoyu daireden biraz daha küçük yapıyoruz
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildDynamicAppBar(context),
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _pages),
          _buildFloatingNavBar(),
        ],
      ),
    );
  }
}