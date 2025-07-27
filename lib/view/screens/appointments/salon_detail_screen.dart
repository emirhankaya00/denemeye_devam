// lib/view/screens/appointments/salon_detail_screen.dart

import 'package:denemeye_devam/view/screens/appointments/comments_screen.dart';
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
import '../search/search_screen.dart'; // Import SearchScreen

class SalonDetailScreen extends StatefulWidget {
  final String salonId;
  const SalonDetailScreen({super.key, required this.salonId});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                _buildMainContent(context, viewModel),
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
    final List<ServiceModel> nailArtServices = [];
    final List<ServiceModel> sacKesimServices = [];
    final List<ServiceModel> sacBakimServices = [];

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // GÜNCELLEME: SliverAppBar tamamen yenilendi.
          _buildSliverAppBar(context, salon),
          // GÜNCELLEME: Eski bilgi kartı yerine yeni aksiyon butonları geldi.
          SliverToBoxAdapter(child: _buildActionButtons(context, salon)),
          SliverToBoxAdapter(child: _buildDiscountBanner()),
          SliverToBoxAdapter(child: _buildCalendar(context, viewModel)),
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
            pinned: true,
          ),
        ];
      },
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

  /// YENİ TASARIM: Resim, gradient ve metinleri birleştiren modern SliverAppBar.
  Widget _buildSliverAppBar(BuildContext context, SaloonModel salon) {
    return SliverAppBar(
      expandedHeight: 300.0, // Resim alanını genişlettik.
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor, // Sabitlendiğinde görünecek renk.
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Arama sayfasına yönlendirme
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        )
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Katman: Arka plan resmi
            Image.network(
              salon.titlePhotoUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.borderColor),
            ),
            // 2. Katman: Okunabilirlik artırmak için gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: [0.5, 0.8, 1.0], // Gradient'in nerede başlayıp biteceği
                ),
              ),
            ),
            // 3. Katman: Resmin üzerindeki metin içerikleri
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: _buildHeaderContent(salon), // Yeni yardımcı metodumuz
            ),
          ],
        ),
      ),
    );
  }

  /// YENİ: Resmin üzerinde gösterilecek olan başlık, detay ve etiketleri oluşturur.
  Widget _buildHeaderContent(SaloonModel salon) {
    // Örnek olarak ilk 3 hizmeti etiket olarak alıyoruz.
    final serviceTags = salon.services.map((s) => s.serviceName).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
      children: [
        Text(
          salon.saloonName,
          style: AppFonts.poppinsBold(fontSize: 26, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('☆ ${salon.rating.toStringAsFixed(1)}', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(' • ', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(salon.saloonAddress?.split(',').first ?? 'İstanbul', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(' • ', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text('5 Km', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
          ],
        ),
        const SizedBox(height: 8),

        // **** DÜZELTME BURADA ****
        // Statik metin, dinamik olarak salon modelinden gelen açıklama ile değiştirildi.
        Text(
          salon.saloonDescription ?? 'Bu salon için bir açıklama mevcut değil.',
          style: AppFonts.bodySmall(color: Colors.white.withOpacity(0.85)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // ***************************

        const SizedBox(height: 12),
        if (serviceTags.isNotEmpty)
          Wrap( // Etiketler sığmazsa alt satıra geçer
            spacing: 8.0,
            children: serviceTags.map((tag) => Chip(
              label: Text(tag, style: AppFonts.bodySmall(color: AppColors.textPrimary)),
              backgroundColor: Colors.white.withOpacity(0.9),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
      ],
    );
  }
  /// YENİLENDİ: _buildSalonInfoCard yerine yeni aksiyon butonları ve yorum bilgisi.
  Widget _buildActionButtons(BuildContext context, SaloonModel salon) {
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final isFavorite = favoritesViewModel.isSalonFavorite(salon.saloonId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol taraftaki aksiyon ikonları
          Row(
            children: [
              _infoIcon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                'Favoriler',
                    () => favoritesViewModel.toggleFavorite(salon.saloonId, salon: salon),
                color: isFavorite ? Colors.red.shade400 : AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              _infoIcon(Icons.location_on_outlined, "Konum'a git", () {}),
              const SizedBox(width: 16),
              _infoIcon(Icons.share_outlined, 'Paylaş', () {}),
            ],
          ),
          // Sağ taraftaki yorum butonu
          TextButton(
            onPressed: () {
              // Yorumlar sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(salonId: salon.saloonId),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.starColor, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      salon.rating.toStringAsFixed(1),
                      style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Text('99+ yorum', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Info Card içindeki ikonlar için yardımcı metot
  Widget _infoIcon(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? AppColors.textPrimary, size: 26),
          const SizedBox(height: 6),
          Text(label, style: AppFonts.bodySmall(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor)
      ),
      child: Row(
        children: [
          const Text('%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('50% indirim', style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
              Text('FREE50 Kodu ile', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel viewModel) {
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
                border: Border.all(color: isSelected ? Colors.transparent : AppColors.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('dd', 'tr_TR').format(date), style: AppFonts.poppinsBold(color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary)),
                  Text(DateFormat('MMM', 'tr_TR').format(date), style: AppFonts.bodySmall(color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary)),
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100.0), // Alttaki bar için boşluk
          child: Text("Bu kategoride hizmet bulunmuyor.", style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
                    Text('\$${service.basePrice.toStringAsFixed(0)}', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('${service.estimatedTime.inMinutes} Dk', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
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

  Widget _buildBottomActionBar(BuildContext context, SalonDetailViewModel viewModel) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${viewModel.selectedServices.length} hizmet', style: AppFonts.bodySmall(color: AppColors.textOnPrimary.withOpacity(0.8))),
                Text('\$${viewModel.totalPrice.toStringAsFixed(0)}', style: AppFonts.poppinsBold(color: AppColors.textOnPrimary, fontSize: 20)),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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