// lib/features/notifications/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:denemeye_devam/viewmodels/appointments_viewmodel.dart';
import 'package:denemeye_devam/features/common/widgets/notification_card.dart';

import '../features/appointments/screens/appointments_screen.dart';
import '../models/reservation_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppointmentsViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      // Pull to refresh eklendi:
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.fetchAppointments,
        child: _buildList(context, vm),
      ),
    );
  }

  Widget _buildList(BuildContext context, AppointmentsViewModel vm) {
    final items = [...vm.allAppointments]
    ..sort((a,b) => b.createdAt.compareTo(a.createdAt));
    // Tarihe göre grupla
    final grouped = _groupByDate(items);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(), // RefreshIndicator için
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              entry.key,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final res in entry.value)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AppointmentsScreen(),
                ),
              ),
              child: NotificationCard(
                title: res.saloon?.saloonName ?? '—',
                message: _messageForStatus(res.status),
                timeAgo: _timeAgo(res.createdAt),
                badgeCount: 1,
              ),
            ),
        ],
      ],
    );
  }

  /// Bugün, Dün yoksa tam tarih başlığı
  static Map<String, List> _groupByDate(List list) {
    final Map<String, List> map = {};
    final now = DateTime.now();
    for (var item in list) {
      final dt = item.createdAt;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(dt.year, dt.month, dt.day))
          .inDays;
      String key;
      if (diff == 0) key = 'Bugün';
      else if (diff == 1) key = 'Dün';
      else key = DateFormat('dd MMMM yyyy', 'tr').format(dt);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Rezervasyon durumuna göre gösterilecek metin
  static String _messageForStatus(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return 'randevunuz onaylandı';
      case ReservationStatus.cancelled:
        return 'randevunuz iptal edildi';
      case ReservationStatus.completed:
        return 'randevunuz tamamlandı';
      case ReservationStatus.noShow:
        return 'randevunuza katılmadınız';
      default:
        return 'randevu durumu güncellendi';
    }
  }

  /// “5 dakika önce” / “2 saat önce” / “3 gün önce”
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'şimdi';
    if (diff.inHours < 1) return '${diff.inMinutes} dakika önce';
    if (diff.inDays < 1) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }
}
