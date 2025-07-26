import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:denemeye_devam/core/theme/app_colors.dart';
import 'package:denemeye_devam/core/theme/app_fonts.dart';
import 'package:denemeye_devam/data/models/saloon_model.dart';
import 'package:denemeye_devam/view/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/filter_viewmodel.dart';
import 'package:denemeye_devam/view/widgets/specific/salon_card.dart';
import 'all_saloons_screen.dart';
import 'category_saloons_screen.dart';
import 'filter_screen.dart';

// ... (DashboardScreen ve _DashboardScreenState aynı kalıyor)

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const _DashboardContent(),
    );
  }
}


class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    if (viewModel.isLoading && viewModel.nearbySaloons.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    void navigateToAllSaloons(String title, List<SaloonModel> saloons) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AllSaloonsScreen(title: title, saloons: saloons)));
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchDashboardData(),
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/map_placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity),
              ),
            ),
            const SectionTitle(title: 'Kategoriler'),
            const CategoryList(), // Düzeltilmiş CategoryList widget'ı
            _buildFilterSection(context),
            const SectionDivider(),
            SectionTitle(title: 'Yakınlardaki Salonlar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('Yakınlardaki Salonlar', viewModel.nearbySaloons)),
            SaloonList(saloons: viewModel.nearbySaloons),
            const SectionDivider(),
            SectionTitle(title: 'En Yüksek Puanlılar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('En Yüksek Puanlılar', viewModel.topRatedSaloons)),
            SaloonList(saloons: viewModel.topRatedSaloons),
            const SectionDivider(),
            SectionTitle(title: 'Kampanyalar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('Kampanyalar', viewModel.campaignSaloons)),
            SaloonList(saloons: viewModel.campaignSaloons),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.filter_list),
        label: const Text('Filtrele ve Sırala'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderColor),
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _showFilterPopup(context),
      ),
    );
  }

  void _showFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        value: Provider.of<FilterViewModel>(context, listen: false),
        child: const FilterPopupContent(),
      ),
    );
  }
}

/// DÜZELTME: Kategori listesi artık dinamik ve tıklanınca renk değiştiriyor.
class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int? _selectedIndex; // Seçili olan kategorinin index'ini tutar.

  // Kategori resimlerini eşleştirmek için sabit bir map
  final Map<String, String> _categoryImages = {
    'Saç Hizmetleri': 'assets/images/iris_login_img_3.jpg',
    'Yüz ve Cilt Bakımı': 'assets/images/iris_login_img_4.jpg',
    'El & Ayak Bakımı': 'assets/images/iris_login_img_2.jpg',
    'Erkek Bakım': 'assets/images/iris_login_img.jpg',
  };

  @override
  Widget build(BuildContext context) {
    // Kategori isimlerini doğrudan ViewModel'den alıyoruz.
    final categoryNames = context.watch<DashboardViewModel>().categoryNames;

    void navigateToCategory(String categoryName, int index) {
      setState(() {
        _selectedIndex = index; // Tıklanan kategoriyi seçili yap.
      });
      // Renk değişimini anında görmek için kısa bir gecikme
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategorySaloonsScreen(categoryName: categoryName)),
        ).then((_) {
          // Sayfadan geri dönüldüğünde seçimi sıfırla
          if (mounted) {
            setState(() {
              _selectedIndex = null;
            });
          }
        });
      });
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final categoryName = categoryNames[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () => navigateToCategory(categoryName, index),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(_categoryImages[categoryName] ?? 'assets/map_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryName,
                    style: AppFonts.bodySmall(color: isSelected ? AppColors.primaryColor : AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


/// DÜZELTME: Fiyat aralığı filtresi kaldırıldı.
class FilterPopupContent extends StatefulWidget {
  const FilterPopupContent({super.key});

  @override
  State<FilterPopupContent> createState() => _FilterPopupContentState();
}

class _FilterPopupContentState extends State<FilterPopupContent> {
  late FilterOptions _localFilters;

  @override
  void initState() {
    super.initState();
    _localFilters = Provider.of<FilterViewModel>(context, listen: false).currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final allServices = context.watch<FilterViewModel>().allServices;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrele ve Sırala', style: AppFonts.poppinsBold(fontSize: 20)),
            const SizedBox(height: 20),
            Text('Hizmet Seçimi', style: AppFonts.poppinsBold(fontSize: 16)),
            const SizedBox(height: 10),
            if (allServices.isEmpty)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: allServices.map((service) {
                  final isSelected = _localFilters.selectedServices.contains(service.serviceName);
                  return FilterChip(
                    label: Text(service.serviceName, style: AppFonts.bodySmall()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _localFilters.selectedServices.add(service.serviceName);
                        } else {
                          _localFilters.selectedServices.remove(service.serviceName);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryColor.withOpacity(0.3),
                    checkmarkColor: AppColors.primaryColor,
                  );
                }).toList(),
              ),
            const Divider(height: 30),
            Text('Minimum Puan: ${_localFilters.minRating.toStringAsFixed(1)}', style: AppFonts.poppinsHeaderTitle()),
            Slider(
              value: _localFilters.minRating,
              min: 1, max: 5, divisions: 4,
              activeColor: AppColors.primaryColor,
              label: _localFilters.minRating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _localFilters = _localFilters.copyWith(minRating: value)),
            ),
            SwitchListTile(
              title: Text('İndirimli Salonlar', style: AppFonts.poppinsHeaderTitle()),
              value: _localFilters.hasDiscount,
              onChanged: (value) => setState(() => _localFilters = _localFilters.copyWith(hasDiscount: value)),
              activeColor: AppColors.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final viewModel = Provider.of<FilterViewModel>(context, listen: false);
                  viewModel.applyFiltersAndFetchResults(_localFilters);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FilterScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Filtrelenen Salonları Gör', style: AppFonts.poppinsBold(color: AppColors.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (SectionTitle, SectionDivider, SaloonList widget'ları aynı kalıyor)

class SectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllPressed;

  const SectionTitle({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary),
          ),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Row(
                children: [
                  Text(
                    'Tümünü gör',
                    style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Divider(color: AppColors.borderColor, thickness: 1),
    );
  }
}

class SaloonList extends StatelessWidget {
  final List<SaloonModel> saloons;

  const SaloonList({
    super.key,
    required this.saloons,
  });

  @override
  Widget build(BuildContext context) {
    if (saloons.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
            child: Text(
              "Bu bölümde gösterilecek salon bulunamadı.",
              style: TextStyle(color: AppColors.textSecondary),
            )),
      );
    }
    return SizedBox(
      height: 350,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames =
          salon.services.map((s) => s.serviceName).toList();

          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(right: 8.0),
            child: SalonCard(
              salonId: salon.saloonId,
              name: salon.saloonName,
              description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
              rating: salon.rating, // Dinamik olarak gelmeli
              location: salon.saloonAddress?.split(',').first ?? 'Konum Yok',
              distance: '5 Km', // Bu değer hesaplanmalı
              services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet Yok"],
              imagePath: salon.titlePhotoUrl,
            ),
          );
        },
      ),
    );
  }
}