// lib/view/view_models/appointments_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/reservation_list_item.dart';
import '../../data/models/selected_item.dart';
import '../../data/repositories/reservation_repository.dart';

class AppointmentsViewModel extends ChangeNotifier {
  // Supabase client'ını doğrudan burada oluşturmak yerine,
  // bir dependency injection yapısı (örn: Provider, GetIt) ile sağlamak daha iyidir.
  // Şimdilik mevcut yapıyı koruyoruz.
  final ReservationRepository _repository =
  ReservationRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ReservationListItem> _allAppointments = [];
  List<ReservationListItem> get allAppointments => _allAppointments;

  AppointmentsViewModel() {
    fetchAppointments();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // VERİ YÜKLEME
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allAppointments = await _repository.getMyReservationsLite();
      // Sıralama zaten repository veya view'da yapılıyor, yine de burada tutabiliriz.
      _allAppointments.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('AppointmentsViewModel.fetchAppointments error: $e');
      _allAppointments = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchAppointments();

  // ──────────────────────────────────────────────────────────────────────────
  // KULLANICI AKSİYONLARI
  // ──────────────────────────────────────────────────────────────────────────

  /// Sıkı iptal: yalnızca pending/approved randevuları iptal eder.
  Future<bool> cancelAppointmentStrict(String reservationId) async {
    try {
      final ok = await _repository.cancelReservation(reservationId);
      // Başarılı olursa, lokal listeyi de güncelleyerek anında UI tepkisi sağla
      if (ok) {
        _allAppointments.removeWhere((r) => r.reservationId == reservationId);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('cancelAppointmentStrict error: $e');
      return false;
    }
  }

  /// Düzenleme talebi: Mevcut randevuyu günceller.
  Future<bool> requestEdit({
    required String reservationId,
    required List<SelectedItem> items,
  }) async {
    try {
      final ok = await _repository.requestEdit(
        reservationId: reservationId,
        items: items,
      );
      // Başarılı olursa tam yenileme yap
      if (ok) await fetchAppointments();
      return ok;
    } catch (e) {
      debugPrint('requestEdit error: $e');
      return false;
    }
  }

  // DÜZELTME: YENİ TEKLİFİ ONAYLAMA FONKSİYONU
  /// Kullanıcının, salonun yeni tarih teklifini kabul etmesini sağlar.
  Future<bool> acceptProposal(String reservationId) async {
    try {
      // Repository katmanı aracılığıyla veritabanını güncelle
      await _repository.respondToOffer(reservationId, accept: true);

      // Lokal listeyi de anında güncelle (yeni veri çekmeye gerek kalmadan)
      final index =
      _allAppointments.indexWhere((r) => r.reservationId == reservationId);
      if (index != -1) {
        final oldItem = _allAppointments[index];
        // Lokaldeki randevuyu, yeni tarih ve 'approved' status ile güncelle
        _allAppointments[index] = ReservationListItem(
          reservationId: oldItem.reservationId,
          saloonId: oldItem.saloonId,
          saloonName: oldItem.saloonName,
          saloonPhoto: oldItem.saloonPhoto,
          lines: oldItem.lines,
          totalPrice: oldItem.totalPrice,
          date: oldItem.proposedDate ?? oldItem.date, // Yeni tarihi ata!
          status: 'approved', // Statüyü onayla!
          proposedDate: null, // Artık teklif tarihi yok
        );
        notifyListeners(); // Arayüze "kendini güncelle" de
      }
      return true;
    } catch (e) {
      debugPrint("Teklif onayı başarısız: $e");
      return false;
    }
  }

  // DÜZELTME: YENİ TEKLİFİ REDDETME FONKSİYONU
  /// Kullanıcının, salonun yeni tarih teklifini reddetmesini sağlar.
  Future<bool> rejectProposal(String reservationId) async {
    try {
      // Repository katmanı aracılığıyla veritabanını güncelle
      await _repository.respondToOffer(reservationId, accept: false);

      // Lokal listeyi de güncelle
      final index =
      _allAppointments.indexWhere((r) => r.reservationId == reservationId);
      if (index != -1) {
        final oldItem = _allAppointments[index];
        // Lokaldeki randevunun durumunu 'kullanıcı tarafından iptal edildi' olarak güncelle
        _allAppointments[index] = ReservationListItem(
          reservationId: oldItem.reservationId,
          saloonId: oldItem.saloonId,
          saloonName: oldItem.saloonName,
          saloonPhoto: oldItem.saloonPhoto,
          lines: oldItem.lines,
          totalPrice: oldItem.totalPrice,
          date: oldItem.date,
          status: 'cancelled_by_user', // Statüyü iptal et
          proposedDate: null,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Teklif reddi başarısız: $e");
      return false;
    }
  }
}