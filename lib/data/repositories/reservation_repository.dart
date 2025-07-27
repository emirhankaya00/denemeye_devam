import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reservation_model.dart';

// Lite liste modeli
import '../models/reservation_list_item.dart';
// Düzenleme talebi / tekrar oluştur için seçili satırlar
import '../models/selected_item.dart';

class ReservationRepository {
  final SupabaseClient _client;
  ReservationRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  // ────────────────────────────────────────────────────────────────────────────
  // VAR OLAN METOTLAR (dokunmadım)
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> createReservation(ReservationModel reservation) async {
    try {
      final reservationData = reservation.toJson()..remove('reservation_id');
      await _client.from('reservations').insert(reservationData);
    } catch (e) {
      debugPrint('createReservation Hata: $e');
      throw Exception('Randevu oluşturulurken bir hata oluştu.');
    }
  }

  Future<List<ReservationModel>> getReservationsForUser() async {
    if (_userId == null) return [];

    try {
      final data = await _client
          .from('reservations')
          .select('*, saloons(*), reservation_services(*, services(*))')
          .eq('user_id', _userId!);

      if (data.isEmpty) return [];

      return data.map((item) {
        try {
          return ReservationModel.fromJson(item);
        } catch (e) {
          debugPrint('Rezervasyon parse hatası: $e - Veri: $item');
          return null;
        }
      }).whereType<ReservationModel>().toList();
    } catch (e) {
      debugPrint('getReservationsForUser Hata: $e');
      throw Exception('Randevular getirilirken bir hata oluştu.');
    }
  }

  Future<void> updateReservationStatus(
      String reservationId,
      ReservationStatus status,
      ) async {
    try {
      await _client
          .from('reservations')
          .update({'status': status.name})
          .eq('reservation_id', reservationId);
    } catch (e) {
      debugPrint('updateReservationStatus Hata: $e');
      throw Exception('Randevu durumu güncellenirken bir hata oluştu.');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // LİSTE / İPTAL / DÜZENLEME TALEBİ
  // ────────────────────────────────────────────────────────────────────────────

  /// Liste ekranı için hafif SELECT (Lite)
  /// DİKKAT: fiyat kolonu reservation_services.service_price_at_res
  static const String _listSelect = '''
    reservation_id, saloon_id, reservation_date, reservation_time, status, total_price,
    saloons(saloon_name, title_photo_url),
    reservation_services(
      quantity,
      service_price_at_res,
      services(service_id, service_name, estimated_time)
    )
  ''';

  /// Kullanıcının randevularını hafif modelle döndürür (UI listeleri için ideal).
  Future<List<ReservationListItem>> getMyReservationsLite() async {
    if (_userId == null) {
      debugPrint('getMyReservationsLite: userId null, boş liste dönüyorum.');
      return [];
    }
    debugPrint('getMyReservationsLite: _userId = $_userId');

    try {
      final data = await _client
          .from('reservations')
          .select(_listSelect)
          .eq('user_id', _userId!)
          .order('reservation_date', ascending: false)
          .order('reservation_time', ascending: false);

      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map(ReservationListItem.fromJson)
          .toList();
    } catch (e) {
      debugPrint('getMyReservationsLite error: $e');
      return [];
    }
  }

  /// Pending/Approved durumdaki bir randevuyu kullanıcı iptal eder.
  Future<bool> cancelReservation(String reservationId) async {
    if (_userId == null) return false;
    try {
      final res = await _client
          .from('reservations')
          .update({
        'status': 'canceled_by_user',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('reservation_id', reservationId)
          .eq('user_id', _userId!) // !: yukarıda null check var
      // Supabase Dart için "in_" yerine "filter" ile IN kullanımı:
          .filter('status', 'in', ['pending', 'approved'])
          .select('reservation_id')
          .maybeSingle();

      return res != null;
    } catch (e) {
      debugPrint('cancelReservation error: $e');
      return false;
    }
  }

  /// Düzenleme talebi:
  /// 1) Eski reservation_services satırlarını siler
  /// 2) Yeni seçilen servisleri (qty=1) ekler
  /// 3) reservations.status → 'pending'
  ///
  /// Not: İdealde transaction/RPC ile yapılır; burada adım adım uyguluyoruz.
  Future<bool> requestEdit({
    required String reservationId,
    required List<SelectedItem> items,
  }) async {
    if (_userId == null) return false;

    try {
      // 1) mevcut satırları sil
      await _client
          .from('reservation_services')
          .delete()
          .eq('reservation_id', reservationId);

      // 2) yeni satırları ekle (qty=1, service_price_at_res := item.service.price)
      final rows = items.map((e) {
        final linePrice = e.service.price; // SelectedItem.service.price
        return {
          'reservation_id'      : reservationId,
          'service_id'          : e.service.serviceId,
          'quantity'            : 1,
          'service_price_at_res': linePrice,
        };
      }).toList();

      if (rows.isNotEmpty) {
        await _client.from('reservation_services').insert(rows);
      }

      // 3) status → pending
      await _client
          .from('reservations')
          .update({
        'status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('reservation_id', reservationId)
          .eq('user_id', _userId!);

      return true;
    } catch (e) {
      debugPrint('requestEdit error: $e');
      return false;
    }
  }
}
