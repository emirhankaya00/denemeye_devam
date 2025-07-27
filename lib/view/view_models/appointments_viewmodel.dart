// lib/view/view_models/appointments_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/reservation_repository.dart';

// Liste ekranı için hafif model
import '../../data/models/reservation_list_item.dart';
// Düzenleme talebi/tekrar oluştur için seçili hizmet modeli (gerekirse)
import '../../data/models/selected_item.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final ReservationRepository _repository =
  ReservationRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Tüm randevular (hafif model)
  List<ReservationListItem> _allAppointments = [];
  List<ReservationListItem> get allAppointments => _allAppointments;

  AppointmentsViewModel() {
    fetchAppointments();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // YÜKLEME
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Hafif liste uç noktasını kullan
      _allAppointments = await _repository.getMyReservationsLite();

      // En yeni en üstte
      _allAppointments.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('AppointmentsViewModel.fetchAppointments error: $e');
      _allAppointments = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchAppointments();

  // ────────────────────────────────────────────────────────────────────────────
  // İPTAL / DÜZENLEME TALEBİ
  // ────────────────────────────────────────────────────────────────────────────

  /// Sıkı iptal: yalnızca pending/approved (veya SQL tarafında izin verilen) randevuları
  /// kullanıcı iptali olarak kapatır.
  Future<bool> cancelAppointmentStrict(String reservationId) async {
    try {
      final ok = await _repository.cancelReservation(reservationId);
      await fetchAppointments();
      return ok;
    } catch (e) {
      debugPrint('cancelAppointmentStrict error: $e');
      return false;
    }
  }

  /// Düzenleme talebi – mevcut satırları siler, verilen items ile yeniden ekler,
  /// randevuyu "pending"e çeker.
  Future<bool> requestEdit({
    required String reservationId,
    required List<SelectedItem> items,
  }) async {
    try {
      final ok = await _repository.requestEdit(
        reservationId: reservationId,
        items: items,
      );
      await fetchAppointments();
      return ok;
    } catch (e) {
      debugPrint('requestEdit error: $e');
      return false;
    }
  }
}
