// lib/data/repositories/reservation_repository.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reservation_model.dart';

class ReservationRepository {
  final SupabaseClient _client;
  ReservationRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

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
      // SORGUNUZ ZATEN DOĞRU: Rezervasyonları, ilişkili salon ve hizmet bilgileriyle birlikte çekiyoruz.
      // Supabase, 'saloons' tablosundan ilgili kaydı ve ara tablodan ('reservation_services')
      // hizmet detaylarını ('services') getirecektir.
      final data = await _client
          .from('reservations')
          .select('*, saloons(*), reservation_services(*, services(*))')
          .eq('user_id', _userId!);

      // Gelen verinin doğru parse edildiğinden emin olalım.
      // Hata ayıklama için gelen veriyi yazdırabilirsiniz: debugPrint(data.toString());

      if (data.isEmpty) {
        return [];
      }

      // Gelen her bir JSON objesini ReservationModel'e çeviriyoruz.
      // Hata yönetimi ekleyerek hangi verinin parse edilemediğini görebiliriz.
      return data.map((item) {
        try {
          return ReservationModel.fromJson(item);
        } catch (e) {
          debugPrint('Rezervasyon parse hatası: $e - Veri: $item');
          return null;
        }
      }).whereType<ReservationModel>().toList(); // Sadece başarılı parse edilenleri listeye ekle

    } catch (e) {
      debugPrint('getReservationsForUser Hata: $e');
      throw Exception('Randevular getirilirken bir hata oluştu.');
    }
  }

  Future<void> updateReservationStatus(String reservationId, ReservationStatus status) async {
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
}