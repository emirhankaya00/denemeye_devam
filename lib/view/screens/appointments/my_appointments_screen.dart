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
          title: Text('Randevularım', style: AppFonts.poppinsBold(color: AppColors.textPrimary)),
          backgroundColor: AppColors.background,
          bottom: const TabBar(tabs: [
            Tab(text: 'Yaklaşan'),
            Tab(text: 'Geçmiş'),
          ]),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : TabBarView(
          children: [
            _buildList(context, upcoming, upcoming: true),
            _buildList(context, past, upcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
      BuildContext context,
      List<ReservationListItem> list, {
        required bool upcoming,
      }) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          upcoming ? 'Yaklaşan randevu yok.' : 'Geçmiş randevu yok.',
          style: AppFonts.bodyMedium(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(context, list[i], upcoming: upcoming),
    );
  }

  Widget _card(BuildContext context, ReservationListItem r, {required bool upcoming}) {
    final dateStr = DateFormat('dd.MM.yyyy • HH:mm').format(r.date);

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: r.saloonPhoto != null && r.saloonPhoto!.isNotEmpty
              ? Image.network(r.saloonPhoto!, width: 56, height: 56, fit: BoxFit.cover)
              : Image.asset('assets/map_placeholder.png', width: 56, height: 56, fit: BoxFit.cover),
        ),
        title: Text(r.saloonName, style: AppFonts.poppinsBold()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: AppFonts.bodySmall(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            _statusChip(r.status),
          ],
        ),
        trailing: Text('₺${r.totalPrice.toStringAsFixed(0)}', style: AppFonts.poppinsBold()),
        onTap: () => _showInvoice(context, r), // geçmişte “Hizmet detayı”
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (upcoming) ...[
              TextButton(
                onPressed: () => _onRequestEdit(context, r),
                child: const Text('Düzenleme talep et'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _onCancel(context, r),
                child: const Text('İptal et'),
              ),
            ] else ...[
              TextButton(
                onPressed: () => _onRecreate(context, r),
                child: const Text('Tekrar oluştur'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _showInvoice(context, r),
                child: const Text('Hizmet detayı'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ——— Aksiyonlar ————————————————————————————————

  Future<void> _onCancel(BuildContext context, ReservationListItem r) async {
    // HATA DÜZELTME: cancelAppointment yerine cancelAppointmentStrict kullanıyoruz.
    final ok =
    await context.read<AppointmentsViewModel>().cancelAppointmentStrict(r.reservationId);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Randevu iptal edildi.' : 'İptal edilemedi.')),
    );
  }

  /// Düzenleme: Salon detayına gider; kullanıcı hizmet ekleyip/çıkarıp
  /// Checkout’ta “düzenleme talebi” olarak gönderebilir.
  Future<void> _onRequestEdit(BuildContext context, ReservationListItem r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalonDetailScreen(saloonId: r.saloonId),
      ),
    );
  }

  /// Geçmiş randevudan aynısını yeniden oluşturmak için salona yönlendir.
  Future<void> _onRecreate(BuildContext context, ReservationListItem r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalonDetailScreen(saloonId: r.saloonId),
      ),
    );
  }

  /// Alt sayfa — fatura görünümü
  void _showInvoice(BuildContext context, ReservationListItem r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final dateStr = DateFormat('dd.MM.yyyy • HH:mm').format(r.date);
        final subtotal = r.lines.fold<double>(0, (a, e) => a + e.lineTotal);

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
              Text('Hizmet Detayı', style: AppFonts.poppinsBold(fontSize: 18)),
              const SizedBox(height: 6),
              Text('${r.saloonName} • $dateStr',
                  style: AppFonts.bodySmall(color: AppColors.textSecondary)),
              const Divider(height: 24),
              ...r.lines.map((e) => Padding(
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
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    Color c = AppColors.textSecondary;
    switch (status) {
      case 'approved':
        c = Colors.green;
        break;
      case 'pending':
        c = Colors.orange;
        break;
      case 'rejected':
        c = Colors.red;
        break;
      case 'canceled_by_user':
        c = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: AppFonts.bodySmall(color: c)),
    );
  }
}
