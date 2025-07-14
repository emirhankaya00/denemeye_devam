import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // AppFonts'u import ettiğinizden emin olun!
import 'package:denemeye_devam/features/common/widgets/salon_card.dart';
import 'package:provider/provider.dart'; // Provider paketi için
import 'package:denemeye_devam/viewmodels/search_viewmodel.dart'; // SearchViewModel eklendi

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // TextEditingController _searchController kaldırıldı, çünkü arama RootScreen'daki AppBar'dan yönetiliyor.
  List<Map<String, dynamic>> _searchResults = [];
  String? _selectedCategory;
  final List<String> _categories = ['Saç bakımı', 'Manikür', 'Cilt Bakımı', 'Masaj', 'Epilasyon', 'Makyaj'];

  final List<Map<String, dynamic>> _allSalons = [
    {'name': 'Mustafa Güzellik Salonu 1', 'rating': '4.5', 'services': ['Saç Kesimi', 'Manikür', 'Tırnak Bakımı', 'Makyaj'], 'hasCampaign': false, 'address': 'Örnek Cad. No:1', 'id': 's1'},
    {'name': 'Premium Salon 1', 'rating': '4.8', 'services': ['Spa', 'Masaj', 'Cilt Bakımı'], 'hasCampaign': false, 'address': 'Başka Sok. No:2', 'id': 's2'},
    {'name': 'Fırsat Salonu 1', 'rating': '4.2', 'services': ['İndirimli Kesim', 'Saç Bakımı'], 'hasCampaign': true, 'address': 'Kampanya Yolu No:3', 'id': 's3'},
    {'name': 'Deniz Kuaför', 'rating': '4.0', 'services': ['Saç Boyama', 'Saç Kesimi', 'Fön'], 'hasCampaign': false, 'address': 'Deniz Mah. No:4', 'id': 's4'},
    {'name': 'Yıldız Güzellik', 'rating': '4.6', 'services': ['Manikür', 'Pedikür', 'Epilasyon', 'Cilt Bakımı'], 'hasCampaign': false, 'address': 'Yıldız Sk. No:5', 'id': 's5'},
    {'name': 'Kampanyalı Saçlar', 'rating': '4.1', 'services': ['Fön', 'Özel Saç Bakımı', 'Saç Kesimi'], 'hasCampaign': true, 'address': 'İndirim Cad. No:6', 'id': 's6'},
  ];

  @override
  void initState() {
    super.initState();
    // _searchController.addListener(_onSearchChanged); // Kaldırıldı
    _searchResults = List.from(_allSalons); // Sayfa ilk açıldığında tüm salonları göster
  }

  @override
  void dispose() {
    // _searchController.removeListener(_onSearchChanged); // Kaldırıldı
    // _searchController.dispose(); // Kaldırıldı
    super.dispose();
  }

  // _onSearchChanged kaldırıldı
  // void _onSearchChanged() {
  //   _performSearch(_searchController.text);
  // }

  void _performSearch(String query) {
    setState(() {
      _searchResults = _allSalons.where((salon) {
        final String salonName = salon['name'].toLowerCase();
        final List<String> services = List<String>.from(salon['services']).map((s) => s.toLowerCase()).toList();
        final String lowerCaseQuery = query.toLowerCase();

        bool nameMatches = salonName.contains(lowerCaseQuery);
        bool serviceMatches = services.any((service) => service.contains(lowerCaseQuery));

        bool categoryMatches = true;
        if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
          // Kategori sadece seçili kategoriyi içeren hizmetleri olan salonları filtreleyecek
          categoryMatches = services.any((service) => service.contains(_selectedCategory!.toLowerCase()));
        }

        return (nameMatches || serviceMatches) && categoryMatches;
      }).toList();
    });
  }

  // _clearSearch kaldırıldı, çünkü arama RootScreen'daki AppBar'dan yönetiliyor.
  // void _clearSearch() {
  //   setState(() {
  //     _searchController.clear();
  //     _selectedCategory = null;
  //     _searchResults = List.from(_allSalons);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // SearchViewModel'ı dinleyerek arama sorgusunu alıyoruz
    final searchViewModel = context.watch<SearchViewModel>();

    // SearchViewModel'dan gelen sorguya göre filtreleme yap
    _performSearch(searchViewModel.searchQuery);

    return Scaffold(
      backgroundColor: AppColors.accentColor, // Ekranın genel arka plan rengi
      // AppBar kaldırıldı, artık RootScreen'daki MainApp yönetecek.
      body: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Kategoriler',
                style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                          // Kategori değiştiğinde de arama yap
                          _performSearch(searchViewModel.searchQuery);
                        });
                      },
                      selectedColor: AppColors.accentColor,
                      backgroundColor: AppColors.tagColorPassive,
                      labelStyle: AppFonts.bodyMedium(
                        color: isSelected ? Colors.white : AppColors.textColorDark,
                      ).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.accentColor : AppColors.dividerColor.withOpacity(0.5), // withValues yerine withOpacity kullanıldı
                        ),
                      ),
                      elevation: isSelected ? 3 : 1,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _searchResults.isEmpty && (searchViewModel.searchQuery.isNotEmpty || _selectedCategory != null)
                  ? _buildNoResultsFound(searchViewModel.searchQuery.isNotEmpty)
                  : _buildSearchResultsList(),
            ),
            // Bottom Nav Bar zaten RootScreen'da yönetiliyor!
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsFound(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textColorLight.withOpacity(0.5)), // withValues yerine withOpacity kullanıldı
          const SizedBox(height: 20),
          Text(
            isSearching ? 'Arama sonucunuz bulunamadı.' : 'Salon bulunamadı.',
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight.withOpacity(0.8)), // withValues yerine withOpacity kullanıldı
          ),
          Text(
            'Farklı bir kelime veya kategoriyle arama yapmayı deneyin.',
            style: AppFonts.bodyMedium(color: AppColors.textColorLight.withOpacity(0.6)), // withValues yerine withOpacity kullanıldı
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> salonData = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SalonCard(
            salonId: salonData['id'] ?? '',
            name: salonData['name'],
            rating: salonData['rating'],
            services: List<String>.from(salonData['services']),
            hasCampaign: salonData['hasCampaign'],
            // imagePath: 'lib/assets/salon_placeholder.png', // Eğer imagePath'iniz sabitse veya modelden gelmiyorsa
          ),
        );
      },
    );
  }
}