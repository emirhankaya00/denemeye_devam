// lib/view/screens/appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../data/models/reservation_list_item.dart';
import '../../view_models/appointments_viewmodel.dart';
import '../appointments/salon_detail_screen.dart';

/// Status metinleri (chip)
String _displayText(String status) {
  switch (status) {
    case 'pending':
      return 'Onay bekliyor';
    case 'approved':
      return 'Onaylandı';
    case 'rejected':
      return 'Salon reddetti';
    case 'canceled_by_user':
    case 'cancelled_by_user':
      return 'Kullanıcı iptal etti';
    case 'canceled_by_salon':
    case 'cancelled_by_salon':
      return 'Salon iptal etti';
    default:
      return status;
  }
}

enum _SectionType { upcoming, past, canceled }

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentsViewModel>();

    // --- Listeleri ayır ---
    final now = DateTime.now();

    bool _isCanceledStatus(String s) =>
        s == 'canceled_by_user' ||
            s == 'cancelled_by_user' ||
            s == 'canceled_by_salon' ||
            s == 'cancelled_by_salon';

    // Gelecek: zaman > şimdi ve status pending/approved (iptal/reddedilmiş olanlar burada görünmez)
    final upcoming = vm.allAppointments
        .where((r) =>
    r.date.isAfter(now) &&
        (r.status == 'pending' || r.status == 'approved'))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Geçmiş: zaman <= şimdi (iptaller hariç); rejected/completed/no_show vs burada tutulabilir
    final past = vm.allAppointments
        .where((r) => !r.date.isAfter(now) && !_isCanceledStatus(r.status))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // İptal edilenler: kullanıcı veya salon iptali (zamandan bağımsız)
    final canceled = vm.allAppointments
        .where((r) => _isCanceledStatus(r.status))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.background,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SegmentedTabBar3(),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: vm.isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        )
            : TabBarView(
          children: [
            _ListSection(
              list: upcoming,
              type: _SectionType.upcoming,
            ),
            _ListSection(
              list: past,
              type: _SectionType.past,
            ),
            _ListSection(
              list: canceled,
              type: _SectionType.canceled,
            ),
          ],
        ),
      ),
    );
  }
}

/// 3 parçalı segmented tab bar
class _SegmentedTabBar3 extends StatelessWidget {
  const _SegmentedTabBar3();

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth / 3;

          return Stack(
            children: [
              // Mavi seçili arka plan
              AnimatedBuilder(
                animation: controller!,
                builder: (_, __) {
                  final idx = controller.index.toDouble();
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    left: idx * w,
                    top: 0,
                    bottom: 0,
                    width: w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
              TabBar(
                indicatorColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  _SegLabel3(text: 'Gelecek\nRandevularım', index: 0),
                  _SegLabel3(text: 'Geçmiş\nRandevularım', index: 1),
                  _SegLabel3(text: 'İptal\nEdilenler', index: 2),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegLabel3 extends StatelessWidget {
  final String text;
  final int index;
  const _SegLabel3({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller!,
      builder: (_, __) {
        final selected = controller.index == index;
        return Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.poppinsBold(
              fontSize: 13.5,
              color: selected ? AppColors.textOnPrimary : AppColors.primaryColor,
            ),
          ),
        );
      },
    );
  }
}

/// Liste bölümü
class _ListSection extends StatelessWidget {
  final List<ReservationListItem> list;
  final _SectionType type;
  const _ListSection({required this.list, required this.type});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      final msg = switch (type) {
        _SectionType.upcoming => 'Yaklaşan randevu yok.',
        _SectionType.past => 'Geçmiş randevu yok.',
        _SectionType.canceled => 'İptal edilen randevu yok.',
      };
      return Center(
        child: Text(msg, style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AppointmentCard(item: list[i], type: type),
    );
  }
}

/// Tek kart
class _AppointmentCard extends StatelessWidget {
  final ReservationListItem item;
  final _SectionType type;
  const _AppointmentCard({required this.item, required this.type});

  bool get _isUpcoming => type == _SectionType.upcoming;
  bool get _isCanceled => type == _SectionType.canceled;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy', 'tr_TR').format(item.date);
    final summary = _buildLineSummary(item);
    final price = '₺${item.totalPrice.toStringAsFixed(0)}';

    final bgColor =
    _isUpcoming ? AppColors.cardColor : AppColors.primaryColor.withOpacity(.06);

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
            // Başlık satırı + sağda kalp & status rozeti
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(item.saloonName,
                      style: AppFonts.poppinsBold(fontSize: 16)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.favorite_border,
                        color: AppColors.primaryColor.withOpacity(.5)),
                    const SizedBox(height: 6),
                    _statusBadge(item.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('İstanbul  •  5.0 Km',
                style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(summary,
                style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('$dateStr  •  $price',
                style: AppFonts.bodyMedium(color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            // Alt aksiyonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isUpcoming) ...[
                  // İptal butonu sadece upcoming + iptal olmayanlarda
                  TextButton(
                    onPressed: () => _onCancel(context, item),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Randevuyu iptal et',
                      style: AppFonts.bodyMedium(color: Colors.red.shade700),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _onRequestEdit(context, item),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Düzenleme talep et'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => _showInvoice(context, item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Hizmet detayı'),
                  ),
                  OutlinedButton(
                    onPressed: () => _onRecreate(context, item),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tekrar oluştur'),
                  ),
                ],
              ],
            ),
            if (_isCanceled)
              const SizedBox(height: 4), // iptal sekmesinde hafif boşluk
          ],
        ),
      ),
    );
  }

  String _buildLineSummary(ReservationListItem r) {
    if (r.lines.isEmpty) return 'Hizmet bilgisi yok';
    return r.lines.map((e) => '${e.serviceName} x ${e.quantity}').join('  +  ');
  }

  Widget _statusBadge(String status) {
    Color c;
    IconData ic;
    switch (status) {
      case 'approved':
        c = Colors.green;
        ic = Icons.check_circle;
        break;
      case 'pending':
        c = Colors.orange;
        ic = Icons.hourglass_bottom;
        break;
      case 'rejected':
        c = Colors.red;
        ic = Icons.cancel;
        break;
      case 'canceled_by_user':
      case 'cancelled_by_user':
        c = Colors.grey;
        ic = Icons.block;
        break;
      case 'canceled_by_salon':
      case 'cancelled_by_salon':
        c = Colors.grey;
        ic = Icons.no_accounts;
        break;
      default:
        c = AppColors.textSecondary;
        ic = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, size: 14, color: c),
          const SizedBox(width: 6),
          Text(_displayText(status), style: AppFonts.bodySmall(color: c)),
        ],
      ),
    );
  }

  // ——— Aksiyonlar ———

  Future<void> _onCancel(
      BuildContext context, ReservationListItem r) async {
    // Bu ekranın upcoming sekmesinde zaten iptal edilmiş öğe yok; yine de koruma olsun.
    final ok = await context
        .read<AppointmentsViewModel>()
        .cancelAppointmentStrict(r.reservationId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Randevu iptal edildi.' : 'İptal edilemedi.')),
    );
  }

  Future<void> _onRequestEdit(
      BuildContext context, ReservationListItem r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalonDetailScreen(saloonId: r.saloonId),
      ),
    );
  }

  Future<void> _onRecreate(
      BuildContext context, ReservationListItem r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalonDetailScreen(saloonId: r.saloonId),
      ),
    );
  }

  void _showInvoice(BuildContext context, ReservationListItem r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final dateStr = DateFormat('dd.MM.yyyy • HH:mm').format(r.date);
        final subtotal =
        r.lines.fold<double>(0, (a, e) => a + e.lineTotal);

        return Padding(
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
              Text('Hizmet Detayı',
                  style: AppFonts.poppinsBold(fontSize: 18)),
              const SizedBox(height: 6),
              Text('${r.saloonName} • $dateStr',
                  style: AppFonts.bodySmall(color: AppColors.textSecondary)),
              const Divider(height: 24),
              ...r.lines.map(
                    (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child:
                          Text(e.serviceName, style: AppFonts.bodyMedium())),
                      Text('₺${e.unitPrice.toStringAsFixed(0)}',
                          style: AppFonts.bodyMedium()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Toplam', style: AppFonts.poppinsBold()),
                  Text('₺${subtotal.toStringAsFixed(0)}',
                      style: AppFonts.poppinsBold()),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
