// lib/repositories/reservation_repository.dart
import 'package:denemeye_devam/models/ReservationModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  final SupabaseClient _client;
  ReservationRepository(this._client);

  Future<void> createReservation(ReservationModel reservation) async {
    try {
      // Modeli JSON'a çevirip 'reservations' tablosuna ekliyoruz.
      // reservationId veritabanı tarafından otomatik oluşturulacağı için yollamıyoruz.
      final reservationData = reservation.toJson()..remove('reservation_id');

      await _client.from('reservations').insert(reservationData);

    } catch (e) {
      print('createReservation Hata: $e');
      throw Exception('Randevu oluşturulurken bir hata oluştu.');
    }
  }
}