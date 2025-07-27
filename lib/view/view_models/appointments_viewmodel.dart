// lib/view/view_models/appointments_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/reservation_model.dart';
import '../../data/repositories/reservation_repository.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final ReservationRepository _repository = ReservationRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ReservationModel> _allAppointments = [];
  List<ReservationModel> get allAppointments => _allAppointments;

  // ViewModel oluşturulduğunda verileri çek
  AppointmentsViewModel() {
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allAppointments = await _repository.getReservationsForUser();
      // Tarihe göre sıralama (en yeni en üstte olacak şekilde)
      _allAppointments.sort((a, b) {
        final aDateTime = a.reservationDate.add(Duration(hours: int.parse(a.reservationTime.split(':')[0]), minutes: int.parse(a.reservationTime.split(':')[1])));
        final bDateTime = b.reservationDate.add(Duration(hours: int.parse(b.reservationTime.split(':')[0]), minutes: int.parse(b.reservationTime.split(':')[1])));
        return bDateTime.compareTo(aDateTime);
      });

    } catch (e) {
      debugPrint('AppointmentsViewModel Hata: $e');
      _allAppointments = []; // Hata durumunda listeyi boşalt
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelAppointment(String reservationId) async {
    try {
      await _repository.updateReservationStatus(reservationId, ReservationStatus.cancelled);
      // İşlem başarılı olduktan sonra listeyi en güncel haliyle yeniden çek.
      await fetchAppointments();
    } catch (e) {
      debugPrint('Randevu iptal edilemedi: $e');
      // Hata durumunda kullanıcıya bilgi vermek için rethrow et.
      rethrow;
    }
  }
}