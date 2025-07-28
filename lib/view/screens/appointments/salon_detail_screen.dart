// KULLANICI UYGULAMASI -> lib/view/screens/appointments/salon_detail_screen.dart

import 'package:denemeye_devam/view/screens/appointments/comments_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:denemeye_devam/view/screens/appointments/checkout_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/saloon_model.dart';
import '../../../data/models/category_with_services.dart';
import '../../../data/repositories/saloon_repository.dart';
import '../../view_models/favorites_viewmodel.dart';
import '../../view_models/saloon_detail_viewmodel.dart';
import '../../view_models/comments_viewmodel.dart';
import '../search/search_screen.dart';

class SalonDetailScreen extends StatelessWidget {
  final String saloonId;
  const SalonDetailScreen({super.key, required this.saloonId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SalonDetailViewModel>(
      create: (ctx) =>
      SalonDetailViewModel(ctx.read<SaloonRepository>())
        ..fetchSalonDetails(saloonId),
      child: _SalonDetailBody(salonId: saloonId),
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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    // Kategoriler varsa dinamik tabbar
    final int tabLength = vm.categories.isNotEmpty ? vm.categories.length : 1;
    return DefaultTabController(
      length: tabLength,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildMainContent(context, vm),
            if (vm.totalCount > 0) _buildBottomActionBar(context, vm),
          ],
        ),
      ),
    );
  }

  // DÜZELTME: ANA İÇERİK OLUŞTURUCU BİRLEŞTİRİLDİ
  Widget _buildMainContent(BuildContext context, SalonDetailViewModel vm) {
    final salon = vm.salon!;
    final tabs = vm.categories.map((c) => Tab(text: c.categoryName)).toList();

    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        _buildSliverAppBar(context, salon),
        SliverToBoxAdapter(child: _buildActionButtons(context, vm)),
        SliverToBoxAdapter(child: _buildDiscountBanner()),
        SliverToBoxAdapter(child: _buildCalendar(context, vm)),
        if (vm.categories.isNotEmpty)
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
                indicatorPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                isScrollable: true,
                tabs: tabs,
              ),
            ),
          ),
      ],
      body: vm.categories.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Text(
            'Bu salonda aktif hizmet bulunmuyor.',
            style: AppFonts.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
      )
          : TabBarView(
        children: vm.categories
            .map((cat) => _buildCategoryServiceList(context, vm, cat))
            .toList(),
      ),
    );
  }

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
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.borderColor),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: [0.5, 0.8, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildHeaderContent(salon),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(SaloonModel salon) {
    final serviceTags =
    salon.services.map((s) => s.serviceName).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(salon.saloonName,
            style: AppFonts.poppinsBold(fontSize: 26, color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('☆ ${salon.rating.toStringAsFixed(1)}',
                style: AppFonts.bodyMedium(
                    color: Colors.white.withOpacity(0.9))),
            Text(' • ',
                style: AppFonts.bodyMedium(
                    color: Colors.white.withOpacity(0.9))),
            Text(salon.saloonAddress?.split(',').first ?? 'İstanbul',
                style: AppFonts.bodyMedium(
                    color: Colors.white.withOpacity(0.9))),
            Text(' • ',
                style: AppFonts.bodyMedium(
                    color: Colors.white.withOpacity(0.9))),
            Text('5 Km',
                style: AppFonts.bodyMedium(
                    color: Colors.white.withOpacity(0.9))),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          salon.saloonDescription ?? 'Bu salon için bir açıklama mevcut değil.',
          style:
          AppFonts.bodySmall(color: Colors.white.withOpacity(0.85)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        if (serviceTags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: serviceTags
                .map(
                  (tag) => Chip(
                label: Text(tag,
                    style: AppFonts.bodySmall(
                        color: AppColors.textPrimary)),
                backgroundColor: Colors.white.withOpacity(0.9),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            )
                .toList(),
          ),
      ],
    );
  }

  // DÜZELTME: AKSİYON BUTONLARI ARTIK VIEWMODEL ALIYOR
  Widget _buildActionButtons(BuildContext context, SalonDetailViewModel vm) {
    final salon = vm.salon!;
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
              'Favori',
                  () => favorites.toggleFavorite(salon.saloonId, salon: salon),
              color: isFavorite ? Colors.red.shade400 : AppColors.textPrimary,
            ),
            const SizedBox(width: 16),
            _infoIcon(Icons.location_on_outlined, "Konum", () {}),
            const SizedBox(width: 16),
            // DÜZELTME: YORUM YAP BUTONU EKLENDİ
            // Sadece ViewModel'den gelen canUserComment bilgisi true ise gösterilir.
            if (vm.canUserComment)
              _infoIcon(Icons.edit_outlined, 'Yorum Yap', () => _showCommentDialog(context, vm)),
          ]),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<CommentsViewModel>(
                    create: (_) => CommentsViewModel()..fetchComments(salon.saloonId),
                    child: CommentsScreen(saloonId: salon.saloonId),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.starColor, size: 22),
                  const SizedBox(width: 4),
                  Text(
                    salon.rating.toStringAsFixed(1),
                    style: AppFonts.poppinsBold(
                        fontSize: 16, color: AppColors.textPrimary),
                  ),
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

  // DÜZELTME: YORUM YAPMA DİALOGUNU AÇAN FONKSİYON
  void _showCommentDialog(BuildContext context, SalonDetailViewModel vm) {
    int rating = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yorum Yap'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Hizmeti Puanlayın:'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Yorumunuzu buraya yazın...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (rating == 0 || commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen puan verin ve yorum yazın.')),
                      );
                      return;
                    }

                    final success = await vm.submitComment(
                      rating: rating,
                      commentText: commentController.text,
                    );

                    if (context.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Yorumunuz başarıyla gönderildi!' : 'Yorum gönderilemedi.'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Gönder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Text('%',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('50% indirim',
                  style:
                  AppFonts.poppinsBold(color: AppColors.textPrimary)),
              Text('FREE50 Kodu ile',
                  style: AppFonts.bodySmall(
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SalonDetailViewModel vm) {
    final weekDates =
    List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
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
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.borderColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('dd', 'tr_TR').format(date),
                      style: AppFonts.poppinsBold(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      )),
                  Text(DateFormat('MMM', 'tr_TR').format(date),
                      style: AppFonts.bodySmall(
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.textSecondary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryServiceList(BuildContext context, SalonDetailViewModel vm, CategoryWithServices cat) {
    final services = cat.services;
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Text(
            'Bu kategoride hizmet bulunmuyor.',
            style: AppFonts.bodyMedium(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = services[index];
        final selected = vm.isSelected(item.serviceId);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8)],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/map_placeholder.png', width: 64, height: 64, fit: BoxFit.cover),
            ),
            title: Text(item.serviceName, style: AppFonts.poppinsBold(fontSize: 15)),
            subtitle: Row(
              children: [
                Text('₺${item.price.toStringAsFixed(0)}',
                    style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                const Icon(Icons.watch_later_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${item.estimatedMinutes} Dk',
                    style: AppFonts.bodySmall(color: AppColors.textSecondary)),
              ],
            ),
            trailing: OutlinedButton(
              onPressed: () => vm.toggle(item),
              style: OutlinedButton.styleFrom(
                foregroundColor: selected ? AppColors.textOnPrimary : AppColors.primaryColor,
                backgroundColor: selected ? AppColors.primaryColor : Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(
                  color: selected ? Colors.transparent : AppColors.primaryColor.withOpacity(0.5),
                ),
              ),
              child: Text(selected ? 'Çıkar' : 'Ekle +'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(BuildContext context, SalonDetailViewModel vm) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
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
                  '${vm.totalCount} hizmet',
                  style: AppFonts.bodySmall(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                ),
                Text(
                  '₺${vm.totalPrice.toStringAsFixed(0)}',
                  style: AppFonts.poppinsBold(
                    color: AppColors.textOnPrimary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (vm.totalCount <= 0 || vm.salon == null) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      saloonId: vm.salon!.saloonId,
                      date: vm.selectedDate,
                      time: vm.selectedTime,
                      items: vm.selectedItems,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textOnPrimary,
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
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
    return Container(color: AppColors.background, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}