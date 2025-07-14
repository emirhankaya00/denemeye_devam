import 'package:flutter/material.dart';
import 'package:denemeye_devam/core/app_colors.dart';
import 'package:denemeye_devam/core/app_fonts.dart'; // AppFonts'u import ettiğinizden emin olun!
import 'package:denemeye_devam/features/common/widgets/salon_card.dart';
// import 'package:denemeye_devam/screens/salon_detail_screen.dart'; // Bu import'a burada ihtiyaç yok, sadece Dashboard'dan geçiyoruz

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String? _selectedCategory;
  final List<String> _categories = ['Saç bakımı', 'Manikür', 'Cilt Bakımı', 'Masaj', 'Epilasyon', 'Makyaj'];

  final List<Map<String, dynamic>> _allSalons = [
    {'name': 'Mustafa Güzellik Salonu 1', 'rating': '4.5', 'services': ['Saç Kesimi', 'Manikür', 'Tırnak Bakımı', 'Makyaj'], 'hasCampaign': false, 'address': 'Örnek Cad. No:1'},
    {'name': 'Premium Salon 1', 'rating': '4.8', 'services': ['Spa', 'Masaj', 'Cilt Bakımı'], 'hasCampaign': false, 'address': 'Başka Sok. No:2'},
    {'name': 'Fırsat Salonu 1', 'rating': '4.2', 'services': ['İndirimli Kesim', 'Saç Bakımı'], 'hasCampaign': true, 'address': 'Kampanya Yolu No:3'},
    {'name': 'Deniz Kuaför', 'rating': '4.0', 'services': ['Saç Boyama', 'Saç Kesimi', 'Fön'], 'hasCampaign': false, 'address': 'Deniz Mah. No:4'},
    {'name': 'Yıldız Güzellik', 'rating': '4.6', 'services': ['Manikür', 'Pedikür', 'Epilasyon', 'Cilt Bakımı'], 'hasCampaign': false, 'address': 'Yıldız Sk. No:5'},
    {'name': 'Kampanyalı Saçlar', 'rating': '4.1', 'services': ['Fön', 'Özel Saç Bakımı', 'Saç Kesimi'], 'hasCampaign': true, 'address': 'İndirim Cad. No:6'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchResults = List.from(_allSalons); // Sayfa ilk açıldığında tüm salonları göster
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor, // Ekranın genel arka plan rengi AppBar ile uyumlu olsun
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor, // AppBar arka plan rengi
        elevation: 0, // Gölge yok
        toolbarHeight: 80.0, // Yüksekliği ayarla
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary, // Beyaz arka plan
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4.0), // Beyaz çemberin içi için boşluk
            child: Icon(
              Icons.arrow_back,
              color: AppColors.primaryColor, // Geri ok rengi (kırmızıya yakın)
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.pop(context); // Geri tuşu işlevi
          },
        ),
        titleSpacing: 0, // Leading ile title arasındaki varsayılan boşluğu kaldır
        title: Container(
          height: 48.0, // Arama çubuğunun yüksekliği
          margin: const EdgeInsets.only(right: 16.0), // Sağdan boşluk bırak
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Arama çubuğu için yuvarlak köşeler
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Salon veya hizmet ara...',
              hintStyle: AppFonts.bodyMedium(color: AppColors.textColorLight), // app_fonts kullanıldı
              prefixIcon: Icon(Icons.search, color: AppColors.textColorLight),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.textColorLight),
                onPressed: _clearSearch,
              )
                  : null,
              border: InputBorder.none, // Varsayılan kenarlığı kaldır
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0), // Metnin dikey hizalamasını ayarla
            ),
            style: AppFonts.bodyMedium(color: AppColors.textColorDark), // app_fonts kullanıldı
            onSubmitted: (query) {
              _performSearch(query); // Enter'a basıldığında arama yap
            },
          ),
        ),
      ),
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
                style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorDark), // Font güncellendi
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
                          _performSearch(_searchController.text);
                        });
                      },
                      selectedColor: AppColors.accentColor,
                      backgroundColor: AppColors.tagColorPassive,
                      labelStyle: AppFonts.bodyMedium(
                        color: isSelected ? Colors.white : AppColors.textColorDark,
                      ).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ), // Font güncellendi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.accentColor : AppColors.dividerColor.withValues(alpha: 0.5),
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
              child: _searchResults.isEmpty && (_searchController.text.isNotEmpty || _selectedCategory != null)
                  ? _buildNoResultsFound()
                  : _buildSearchResultsList(),
            ),
            // Bottom Nav Bar KALDIRILDI!
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _searchResults = List.from(_allSalons);
    });
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.textColorLight.withValues(alpha: 0.5)),
          const SizedBox(height: 20),
          Text(
            'Sonuç bulunamadı.',
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textColorLight.withValues(alpha: 0.8)), // Font güncellendi
          ),
          Text(
            'Farklı bir kelime veya kategoriyle arama yapmayı deneyin.',
            style: AppFonts.bodyMedium(color: AppColors.textColorLight.withValues(alpha: 0.6)), // Font güncellendi
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
            // imagePath: 'lib/assets/salon_placeholder.png',
          ),
        );
      },
    );
  }
}