// KULLANICI UYGULAMASI -> lib/view/screens/appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/reservation_list_item.dart';
import '../../view_models/appointments_viewmodel.dart';
import '../appointments/salon_detail_screen.dart';

String _displayText(String status) {
  // ... (Bu fonksiyon aynı kalabilir)
  switch (status) {
    case 'pending': return 'Onay Bekliyor';
    case 'approved': return 'Onaylandı';
    case 'offered': return 'Yeni Teklif Var';
    case 'rejected': return 'Salon Reddetti';
    case 'canceled_by_user':
    case 'cancelled_by_user': return 'İptal Ettin';
    case 'canceled_by_salon':
    case 'cancelled_by_salon': return 'Salon İptal Etti';
    default: return status;
  }
}

enum _SectionType { offered, upcoming, past, canceled }

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();
    final now = DateTime.now();

    // Filtreleme mantığı doğru, burada değişiklik yok.
    final offered = vm.allAppointments.where((r) => r.status == 'offered').toList();
    final upcoming = vm.allAppointments.where((r) => r.date.isAfter(now) && (r.status == 'pending' || r.status == 'approved')).toList();
    final past = vm.allAppointments.where((r) => !r.date.isAfter(now) && r.status != 'offered' && !['canceled_by_user', 'cancelled_by_user', 'canceled_by_salon', 'cancelled_by_salon'].contains(r.status)).toList();
    final canceled = vm.allAppointments.where((r) => ['canceled_by_user', 'cancelled_by_user', 'canceled_by_salon', 'cancelled_by_salon'].contains(r.status)).toList();

    offered.sort((a, b) => a.date.compareTo(b.date));
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    past.sort((a, b) => b.date.compareTo(a.date));
    canceled.sort((a, b) => b.date.compareTo(a.date));

    // DÜZELTME: Scaffold ve AppBar kaldırıldı.
    // Sayfa artık doğrudan DefaultTabController ile başlıyor ve bir Column içinde
    // TabBar ve TabBarView'ı barındırıyor.
    return DefaultTabController(
      length: 4,
      child: SafeArea( // Ekranın üst çentik gibi alanlarına taşmasını engeller
        child: Column(
          children: [
            // Sekme Barları (TabBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    color: AppColors.primaryColor),
                unselectedLabelColor: AppColors.textSecondary,
                labelColor: Colors.white,
                tabs: const [
                  Tab(text: 'Rezervasyon Önerisi'),
                  Tab(text: 'Gelecek'),
                  Tab(text: 'Geçmiş'),
                  Tab(text: 'İptal Edilenler'),
                ],
              ),
            ),

            // Yükleme durumu veya Sekme İçerikleri
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : TabBarView(
                children: [
                  _ListSection(list: offered, type: _SectionType.offered),
                  _ListSection(list: upcoming, type: _SectionType.upcoming),
                  _ListSection(list: past, type: _SectionType.past),
                  _ListSection(list: canceled, type: _SectionType.canceled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _ListSection ve _AppointmentCard widget'ları aynı kalabilir.
// ... (Önceki mesajdaki _ListSection ve _AppointmentCard kodları burada olacak)

class _ListSection extends StatelessWidget {
  final List<ReservationListItem> list;
  final _SectionType type;
  const _ListSection({required this.list, required this.type});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      final msg = switch (type) {
        _SectionType.offered => 'Yanıt bekleyen öneri yok.',
        _SectionType.upcoming => 'Yaklaşan randevu yok.',
        _SectionType.past => 'Geçmiş randevu yok.',
        _SectionType.canceled => 'İptal edilen randevu yok.',
      };
      return Center(
        child: Text(msg, style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AppointmentCard(item: list[i], type: type),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final ReservationListItem item;
  final _SectionType type;
  const _AppointmentCard({required this.item, required this.type});

  bool get _isOffered => type == _SectionType.offered;
  bool get _isUpcoming => type == _SectionType.upcoming;
  bool get _isCanceled => type == _SectionType.canceled;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(item.date);
    final summary = _buildLineSummary(item);
    final price = '₺${item.totalPrice.toStringAsFixed(0)}';
    final bgColor = AppColors.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(item.saloonName, style: AppFonts.poppinsBold(fontSize: 16))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.favorite_border, color: AppColors.primaryColor.withOpacity(.5)),
                    const SizedBox(height: 6),
                    _statusBadge(item.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('İstanbul  •  5.0 Km', style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(summary, style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('$dateStr  •  $price', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            if (_isOffered)
              _buildOfferedProposalActions(context)
            else if (_isUpcoming)
              _buildUpcomingActions(context)
            else if (!_isCanceled)
                _buildPastActions(context),
            if (_isCanceled) const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferedProposalActions(BuildContext context) {
    String proposedDateStr;
    final pDate = item.proposedDate;
    if (pDate != null) {
      proposedDateStr = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR').format(pDate);
    } else {
      proposedDateStr = 'Tarih belirtilmemiş';
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('Salonun Yeni Tarih Teklifi:', style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(proposedDateStr, style: AppFonts.poppinsBold(color: AppColors.primaryColor, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _onRejectProposal(context, item),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reddet'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _onAcceptProposal(context, item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Onayla'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildUpcomingActions(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      TextButton(
        onPressed: () => _onCancel(context, item),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Text('Randevuyu iptal et', style: AppFonts.bodyMedium(color: Colors.red.shade700)),
      ),
      OutlinedButton(
        onPressed: () => _onRequestEdit(context, item),
        style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Düzenleme talep et'),
      ),
    ]);
  }

  Widget _buildPastActions(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ElevatedButton(
        onPressed: () => _showInvoice(context, item),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Hizmet Detayı'),
      ),
      OutlinedButton(
        onPressed: () => _onRecreate(context, item),
        style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        child: const Text('Tekrar Oluştur'),
      ),
    ]);
  }

  String _buildLineSummary(ReservationListItem r) {
    if (r.lines.isEmpty) return 'Hizmet bilgisi yok';
    return r.lines.map((e) => '${e.serviceName} x ${e.quantity}').join('  +  ');
  }

  Widget _statusBadge(String status) {
    Color c; IconData ic;
    switch (status) {
      case 'approved': c = Colors.green; ic = Icons.check_circle; break;
      case 'pending': c = Colors.orange; ic = Icons.hourglass_bottom; break;
      case 'offered': c = AppColors.primaryColor; ic = Icons.swap_horiz; break;
      case 'rejected': c = Colors.red; ic = Icons.cancel; break;
      case 'canceled_by_user':
      case 'cancelled_by_user': c = Colors.grey; ic = Icons.block; break;
      case 'canceled_by_salon':
      case 'cancelled_by_salon': c = Colors.grey; ic = Icons.no_accounts; break;
      default: c = AppColors.textSecondary; ic = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: c.withOpacity(.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.withOpacity(.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, size: 14, color: c),
        const SizedBox(width: 6),
        Text(_displayText(status), style: AppFonts.bodySmall(color: c)),
      ]),
    );
  }

  Future<void> _onAcceptProposal(BuildContext context, ReservationListItem r) async {
    final ok = await context.read<AppointmentsViewModel>().acceptProposal(r.reservationId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Teklif onaylandı.' : 'İşlem başarısız.')));
  }

  Future<void> _onRejectProposal(BuildContext context, ReservationListItem r) async {
    final ok = await context.read<AppointmentsViewModel>().rejectProposal(r.reservationId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Teklif reddedildi.' : 'İşlem başarısız.')));
  }

  Future<void> _onCancel(BuildContext context, ReservationListItem r) async {
    final ok = await context.read<AppointmentsViewModel>().cancelAppointmentStrict(r.reservationId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Randevu iptal edildi.' : 'İptal edilemedi.')));
  }

  Future<void> _onRequestEdit(BuildContext context, ReservationListItem r) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => SalonDetailScreen(saloonId: r.saloonId)));
  }

  Future<void> _onRecreate(BuildContext context, ReservationListItem r) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => SalonDetailScreen(saloonId: r.saloonId)));
  }

  void _showInvoice(BuildContext context, ReservationListItem r) { /* ... */ }
}