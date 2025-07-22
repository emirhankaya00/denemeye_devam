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
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart';

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
  late TextEditingController _searchController; // Arama çubuğu için controller
  late FocusNode _searchFocusNode; // Arama çubuğu için focus node

  // Alt navigasyon barında gösterilecek ekranların listesi (5 ikonlu tasarıma göre ayarlandı)
  static final List<Widget> _pages = <Widget>[
    const DashboardScreen(), // Index 0
    const AppointmentsScreen(), // Index 1
    const SearchScreen(), // Index 2
    const FavoritesScreen(), // Index 3
    const ProfileScreen(), // Index 4
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
      _selectedIndex = index;
      _searchController.clear();
      _searchFocusNode.unfocus();
      Provider.of<SearchViewModel>(context, listen: false).toggleSearch(false);
    });
  }

  AppBar _buildDynamicAppBar(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    String titleText = '';
    bool showSearchField = false;
    bool showBackButton = false;
    VoidCallback? leadingAction;
    List<Widget>? actions;
    String? searchHint;

    switch (_selectedIndex) {
      case 0: // DashboardScreen
        titleText = 'Ana Sayfa';
        actions = [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _onItemTapped(2); // Arama sekmesine git
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                authViewModel.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.textColorDark),
                    const SizedBox(width: 8),
                    Text(
                      'Çıkış Yap',
                      style: AppFonts.bodyMedium(
                        color: AppColors.textColorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ];
        break;
      case 1: // AppointmentsScreen
        titleText = 'Randevularım';
        showSearchField = true;
        searchHint = 'Randevu ara...';
        showBackButton = true;
        leadingAction = () => _onItemTapped(0);
        break;
      case 2: // SearchScreen
        titleText = 'Ara';
        showSearchField = true;
        searchHint = 'Salon veya hizmet ara...';
        showBackButton = true;
        leadingAction = () => _onItemTapped(0);
        break;
      case 3: // FavoritesScreen
        titleText = 'Favorilerim';
        showSearchField = true;
        searchHint = 'Favorilerde ara...';
        showBackButton = true;
        leadingAction = () => _onItemTapped(0);
        break;
      case 4: // ProfileScreen
        titleText = 'Profilim';
        showSearchField = false;
        showBackButton = true;
        leadingAction = () => _onItemTapped(0);
        break;
    }

    // GÜNCELLENMİŞ APPBAR KODU BURADA
    return AppBar(
      elevation: 8, // Gölge efekti için elevation artırıldı
      toolbarHeight: 80.0,
      // AppBar'ın alt köşelerine yuvarlaklık veriyoruz
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25), // İstediğiniz yuvarlaklık değeri
        ),
      ),
      flexibleSpace: Container( // Gradient arka plan için Container eklendi
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor, // Gradientin başlangıç rengi
              AppColors.accentColor, // Gradientin bitiş rengi
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      leading: showBackButton
          ? IconButton(
        icon: Container(
          decoration: BoxDecoration(
            color: AppColors.textOnPrimary,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.arrow_back, color: AppColors.primaryColor, size: 20),
        ),
        onPressed: leadingAction,
      )
          : null,
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
          onTap: () {
            searchViewModel.toggleSearch(true);
          },
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
      actions: showSearchField ? const [SizedBox(width: 16.0)] : actions,
    );
  }

  // Özel olarak BottomNavigationBar item ikonlarını ve arka planını oluşturmak için yardımcı fonksiyon
  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    // İkonun boyutuna göre kare bir alan belirle
    final double iconSize = 24.0; // İkon boyutu
    final double padding = 6.0; // İç dolgu
    final double containerSize = iconSize + (padding * 2); // Konteyner boyutu (24 + 12 = 36)

    return Center(
      child: Container(
        width: containerSize, // Genişliği belirle
        height: containerSize, // Yüksekliği belirle
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0), // Köşelerin yuvarlak kalması için mevcut radius
          border: isSelected ? null : Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildDynamicAppBar(context),
      body: Stack(
        children: [
          // Sayfa içeriği
          IndexedStack(index: _selectedIndex, children: _pages),
          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 95.0,
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Align(
                  alignment: Alignment.center,
                  child: BottomNavigationBar(
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: _buildNavItem(Icons.auto_awesome_outlined, 0), // Makas yerine Parıltı ikonu
                        activeIcon: _buildNavItem(Icons.auto_awesome_outlined, 0),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(Icons.event_note_outlined, 1), // Takvim (notlu)
                        activeIcon: _buildNavItem(Icons.event_note_outlined, 1),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(Icons.search_outlined, 2), // Parıltı yerine Arama ikonu
                        activeIcon: _buildNavItem(Icons.search_outlined, 2),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(Icons.favorite_border, 3), // Favoriler
                        activeIcon: _buildNavItem(Icons.favorite, 3),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavItem(Icons.person_outline, 4), // Kişi ikonu
                        activeIcon: _buildNavItem(Icons.person_outline, 4),
                        label: '',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.transparent,
                    unselectedItemColor: Colors.transparent,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: AppColors.cardColor,
                    elevation: 0,
                    selectedLabelStyle: const TextStyle(fontSize: 0),
                    unselectedLabelStyle: const TextStyle(fontSize: 0),
                    iconSize: 24.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}