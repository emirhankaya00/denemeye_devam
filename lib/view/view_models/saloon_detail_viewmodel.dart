// lib/view/view_models/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/personal_model.dart';
import '../../data/models/reservation_model.dart';
import '../../data/models/saloon_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../data/repositories/saloon_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  // Sizin sağladığınız repository'ler kullanılıyor.
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);
  final ReservationRepository _reservationRepository = ReservationRepository(Supabase.instance.client);
  final FavoritesRepository _favoritesRepository = FavoritesRepository(Supabase.instance.client);

  // --- STATE DEĞİŞKENLERİ ---
  SaloonModel? _salon;
  SaloonModel? get salon => _salon;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  // --- YENİ TASARIM İÇİN GÜNCELLENEN STATE'LER ---
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // Tek bir servis yerine seçilen servislerin LİSTESİ tutuluyor.
  final List<ServiceModel> _selectedServices = [];
  List<ServiceModel> get selectedServices => List.unmodifiable(_selectedServices);

  // Seçilen servislerin toplam fiyatını anlık olarak hesaplayan getter.
  double get totalPrice {
    if (_selectedServices.isEmpty) return 0.0;
    return _selectedServices.fold(0.0, (sum, item) => sum + item.basePrice);
  }

  // --- VERİ ÇEKME VE YÖNETİM FONKSİYONLARI ---

  Future<void> fetchSalonDetails(String salonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Gerekli tüm verileri paralel olarak çekiyoruz.
      final results = await Future.wait([
        _saloonRepository.getSaloonById(salonId),
        _favoritesRepository.isFavorite(salonId),
        // _saloonRepository.getEmployeesBySaloon(salonId), // İhtiyaç halinde eklenebilir.
      ]);

      _salon = results[0] as SaloonModel?;
      _isFavorite = results[1] as bool;
      // _employees = results[2] as List<PersonalModel>;

    } catch (e) {
      debugPrint("SalonDetailViewModel Hata: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FAVORİ YÖNETİMİ ---
  Future<void> toggleFavorite() async {
    if (salon == null) return;

    // Geçici olarak favori durumunu anında güncelleyerek arayüzü akıcı hale getiriyoruz.
    _isFavorite = !_isFavorite;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _favoritesRepository.addFavorite(salon!.saloonId);
      } else {
        await _favoritesRepository.removeFavorite(salon!.saloonId);
      }
    } catch (e) {
      // Hata durumunda eski duruma geri dön
      _isFavorite = !_isFavorite;
      notifyListeners();
      debugPrint("Favori işlemi hatası: $e");
    }
  }

  // --- RANDEVU SÜRECİ YÖNETİMİ ---

  void selectNewDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Bir servisi seçme veya seçimi kaldırma mantığı.
  void toggleService(ServiceModel service) {
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners(); // Toplam fiyatın ve butonların güncellenmesi için arayüzü bilgilendir.
  }

  // Bir servisin listede (seçili) olup olmadığını kontrol eder.
  bool isServiceSelected(ServiceModel service) {
    return _selectedServices.contains(service);
  }

  // Seçilen tüm servisleri ve seçimleri temizler.
  void clearSelections() {
    _selectedServices.clear();
    // selectedTimeSlot = null; // Zaman seçimi varsa o da temizlenmeli.
    notifyListeners();
  }

  // TODO: Randevu oluşturma fonksiyonu, artık bir liste olan _selectedServices'i
  // ve totalPrice'ı kullanarak güncellenmelidir.
  Future<void> createReservation() async {
    if (salon == null || selectedServices.isEmpty) {
      throw Exception('Lütfen en az bir hizmet seçin.');
    }
    // ...
    // Gerekli mantık (örneğin reservation_services tablosuna çoklu kayıt)
    // burada uygulanmalıdır.
    // ...

    // İşlem sonrası seçimleri temizle
    clearSelections();
  }
}