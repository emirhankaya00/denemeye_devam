import 'package:denemeye_devam/models/PersonalModel.dart';
import 'package:denemeye_devam/models/ReservationModel.dart';
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:denemeye_devam/models/ServiceModel.dart';
import 'package:flutter/material.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:denemeye_devam/repositories/reservation_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:denemeye_devam/repositories/favorites_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);
  final ReservationRepository _reservationRepository = ReservationRepository(Supabase.instance.client);
  final FavoritesRepository _favoritesRepository = FavoritesRepository(Supabase.instance.client);

  // --- STATE DEĞİŞKENLERİ ---
  bool isFavorite = false;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SaloonModel? _salon;
  SaloonModel? get salon => _salon;

  List<PersonalModel> _employees = [];
  List<PersonalModel> get employees => _employees;

  // Randevu alma süreci için
  DateTime? selectedDate;
  String? selectedTimeSlot;
  ServiceModel? selectedService;
  PersonalModel? selectedEmployee;

  // --- ANA VERİ ÇEKME FONKSİYONU ---
  Future<void> fetchSalonDetails(String salonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _saloonRepository.getSaloonById(salonId),
        _saloonRepository.getEmployeesBySaloon(salonId),
      ]);

      _salon = results[0] as SaloonModel?;
      _employees = results[1] as List<PersonalModel>;
      selectedDate = DateTime.now();
    } catch (e) {
      print("fetchSalonDetails Hata: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- RANDEVU SÜRECİ YÖNETİMİ ---
  void selectNewDate(DateTime date) {
    selectedDate = date;
    // Yeni tarih seçildiğinde, saat/çalışan gibi seçimleri sıfırla
    selectedTimeSlot = null;
    selectedEmployee = null;
    notifyListeners();
  }

  void selectTime(String time) {
    selectedTimeSlot = time;
    notifyListeners();
  }

  void selectServiceForAppointment(ServiceModel service) {
    selectedService = service;
    notifyListeners();
  }

  void selectEmployeeForAppointment(PersonalModel employee) {
    selectedEmployee = employee;
    notifyListeners();
  }

  // --- RANDEVU OLUŞTURMA FONKSİYONU ---
  Future<void> createReservation() async {
    // Gerekli tüm bilgiler seçilmiş mi diye kontrol et
    if (salon == null ||
        selectedDate == null ||
        selectedTimeSlot == null ||
        selectedService == null ||
        selectedEmployee == null) {
      throw Exception('Lütfen randevu için tüm alanları seçin.');
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Randevu oluşturmak için giriş yapmalısınız.');
    }

    final newReservation = ReservationModel(
      reservationId: '', // DB kendi atayacak
      userId: userId,
      saloonId: salon!.saloonId,
      personalId: selectedEmployee!.personalId,
      reservationDate: selectedDate!,
      reservationTime: selectedTimeSlot!,
      totalPrice: selectedService!.basePrice, // Fiyatı hizmetten al
      status: ReservationStatus.pending, // Başlangıç durumu
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Repository aracılığıyla randevuyu veritabanına kaydet
    await _reservationRepository.createReservation(newReservation);

    // İşlem sonrası seçimleri temizle
    selectedTimeSlot = null;
    selectedService = null;
    selectedEmployee = null;
    notifyListeners();
  }
  Future<void> toggleFavorite() async {
    if (salon == null) return;

    // Mevcut durumun tersini yap
    if (isFavorite) {
      await _favoritesRepository.removeFavorite(salon!.saloonId);
    } else {
      await _favoritesRepository.addFavorite(salon!.saloonId);
    }

    // Durumu güncelle ve arayüzü bilgilendir
    isFavorite = !isFavorite;
    notifyListeners();
  }
}