// lib/features/saloons/screens/salon_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../../data/models/service_model.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../../view_models/saloon_detail_viewmodel.dart';
// Diğer importlarınız...

class SalonDetailScreen extends StatefulWidget {
  final String salonId;
  const SalonDetailScreen({super.key, required this.salonId});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

// Sekmelerin (TabBar) yönetimi için SingleTickerProviderStateMixin ekliyoruz.
class _SalonDetailScreenState extends State<SalonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    // TODO: Hizmet kategorilerine göre sekme sayısı dinamik olmalı.
    // Şimdilik tasarımda 4 kategori olduğu için 4 olarak ayarlıyoruz.
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ViewModel'i burada dinlemeye başlıyoruz.
      Provider.of<SalonDetailViewModel>(context, listen: false).fetchSalonDetails(widget.salonId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel'i Provider ile widget ağacına dahil ediyoruz.
    return ChangeNotifierProvider(
      create: (_) => SalonDetailViewModel()..fetchSalonDetails(widget.salonId),
      child: Consumer<SalonDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || viewModel.salon == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
            );
          }
          // Ana Scaffold yapısı Stack ile sarmalanıyor.
          // Bu, en altta "Randevu Al" barını gösterebilmemizi sağlar.
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                _buildMainContent(context, viewModel),
                // Seçili servis varsa, alttaki barı göster.
                if (viewModel.selectedServices.isNotEmpty)
                  _buildBottomActionBar(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- ANA İÇERİK (KAYDIRILABİLİR ALAN) ---
  Widget _buildMainContent(BuildContext context, SalonDetailViewModel viewModel) {
    final salon = viewModel.salon!;

    // TODO: Bu hizmet listeleri, modelinizdeki kategori bilgisine göre doldurulmalı.
    final List<ServiceModel> ciltBakimServices = salon.services;
    final List<ServiceModel> nailArtServices = []; // Örnek
    final List<ServiceModel> sacKesimServices = []; // Örnek
    final List<ServiceModel> sacBakimServices = []; // Örnek

    // NestedScrollView, iç içe kaydırılabilir alanlar oluşturmamızı sağlar.
    // headerSliverBuilder: Üstte kalan, kaydırıldıkça değişen kısım.
    // body: Altta kalan, sekmelere göre içeriği değişen kısım.
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildSliverAppBar(context, salon),
          SliverToBoxAdapter(child: _buildSalonInfoCard(context, salon)),
          SliverToBoxAdapter(child: _buildDiscountBanner()),
          SliverToBoxAdapter(child: _buildCalendar(context, viewModel)),
          // SliverPersistentHeader, TabBar'ın ekranın üstüne sabitlenmesini sağlar.
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.textOnPrimary,
                unselectedLabelColor: AppColors.textPrimary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryColor,
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Cilt Bakım'),
                  Tab(text: 'Nail Art'),
                  Tab(text: 'Saç Kesim'),
                  Tab(text: 'Saç Bakım'),
                ],
              ),
            ),
            pinned: true, // Üste yapışmasını sağlar.
          ),
        ];
      },
      // TabBar'a bağlı olarak gösterilecek içerikler.
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServiceList(context, viewModel, ciltBakimServices),
          _buildServiceList(context, viewModel, nailArtServices),
          _buildServiceList(context, viewModel, sacKesimServices),
          _buildServiceList(context, viewModel, sacBakimServices),
        ],
      ),
    );
  }

  // --- WIDGET BÖLÜMLERİ ---

  Widget _buildSliverAppBar(BuildContext context, SaloonModel salon) {
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final bool isFavorite = favoritesViewModel.isSalonFavorite(salon.saloonId);

    return SliverAppBar(
      expandedHeight: 220.0, // Resmin başlangıçtaki yüksekliği
      floating: false,
      pinned: true, // Kaydırıldığında AppBar'ın yukarıda kalmasını sağlar
      backgroundColor: AppColors.primaryColor,
      elevation: 1.0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () { /* Arama fonksiyonu */ },
        )
      ],
      // FlexibleSpaceBar, AppBar'ın esnek alanıdır. Resim buraya konur.
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(salon.saloonName, style: AppFonts.poppinsBold(color: Colors.white, fontSize: 16)),
        background: Image.network(
          salon.titlePhotoUrl ?? '',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.4), // Resmin üzerine hafif bir karartma efekti
          colorBlendMode: BlendMode.darken,
          errorBuilder: (_, __, ___) => Container(color: AppColors.borderColor),
        ),
      ),
    );
  }

  Widget _buildSalonInfoCard(BuildContext context, SaloonModel salon) {
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final bool isFavorite = favoritesViewModel.isSalonFavorite(salon.saloonId);
    // Bu kart, salonun temel bilgilerini ve aksiyon butonlarını içerir.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("⭐️ ${salon.rating.toStringAsFixed(1)}", style: AppFonts.bodyMedium()),
              Text("📍 5 Km", style: AppFonts.bodyMedium()), // Mesafe dinamik olmalı
              Text("💬 99+ Yorum", style: AppFonts.bodyMedium()),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoIcon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                'Favoriler',
                    () => favoritesViewModel.toggleFavorite(salon.saloonId, salon: salon),
                color: isFavorite ? Colors.red.shade400 : AppColors.primaryColor,
              ),
              _infoIcon(Icons.location_on_outlined, "Konum'a Git", () {}),
              _infoIcon(Icons.share_outlined, 'Paylaş', () {}),
            ],
          )
        ],
      ),
    );
  }

  // Info Card içindeki ikonlar için yardımcı metot
  Widget _infoIcon(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(icon, color: color ?? AppColors.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(label, style: AppFonts.bodySmall(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Text('50% İndirim', style: AppFonts.poppinsBold(color: AppColors.primaryColor)),
          const SizedBox(width: 4),
          Text('FREESD Kodu ile', style: AppFonts.bodyMedium(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel viewModel) {
    // Tasarımdaki yatay takvim
    final List<DateTime> weekDates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = viewModel.selectedDate.day == date.day;

          return GestureDetector(
            onTap: () => viewModel.selectNewDate(date),
            child: Container(
              width: 55,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.borderColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd', 'tr_TR').format(date),
                    style: AppFonts.poppinsBold(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM', 'tr_TR').format(date),
                    style: AppFonts.bodySmall(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
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

  Widget _buildServiceList(BuildContext context, SalonDetailViewModel viewModel, List<ServiceModel> services) {
    if (services.isEmpty) {
      return Center(
        child: Text(
          "Bu kategoride hizmet bulunmuyor.",
          style: AppFonts.bodyMedium(color: AppColors.textSecondary),
        ),
      );
    }
    // Hizmet listesi
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Alttaki bar için boşluk
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = viewModel.isServiceSelected(service);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/map_placeholder.png', width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.serviceName, style: AppFonts.poppinsBold(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${service.basePrice.toStringAsFixed(0)}',
                      style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${service.estimatedTime.inMinutes} Dk',
                      style: AppFonts.bodySmall(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => viewModel.toggleService(service),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isSelected ? AppColors.textOnPrimary : AppColors.primaryColor,
                  backgroundColor: isSelected ? AppColors.primaryColor : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(color: isSelected ? Colors.transparent : AppColors.primaryColor.withOpacity(0.5)),
                ),
                child: Text(isSelected ? 'Çıkar' : 'Ekle +'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Ekranın en altında görünen "Randevu Al" barı
  Widget _buildBottomActionBar(BuildContext context, SalonDetailViewModel viewModel) {
    // Sadece servis seçiliyken görünür
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${viewModel.selectedServices.length} hizmet',
                  style: AppFonts.bodySmall(color: AppColors.textOnPrimary.withOpacity(0.8)),
                ),
                Text(
                  '\$${viewModel.totalPrice.toStringAsFixed(0)}',
                  style: AppFonts.poppinsBold(color: AppColors.textOnPrimary, fontSize: 20),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () { /* Randevu alımının son adımı (yeni sayfaya yönlendirme vs.) */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textOnPrimary,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Randevu Al', style: AppFonts.poppinsBold()),
            ),
          ],
        ),
      ),
    );
  }
}

// Sekme başlıklarını sabitlemek için yardımcı class
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TabBar'ın arkasının transparan olmaması için bir Container ile sarmalıyoruz.
    return Container(
      color: AppColors.background,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}