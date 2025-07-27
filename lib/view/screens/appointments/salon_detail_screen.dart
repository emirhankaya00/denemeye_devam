// lib/view/screens/appointments/salon_detail_screen.dart

import 'dart:async';
import 'package:denemeye_devam/view/screens/appointments/comments_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../../data/models/service_model.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../../view_models/saloon_detail_viewmodel.dart';
import '../../view_models/comments_viewmodel.dart';
import '../search/search_screen.dart';

class SalonDetailScreen extends StatelessWidget {
  /// 🔁 Burayı `salonId` olarak tuttuk (tek "o") — proje genelindeki çağrılarla uyumlu.
  final String salonId;
  const SalonDetailScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SalonDetailViewModel>(
      // ViewModel’i burada kurup veriyi microtask ile tetikliyoruz.
      create: (_) {
        final vm = SalonDetailViewModel();
        scheduleMicrotask(() => vm.fetchSalonDetails(salonId));
        return vm;
      },
      child: _SalonDetailBody(salonId: salonId),
    );
  }
}

class _SalonDetailBody extends StatelessWidget {
  final String salonId;
  const _SalonDetailBody({required this.salonId});
  String _formatCount(int n) => n > 99 ? '99+' : n.toString();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalonDetailViewModel>();

    if (vm.isLoading || vm.salon == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildMainContent(context, vm),
            if (vm.selectedServices.isNotEmpty) _buildBottomActionBar(context, vm),
          ],
        ),
      ),
    );
  }

  // --- ANA İÇERİK ---
  Widget _buildMainContent(BuildContext context, SalonDetailViewModel vm) {
    final salon = vm.salon!;

    final List<ServiceModel> ciltBakimServices = salon.services;
    final List<ServiceModel> nailArtServices = [];
    final List<ServiceModel> sacKesimServices = [];
    final List<ServiceModel> sacBakimServices = [];

    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        _buildSliverAppBar(context, salon),
        SliverToBoxAdapter(child: _buildActionButtons(context, salon)),
        SliverToBoxAdapter(child: _buildDiscountBanner()),
        SliverToBoxAdapter(child: _buildCalendar(context, vm)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
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
        ),
      ],
      body: TabBarView(
        children: [
          _buildServiceList(context, vm, ciltBakimServices),
          _buildServiceList(context, vm, nailArtServices),
          _buildServiceList(context, vm, sacKesimServices),
          _buildServiceList(context, vm, sacBakimServices),
        ],
      ),
    );
  }

  /// SliverAppBar (resim + gradient + başlık)
  Widget _buildSliverAppBar(BuildContext context, SaloonModel salon) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              salon.titlePhotoUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.borderColor),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: [0.5, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: _buildHeaderContent(salon),
            ),
          ],
        ),
      ),
    );
  }

  /// Başlık alanı
  Widget _buildHeaderContent(SaloonModel salon) {
    final serviceTags = salon.services.map((s) => s.serviceName).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(salon.saloonName, style: AppFonts.poppinsBold(fontSize: 26, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('☆ ${salon.rating.toStringAsFixed(1)}',
                style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(' • ', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(salon.saloonAddress?.split(',').first ?? 'İstanbul',
                style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text(' • ', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
            Text('5 Km', style: AppFonts.bodyMedium(color: Colors.white.withOpacity(0.9))),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          salon.saloonDescription ?? 'Bu salon için bir açıklama mevcut değil.',
          style: AppFonts.bodySmall(color: Colors.white.withOpacity(0.85)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        if (serviceTags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: serviceTags
                .map((tag) => Chip(
              label: Text(tag, style: AppFonts.bodySmall(color: AppColors.textPrimary)),
              backgroundColor: Colors.white.withOpacity(0.9),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ))
                .toList(),
          ),
      ],
    );
  }

  /// Aksiyonlar + Yorumlar butonu
  Widget _buildActionButtons(BuildContext context, SaloonModel salon) {
    final favorites = context.watch<FavoritesViewModel>();
    final isFavorite = favorites.isSalonFavorite(salon.saloonId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            _infoIcon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              'Favoriler',
                  () => favorites.toggleFavorite(salon.saloonId, salon: salon),
              color: isFavorite ? Colors.red.shade400 : AppColors.textPrimary,
            ),
            const SizedBox(width: 16),
            _infoIcon(Icons.location_on_outlined, "Konum'a git", () {}),
            const SizedBox(width: 16),
            _infoIcon(Icons.share_outlined, 'Paylaş', () {}),
          ]),
          TextButton(
            onPressed: () {
              // Yorumlar ekranını route‑scoped Provider ile aç
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<CommentsViewModel>(
                    // ✅ CommentsViewModel sizde parametresiz ise:
                    create: (_) => CommentsViewModel()..fetchComments(salon.saloonId),
                    // Eğer CommentsViewModel(repo) imzanız varsa yukarıyı şu yapın:
                    // create: (ctx) => CommentsViewModel(ctx.read<CommentRepository>())..fetchComments(salon.saloonId),
                    child: CommentsScreen(saloonId: salon.saloonId),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded, color: AppColors.starColor, size: 22),
                  const SizedBox(width: 4),
                  Text(salon.rating.toStringAsFixed(1),
                      style: AppFonts.poppinsBold(fontSize: 16, color: AppColors.textPrimary)),
                ]),
                Text(
                  '${_formatCount(salon.commentCount)} yorum',
                  style: AppFonts.bodySmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Text('%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('50% indirim', style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
            Text('FREE50 Kodu ile', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel vm) {
    final weekDates = List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: weekDates.length,
        itemBuilder: (_, i) {
          final date = weekDates[i];
          final isSelected = vm.selectedDate.day == date.day &&
              vm.selectedDate.month == date.month &&
              vm.selectedDate.year == date.year;
          return GestureDetector(
            onTap: () => vm.selectNewDate(date),
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
                  Text(DateFormat('dd', 'tr_TR').format(date),
                      style: AppFonts.poppinsBold(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary)),
                  Text(DateFormat('MMM', 'tr_TR').format(date),
                      style: AppFonts.bodySmall(
                          color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceList(BuildContext context, SalonDetailViewModel vm, List<ServiceModel> services) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Text('Bu kategoride hizmet bulunmuyor.',
              style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: services.length,
      itemBuilder: (_, index) {
        final service = services[index];
        final isSelected = vm.isServiceSelected(service);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/map_placeholder.png',
                  width: 80, height: 80, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.serviceName, style: AppFonts.poppinsBold(fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('\$${service.basePrice.toStringAsFixed(0)}',
                        style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('${service.estimatedTime.inMinutes} Dk',
                        style: AppFonts.bodySmall(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => vm.toggleService(service),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isSelected ? AppColors.textOnPrimary : AppColors.primaryColor,
                  backgroundColor: isSelected ? AppColors.primaryColor : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : AppColors.primaryColor.withOpacity(0.5),
                  ),
                ),
                child: Text(isSelected ? 'Çıkar' : 'Ekle +'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, SalonDetailViewModel vm) {
    return Positioned(
      bottom: 20, left: 20, right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('${vm.selectedServices.length} hizmet',
                style: AppFonts.bodySmall(color: AppColors.textOnPrimary.withOpacity(0.8))),
            Text('\$${vm.totalPrice.toStringAsFixed(0)}',
                style: AppFonts.poppinsBold(color: AppColors.textOnPrimary, fontSize: 20)),
          ]),
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
        ]),
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
    return Container(color: AppColors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
