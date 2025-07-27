import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Proje dosyalarınızı import edin
import 'package:denemeye_devam/core/theme/app_colors.dart';
import 'package:denemeye_devam/core/theme/app_fonts.dart';
import 'package:denemeye_devam/data/models/saloon_model.dart';
import 'package:denemeye_devam/view/view_models/dashboard_viewmodel.dart';
import 'package:denemeye_devam/view/view_models/filter_viewmodel.dart';
import 'package:denemeye_devam/view/widgets/specific/salon_card.dart';

// Sayfa yönlendirmeleri için importlar
import 'all_saloons_screen.dart';
import 'category_saloons_screen.dart';
import 'filter_screen.dart';


// --- ANA DASHBOARD EKRANI ---
// Bu widget, ekranın temel yapısını kurar ve veri çekme işlemini başlatır.

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran ilk yüklendiğinde ViewModel aracılığıyla gerekli verileri çekiyoruz.
    // addPostFrameCallback kullanarak build işlemi bittikten sonra çalışmasını sağlıyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const _DashboardContent(), // Ekranın içeriğini ayrı bir widget'ta tutuyoruz.
    );
  }
}


// --- DASHBOARD İÇERİK WIDGET'I ---
// Ekranın tüm görsel elemanlarını ve mantığını içerir.

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    // Veriler yüklenirken bekleme göstergesi gösterilir.
    if (viewModel.isLoading && viewModel.nearbySaloons.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    // "Tümünü Gör" butonuna tıklandığında ilgili sayfaya yönlendirme fonksiyonu.
    void navigateToAllSaloons(String title, List<SaloonModel> saloons) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AllSaloonsScreen(title: title, saloons: saloons)));
    }

    // RefreshIndicator ile sayfayı aşağı çekerek yenileme özelliği ekleniyor.
    return RefreshIndicator(
      onRefresh: () => viewModel.fetchDashboardData(),
      color: AppColors.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısımdaki görsel (Harita vb.)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/map_placeholder.png', fit: BoxFit.cover, height: 200, width: double.infinity),
              ),
            ),

            // Bölüm başlıkları ve listeler
            const SectionTitle(title: 'Kategoriler'),
            const CategoryList(),
            _buildFilterSection(context), // Filtreleme butonu
            const SectionDivider(),

            SectionTitle(title: 'Yakınlardaki Salonlar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('Yakınlardaki Salonlar', viewModel.nearbySaloons)),
            SaloonList(saloons: viewModel.nearbySaloons),
            const SectionDivider(),

            SectionTitle(title: 'En Yüksek Puanlılar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('En Yüksek Puanlılar', viewModel.topRatedSaloons)),
            SaloonList(saloons: viewModel.topRatedSaloons),
            const SectionDivider(),

            SectionTitle(title: 'Kampanyalar', showSeeAll: true, onSeeAllPressed: () => navigateToAllSaloons('Kampanyalar', viewModel.campaignSaloons)),
            SaloonList(saloons: viewModel.campaignSaloons),

            // Alt kısımda boşluk bırakarak tab bar'ın içeriği engellemesini önlüyoruz.
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// "Filtrele ve Sırala" butonunu oluşturan yardımcı fonksiyon.
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

  /// Filtreleme seçeneklerini gösteren modal bottom sheet'i açar.
  void _showFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // İçeriğin uzunluğuna göre boyutlanmasını sağlar.
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ChangeNotifierProvider.value(
        // Mevcut FilterViewModel'i alt widget'a iletiyoruz.
        value: Provider.of<FilterViewModel>(context, listen: false),
        child: const FilterPopupContent(),
      ),
    );
  }
}


// --- KATEGORİ LİSTESİ WIDGET'I ---
// Yatayda kaydırılabilir kategori listesini oluşturur. Tıklama animasyonu içerir.

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int? _selectedIndex; // Seçili kategorinin index'ini tutar.

  // Kategori resimlerini isimleriyle eşleştiren map.
  // Not: Bu bilgiyi kategori modelinizin içinden almak daha dinamik bir çözüm olur.
  final Map<String, String> _categoryImages = {
    'Saç Hizmetleri': 'assets/images/iris_login_img_3.jpg',
    'Yüz ve Cilt Bakımı': 'assets/images/iris_login_img_4.jpg',
    'El & Ayak Bakımı': 'assets/images/iris_login_img_2.jpg',
    'Erkek Bakım': 'assets/images/iris_login_img.jpg',
  };

  @override
    Widget build(BuildContext context) {
    final categoryNames = context.watch<DashboardViewModel>().categoryNames;

    void navigateToCategory(String categoryName, int index) {
      setState(() => _selectedIndex = index); // Tıklanan kategoriyi seçili yap.

      // Kısa bir gecikme ile hem animasyonun görünmesini sağlıyoruz hem de sayfaya yönlendiriyoruz.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategorySaloonsScreen(categoryName: categoryName)),
        ).then((_) {
          // Kullanıcı sayfadan geri döndüğünde seçimi sıfırlıyoruz.
          if (mounted) {
            setState(() => _selectedIndex = null);
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


// --- FİLTRE POPUP İÇERİĞİ ---
// Modal olarak açılan filtreleme arayüzünü oluşturur.

class FilterPopupContent extends StatefulWidget {
  const FilterPopupContent({super.key});

  @override
  State<FilterPopupContent> createState() => _FilterPopupContentState();
}

class _FilterPopupContentState extends State<FilterPopupContent> {
  // Kullanıcının yaptığı değişiklikleri geçici olarak tutacak olan lokal filtre nesnesi.
  late FilterOptions _localFilters;

  @override
  void initState() {
    super.initState();
    // Popup açıldığında, FilterViewModel'deki mevcut filtreleri kopyalayarak işe başlıyoruz.
    _localFilters = Provider.of<FilterViewModel>(context, listen: false).currentFilters.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'den tüm hizmetlerin listesini alıyoruz.
    final allServices = context.watch<FilterViewModel>().allServices;

    return Padding(
      // Klavye açıldığında içeriğin yukarı kaymasını sağlar.
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrele ve Sırala', style: AppFonts.poppinsBold(fontSize: 20)),
            const SizedBox(height: 20),

            // Hizmet Seçimi
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
                      // Hizmet seçildiğinde veya seçim kaldırıldığında lokal listeyi güncelliyoruz.
                      setState(() {
                        if (selected) {
                          _localFilters.selectedServices.add(service.serviceName);
                        } else {
                          _localFilters.selectedServices.remove(service.serviceName);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryColor.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primaryColor,
                  );
                }).toList(),
              ),
            const Divider(height: 30),

            // Puan Filtresi
            Text('Minimum Puan: ${_localFilters.minRating.toStringAsFixed(1)}', style: AppFonts.poppinsHeaderTitle()),
            Slider(
              value: _localFilters.minRating,
              min: 1, max: 5, divisions: 4,
              activeColor: AppColors.primaryColor,
              label: _localFilters.minRating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _localFilters = _localFilters.copyWith(minRating: value)),
            ),

            // İndirim Filtresi
            SwitchListTile(
              title: Text('İndirimli Salonlar', style: AppFonts.poppinsHeaderTitle()),
              value: _localFilters.hasDiscount,
              onChanged: (value) => setState(() => _localFilters = _localFilters.copyWith(hasDiscount: value)),
              activeColor: AppColors.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            // Filtreleme Sonuçlarını Göster Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final viewModel = Provider.of<FilterViewModel>(context, listen: false);
                  // 1. Lokalde yapılan değişiklikleri ana ViewModel'e iletiyoruz.
                  viewModel.applyFiltersAndFetchResults(_localFilters);
                  // 2. Popup'ı kapatıyoruz.
                  Navigator.pop(context);
                  // 3. Sonuçların gösterileceği FilterScreen'e yönlendiriyoruz.
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


// --- YARDIMCI WIDGET'LAR ---
// Kod tekrarını önlemek için kullanılan küçük ve yeniden kullanılabilir widget'lar.

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
          Text(title, style: AppFonts.poppinsBold(fontSize: 18, color: AppColors.textPrimary)),
          if (showSeeAll)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Row(
                children: [
                  Text('Tümünü gör', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.textSecondary),
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

  const SaloonList({super.key, required this.saloons});

  @override
  Widget build(BuildContext context) {
    if (saloons.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("Bu bölümde gösterilecek salon bulunamadı.", style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    return SizedBox(
      height: 350, // SalonCard'ınızın yüksekliğine göre ayarlayabilirsiniz.
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: saloons.length,
        itemBuilder: (context, index) {
          final salon = saloons[index];
          final serviceNames = salon.services.map((s) => s.serviceName).toList();

          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(right: 16.0), // Kartlar arası boşluk
            child: SalonCard(
              salonId: salon.saloonId,
              name: salon.saloonName,
              description: salon.saloonDescription ?? 'Açıklama mevcut değil.',
              rating: salon.rating,
              location: salon.saloonAddress?.split(',').first ?? 'Konum bilgisi yok',
              // Not: Mesafe (distance) bilgisi için kullanıcının konumu ile salonun konumu arasında hesaplama yapılmalıdır.
              distance: '5 Km', // Bu değer dinamik olmalı.
              services: serviceNames.isNotEmpty ? serviceNames : ["Hizmet bulunmuyor"],
              imagePath: salon.titlePhotoUrl,
            ),
          );
        },
      ),
    );
  }
}