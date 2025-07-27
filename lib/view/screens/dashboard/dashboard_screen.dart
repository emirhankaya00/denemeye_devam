import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'package:denemeye_devam/core/theme/app_colors.dart';
import 'package:denemeye_devam/core/theme/app_fonts.dart';

// Data–view-model
import 'package:denemeye_devam/data/models/saloon_model.dart';
import 'package:denemeye_devam/view/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/filter_viewmodel.dart';

// Widgets / screens
import 'package:denemeye_devam/view/widgets/specific/salon_card.dart';
import 'all_saloons_screen.dart';
import 'category_saloons_screen.dart';
import 'filter_screen.dart';

/// ─────────────────────────────────────────
///                DASHBOARD
/// ─────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Dashboard verilerini ilk kez çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    child: const _DashboardContent(),
  );
}

/// ─────────────────────────────────────────
///      EKRAN GÖVDE İÇERİĞİ
/// ─────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    if (vm.isLoading && vm.nearbySaloons.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    void goAll(String title, List<SaloonModel> list) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AllSaloonsScreen(title: title, saloons: list)),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.fetchDashboardData,
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Harita/üst görsel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/map_placeholder.png',
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            ),

            // Kategoriler
            const SectionTitle(title: 'Kategoriler'),
            const CategoryList(),

            // Filtre butonu
            _buildFilterButton(context),
            const SectionDivider(),

            SectionTitle(
                title: 'Yakınlardaki Salonlar',
                showSeeAll: true,
                onSeeAllPressed: () =>
                    goAll('Yakınlardaki Salonlar', vm.nearbySaloons)),
            SaloonList(saloons: vm.nearbySaloons),
            const SectionDivider(),

            SectionTitle(
                title: 'En Yüksek Puanlılar',
                showSeeAll: true,
                onSeeAllPressed: () =>
                    goAll('En Yüksek Puanlılar', vm.topRatedSaloons)),
            SaloonList(saloons: vm.topRatedSaloons),
            const SectionDivider(),

            SectionTitle(
                title: 'Kampanyalar',
                showSeeAll: true,
                onSeeAllPressed: () =>
                    goAll('Kampanyalar', vm.campaignSaloons)),
            SaloonList(saloons: vm.campaignSaloons),

            const SizedBox(height: 80), // TabBar alanı için boşluk
          ],
        ),
      ),
    );
  }

  /// Filtre butonu
  Widget _buildFilterButton(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: OutlinedButton.icon(
      icon: const Icon(Icons.filter_list),
      label: const Text('Filtrele ve Sırala'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderColor),
        minimumSize: const Size(double.infinity, 45),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => _showFilterPopup(context),
    ),
  );

  /// Modal popup
  void _showFilterPopup(BuildContext context) {
    final vm = Provider.of<FilterViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _FilterPopupContent(),
      ),
    );
  }
}

/// ─────────────────────────────────────────
///     KATEGORİ LİSTESİ (yatay)
/// ─────────────────────────────────────────
/// (Kategori kodu değişmedi – kesildi)
/// …
/// (Aynen senin mevcut CategoryList, SectionTitle, SectionDivider, SaloonList
///  sınıfların burada zaten geçerli.)

/// ─────────────────────────────────────────
///           POPUP İÇERİĞİ
/// ─────────────────────────────────────────
class _FilterPopupContent extends StatefulWidget {
  const _FilterPopupContent();

  @override
  State<_FilterPopupContent> createState() => _FilterPopupContentState();
}

class _FilterPopupContentState extends State<_FilterPopupContent> {
  late FilterOptions _local; // Geçici filtre ayarları

  @override
  void initState() {
    super.initState();
    final vm = context.read<FilterViewModel>();
    _local = vm.currentFilters.copyWith(); // Mevcut ayarlar
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();
    final services = vm.allServices;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrele', style: AppFonts.poppinsBold(fontSize: 20)),
            const SizedBox(height: 20),

            // Hizmet seçimi
            Text('Hizmet Seçimi', style: AppFonts.poppinsBold(fontSize: 16)),
            const SizedBox(height: 8),
            if (vm.isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: services.map((srv) {
                  final sel =
                  _local.selectedServices.contains(srv.serviceName);
                  return FilterChip(
                    label: Text(srv.serviceName, style: AppFonts.bodySmall()),
                    selected: sel,
                    onSelected: (s) {
                      setState(() {
                        if (s) {
                          _local.selectedServices.add(srv.serviceName);
                        } else {
                          _local.selectedServices.remove(srv.serviceName);
                        }
                      });
                    },
                    selectedColor:
                    AppColors.primaryColor.withOpacity(0.25),
                    checkmarkColor: AppColors.primaryColor,
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Puan slider’ı
            Text(
              'Minimum Puan: ${_local.minRating.toStringAsFixed(1)}',
              style: AppFonts.poppinsHeaderTitle(),
            ),
            Slider(
              value: _local.minRating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _local.minRating.toStringAsFixed(1),
              activeColor: AppColors.primaryColor,
              onChanged: (v) =>
                  setState(() => _local = _local.copyWith(minRating: v)),
            ),

            const SizedBox(height: 24),

            // Uygula butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final vm =
                  Provider.of<FilterViewModel>(context, listen: false);
                  await vm.applyFiltersAndFetchResults(_local);
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FilterScreen(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Filtrelenen Salonları Gör',
                  style:
                  AppFonts.poppinsBold(color: AppColors.textOnPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────
//  YARDIMCI WIDGET’LAR
// ─────────────────────────────────────────

// Bölüm başlığı + “Tümünü gör” butonu
class SectionTitle extends StatelessWidget {
  final String title;
  final bool   showSeeAll;
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
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
              AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary)),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Row(
                children: [
                  Text('Tümünü gör',
                      style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// İnce ayraç
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Divider(color: AppColors.borderColor, thickness: 1),
  );
}

// Salon kartlarını yatay listeleyen widget
class SaloonList extends StatelessWidget {
  final List<SaloonModel> saloons;
  const SaloonList({super.key, required this.saloons});

  @override
  Widget build(BuildContext context) {
    if (saloons.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Bu bölümde gösterilecek salon bulunamadı.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    return SizedBox(
      height: 350,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: saloons.length,
        itemBuilder: (context, i) {
          final salon = saloons[i];
          final names = salon.services.map((s) => s.serviceName).toList();
          return Container(
            width: MediaQuery.of(context).size.width * .8,
            margin: const EdgeInsets.only(right: 16),
            child: SalonCard(
              salonId:   salon.saloonId,
              name:      salon.saloonName,
              description: salon.saloonDescription ?? 'Açıklama yok',
              rating:    salon.rating,
              location:  salon.saloonAddress?.split(',').first ?? 'Konum yok',
              distance:  '5 Km', // (örnek – dinamik değil)
              services:  names.isNotEmpty ? names : ['Hizmet yok'],
              imagePath: salon.titlePhotoUrl,
            ),
          );
        },
      ),
    );
  }
}

// Kategori (ikon + metin) yatay listesi – mevcut kodun değişmemiş hâli
// (Senin önceki CategoryList kodunu kopyala; yoksa bu helperları zaten
//  başka bir dosyada tutuyorsan import et.)
// ─────────────────────────────────────────
//  YATAY KATEGORİ LİSTESİ WIDGET’I
// ─────────────────────────────────────────
class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int? _selectedIndex;

  /// Her kategori adını sabit bir görselle eşleştiriyoruz.
  /// Veya DashboardViewModel’den bir ikon url’i döndürebilirsin.
  final Map<String, String> _images = {
    'Saç Hizmetleri'   : 'assets/images/iris_login_img_3.jpg',
    'Yüz ve Cilt Bakımı': 'assets/images/iris_login_img_4.jpg',
    'El & Ayak Bakımı' : 'assets/images/iris_login_img_2.jpg',
    'Erkek Bakım'      : 'assets/images/iris_login_img.jpg',
  };

  @override
  Widget build(BuildContext context) {
    // ViewModel’de tutulan kategori adları
    final names = context.watch<DashboardViewModel>().categoryNames;

    void goCategory(String name, int i) {
      setState(() => _selectedIndex = i);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategorySaloonsScreen(categoryName: name),
          ),
        ).then((_) {
          if (mounted) setState(() => _selectedIndex = null);
        });
      });
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: names.length,
        itemBuilder: (_, i) {
          final name = names[i];
          final selected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => goCategory(name, i),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage(
                          _images[name] ?? 'assets/map_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: AppFonts.bodySmall(
                      color: selected
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
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
