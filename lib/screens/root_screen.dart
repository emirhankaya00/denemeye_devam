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
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart'; // YENİ: SearchViewModel import edildi
import 'package:denemeye_devam/viewmodels/favorites_viewmodel.dart'; // Favoriler ViewModel
// Eğer Randevular için de bir ViewModel oluşturursanız, onu da buraya import edin.
// import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';

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

  // Alt navigasyon barında gösterilecek ekranların listesi
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

    // Arama sorgusu değiştikçe SearchViewModel'ı güncelle
    _searchController.addListener(() {
      Provider.of<SearchViewModel>(context, listen: false).setSearchQuery(_searchController.text);
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Arama çubuğu odağı kaybettiğinde, arama modunu kapat.
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
      // Yeni bir sekmeye geçildiğinde arama modunu ve sorguyu sıfırla
      _searchController.clear();
      _searchFocusNode.unfocus();
      Provider.of<SearchViewModel>(context, listen: false).toggleSearch(false);
    });
  }

  // Dinamik AppBar oluşturma metodu
  AppBar _buildDynamicAppBar(BuildContext context) {
    final searchViewModel = context.watch<SearchViewModel>(); // SearchViewModel'ı dinle
    final authViewModel = context.watch<AuthViewModel>(); // AuthViewModel'ı dinle (logout için)

    String titleText = '';
    bool showSearchField = false;
    bool showBackButton = false;
    VoidCallback? leadingAction;
    List<Widget>? actions;
    String? searchHint;

    switch (_selectedIndex) {
      case 0: // DashboardScreen (Ana Sayfa)
        titleText = 'Ana Sayfa';
        // Dashboard'da arama çubuğu yerine arama ikonu veya boş bırakabiliriz
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
      case 1: // AppointmentsScreen (Randevularım)
        titleText = 'Randevularım';
        showSearchField = true;
        searchHint = 'Randevu ara...';
        showBackButton = true; // Dashboard'a dönmek için geri tuşu
        leadingAction = () => _onItemTapped(0); // YENİ: Dashboard'a dön
        break;
      case 2: // SearchScreen (Ara)
        titleText = 'Ara';
        showSearchField = true;
        searchHint = 'Salon veya hizmet ara...';
        showBackButton = true; // Dashboard'a dönmek için geri tuşu
        leadingAction = () => _onItemTapped(0); // YENİ: Dashboard'a dön
        break;
      case 3: // FavoritesScreen (Favorilerim)
        titleText = 'Favorilerim';
        showSearchField = true;
        searchHint = 'Favorilerde ara...';
        showBackButton = true; // Dashboard'a dönmek için geri tuşu
        leadingAction = () => _onItemTapped(0); // YENİ: Dashboard'a dön
        break;
      case 4: // ProfileScreen (Profilim)
        titleText = 'Profilim';
        showSearchField = false;
        showBackButton = true; // Dashboard'a dönmek için geri tuşu
        leadingAction = () => _onItemTapped(0); // YENİ: Dashboard'a dön
        break;
    }

    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      toolbarHeight: 80.0,
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
          : null, // Geri tuşu yoksa boş bırak
      titleSpacing: showSearchField ? 0 : null, // Arama çubuğu varsa boşluğu kaldır
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
            // Arama çubuğuna tıklandığında arama modunu aç
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
                searchViewModel.setSearchQuery(''); // Sorguyu temizle
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
      actions: showSearchField ? const [SizedBox(width: 16.0)] : actions, // Arama çubuğu varsa boşluk bırak, yoksa actions'ları göster
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildDynamicAppBar(context), // Dinamik AppBar burada!
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
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
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