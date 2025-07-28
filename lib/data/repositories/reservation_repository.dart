// lib/data/repositories/reservation_repository.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reservation_model.dart';
import '../models/reservation_list_item.dart';
import '../models/selected_item.dart';

class ReservationRepository {
  final SupabaseClient _client;
  ReservationRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  // ────────────────────────────────────────────────────────────────────────────
  // MEVCUT METOTLAR (DEĞİŞTİRİLMEDİ)
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
  // KULLANICI AKSİYONLARI (LİSTE, İPTAL, DÜZENLEME, TEKLİFE YANIT)
  // ────────────────────────────────────────────────────────────────────────────

  // DÜZELTME: is_revision_request alanı sorguya eklendi.
  static const String _listSelect = '''
    reservation_id, saloon_id, reservation_date, reservation_time, status, total_price, proposed_date, is_revision_request,
    saloons(saloon_name, title_photo_url),
    reservation_services(
      quantity,
      service_price_at_res,
      services(service_id, service_name, estimated_time)
    )
  ''';

  Future<List<ReservationListItem>> getMyReservationsLite() async {
    if (_userId == null) {
      debugPrint('getMyReservationsLite: userId null, boş liste dönüyorum.');
      return [];
    }

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
          .eq('user_id', _userId!)
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
  /// 2) Yeni seçilen servisleri ekler
  /// 3) reservations.status → 'pending'
  /// 4) reservations.is_revision_request → true (DÜZELTME)
  Future<bool> requestEdit({
    required String reservationId,
    required List<SelectedItem> items,
  }) async {
    if (_userId == null) return false;

    try {
      // 1) Mevcut hizmet satırlarını sil
      await _client
          .from('reservation_services')
          .delete()
          .eq('reservation_id', reservationId);

      // 2) Yeni hizmet satırlarını oluştur ve ekle
      final rows = items.map((e) {
        final linePrice = e.service.price;
        return {
          'reservation_id': reservationId,
          'service_id': e.service.serviceId,
          'quantity': 1,
          'service_price_at_res': linePrice,
        };
      }).toList();

      if (rows.isNotEmpty) {
        await _client.from('reservation_services').insert(rows);
      }

      // 3) Ana randevu kaydını "revize talebi" olarak güncelle
      await _client.from('reservations').update({
        'status': 'pending',
        'is_revision_request': true, // DÜZELTME: Bu talebin bir revizyon olduğunu işaretle
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('reservation_id', reservationId).eq('user_id', _userId!);

      return true;
    } catch (e) {
      debugPrint('requestEdit error: $e');
      return false;
    }
  }

  Future<bool> canUserComment(String saloonId) async {
    if (_userId == null) return false;

    try {
      final response = await _client
          .from('reservations')
          .select('reservation_id')
          .eq('user_id', _userId!)
          .eq('saloon_id', saloonId)
          .eq('status', 'completed') // Sadece tamamlanmış randevuları say
          .limit(1); // Sadece bir tane bulmamız yeterli

      // Eğer en az bir kayıt bulunduysa, liste boş olmayacaktır.
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('canUserComment hatası: $e');
      return false; // Hata durumunda yetki yok say
    }
  }

  /// Kullanıcının, salonun yeni tarih teklifine yanıt vermesini sağlar.
  /// Supabase'deki 'respond_to_reservation_offer' RPC fonksiyonunu çağırır.
  Future<void> respondToOffer(String reservationId, {required bool accept}) async {
    if (_userId == null) {
      throw Exception("Kullanıcı girişi yapılmamış.");
    }
    try {
      await _client.rpc('respond_to_reservation_offer', params: {
        'p_reservation_id': reservationId,
        'p_accepted': accept,
      });
    } catch (e) {
      debugPrint("respondToOffer repository hatası: $e");
      throw Exception("Teklife yanıt verilirken bir veritabanı hatası oluştu.");
    }
  }
}