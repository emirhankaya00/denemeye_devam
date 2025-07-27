// lib/view/screens/appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/reservation_list_item.dart';
import '../../view_models/appointments_viewmodel.dart';
import '../appointments/salon_detail_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();

    // VM’de upcoming/past getter’ları olmadığı için burada ayırıyoruz
    final now = DateTime.now();
    final upcoming = vm.allAppointments
        .where((r) => r.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // en yakın üstte

    final past = vm.allAppointments
        .where((r) => !r.date.isAfter(now))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // en yeni geçmiş üstte

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          toolbarHeight: 0, // başlık yok
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(68), // içerik 52 + (8 üst + 8 alt) = 68
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _SegmentedTabBar(),
            ),
          ),
        ),

        body: vm.isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        )
            : const TabBarView(
          children: [
            _ListSection(isUpcoming: true),
            _ListSection(isUpcoming: false),
          ],
        ),
      ),
    );
  }
}

/// Üstteki “Gelecek / Geçmiş” segmented görünümlü TabBar
class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52, // tasarımdaki yüksekliğe yakın
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white, // arka plan beyaz
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: TabBar(
            // Seçili segment: mavi dolu; seçili olmayan: beyaz + mavi yazı
            indicator: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(14),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4), // içte maviye “boşluk” efekti
            labelColor: AppColors.textOnPrimary,       // seçili yazı beyaz
            unselectedLabelColor: AppColors.primaryColor, // seçili olmayan mavi
            dividerColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            labelStyle: AppFonts.poppinsBold(fontSize: 16),
            unselectedLabelStyle: AppFonts.poppinsBold(fontSize: 16),
            tabs: const [
              Tab(text: 'Gelecek Randevularım'),
              Tab(text: 'Geçmiş Randevularım'),
            ],
          ),
        ),
      ),
    );
  }
}


/// Liste bölümünü çizer; veriyi provider’dan çeker
class _ListSection extends StatelessWidget {
  final bool isUpcoming;
  const _ListSection({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();
    final now = DateTime.now();

    final list = (isUpcoming
        ? vm.allAppointments.where((r) => r.date.isAfter(now))
        : vm.allAppointments.where((r) => !r.date.isAfter(now)))
        .toList()
      ..sort((a, b) => isUpcoming
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date));

    if (list.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'Yaklaşan randevu yok.' : 'Geçmiş randevu yok.',
          style: AppFonts.bodyMedium(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: vm.refresh,
      child: ListView.separated(
        // ↓ Segment butonları ile kartlar arasında daha fazla mesafe
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AppointmentCard(item: list[i], isUpcoming: isUpcoming),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final ReservationListItem item;
  final bool isUpcoming;
  const _AppointmentCard({required this.item, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM y • HH:mm', 'tr_TR').format(item.date);
    final servicesSummary = _buildServicesSummary(item);
    final priceStr = '₺${item.totalPrice.toStringAsFixed(0)}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.primaryColor.withOpacity(.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık satırı
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.saloonPhoto != null && item.saloonPhoto!.isNotEmpty
                      ? Image.network(item.saloonPhoto!, width: 56, height: 56, fit: BoxFit.cover)
                      : Image.asset('assets/map_placeholder.png',
                      width: 56, height: 56, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.saloonName, style: AppFonts.poppinsBold(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'İstanbul  •  5.0 Km',
                        style: AppFonts.bodySmall(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servicesSummary,
                        style: AppFonts.bodySmall(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$dateStr  •  $priceStr',
                        style: AppFonts.bodyMedium(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _HeartButton(),
              ],
            ),

            const SizedBox(height: 12),
            // Alt aksiyonlar
            Row(
              children: [
                if (isUpcoming)
                  TextButton(
                    onPressed: () => _onCancel(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Randevuyu iptal et',
                      style: AppFonts.bodyMedium(color: Colors.red.shade700),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _showInvoice(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Hizmet detayı'),
                  ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => isUpcoming ? _onRequestEdit(context) : _onRecreate(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isUpcoming ? 'Düzenleme talep et' : 'Tekrar oluştur'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildServicesSummary(ReservationListItem r) {
    if (r.lines.isEmpty) return 'Hizmet bilgisi yok';
    final parts = r.lines.map((e) => '${e.serviceName} × ${e.quantity}');
    return parts.join(' + ');
  }

  Future<void> _onCancel(BuildContext context) async {
    final ok = await context.read<AppointmentsViewModel>()
        .cancelAppointmentStrict(item.reservationId);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Randevu iptal edildi.' : 'İptal edilemedi.')),
    );
  }

  Future<void> _onRequestEdit(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalonDetailScreen(saloonId: item.saloonId)),
    );
  }

  Future<void> _onRecreate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalonDetailScreen(saloonId: item.saloonId)),
    );
  }

  void _showInvoice(BuildContext context) {
    final subtotal = item.lines.fold<double>(0, (a, e) => a + e.lineTotal);
    final dateStr = DateFormat('d MMM y • HH:mm', 'tr_TR').format(item.date);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Hizmet Detayı', style: AppFonts.poppinsBold(fontSize: 18)),
            const SizedBox(height: 6),
            Text('${item.saloonName} • $dateStr',
                style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const Divider(height: 24),
            ...item.lines.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(e.serviceName, style: AppFonts.bodyMedium())),
                  Text('₺${e.unitPrice.toStringAsFixed(0)}', style: AppFonts.bodyMedium()),
                ],
              ),
            )),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Toplam', style: AppFonts.poppinsBold()),
                Text('₺${subtotal.toStringAsFixed(0)}', style: AppFonts.poppinsBold()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartButton extends StatefulWidget {
  const _HeartButton();

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  bool fav = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => fav = !fav),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(.25)),
          color: AppColors.background,
        ),
        child: Icon(
          fav ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: fav ? Colors.red : AppColors.primaryColor,
        ),
      ),
    );
  }
}
