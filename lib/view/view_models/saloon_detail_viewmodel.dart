// lib/view/view_models/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/saloon_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/saloon_repository.dart';

// Yeni modeller (kategorili hizmet + seçim satırı)
import '../../data/models/category_with_services.dart';
import '../../data/models/selected_item.dart';

class SalonDetailViewModel extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // Repositories
  // (DI yapmadığın yerlerde default olarak Supabase.instance.client ile kurulur)
  // ────────────────────────────────────────────────────────────────────────────
  final SaloonRepository _saloonRepository;
  final FavoritesRepository _favoritesRepository;

  SalonDetailViewModel(SaloonRepository read, {
    SaloonRepository? saloonRepository,
    FavoritesRepository? favoritesRepository,
  })  : _saloonRepository =
      saloonRepository ?? SaloonRepository(Supabase.instance.client),
        _favoritesRepository =
            favoritesRepository ?? FavoritesRepository(Supabase.instance.client);

  // ────────────────────────────────────────────────────────────────────────────
  // State
  // ────────────────────────────────────────────────────────────────────────────
  SaloonModel? _salon;
  SaloonModel? get salon => _salon;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay get selectedTime => _selectedTime;

  /// Kategoriler ve her kategori altındaki salon hizmetleri
  List<CategoryWithServices> _categories = [];
  List<CategoryWithServices> get categories => List.unmodifiable(_categories);

  /// Seçili hizmetler (serviceId -> SelectedItem)
  final Map<String, SelectedItem> _selected = {};

  /// Toplam adet / fiyat / süre
  int get totalCount => _selected.values.fold(0, (a, b) => a + b.quantity);
  double get totalPrice =>
      _selected.values.fold(0.0, (a, b) => a + b.lineTotal);
  int get totalMinutes =>
      _selected.values.fold(0, (a, b) => a + b.service.estimatedMinutes);

  /// Seçili kalemleri liste olarak almak için
  List<SelectedItem> get selectedItems => _selected.values.toList();

  // ────────────────────────────────────────────────────────────────────────────
  // Backward‑compat: Eski ekranların beklediği API (ServiceModel tabanlı)
  //  - selectedServices (READ-ONLY bir liste; SelectedItem -> ServiceModel map)
  //  - toggleService(ServiceModel)
  //  - isServiceSelected(ServiceModel)
  // ────────────────────────────────────────────────────────────────────────────

  /// Eski kodların okuması için, seçimi ServiceModel listesine yansıtırız.
  List<ServiceModel> get selectedServices {
    return _selected.values.map((e) {
      return ServiceModel(
        serviceId: e.service.serviceId,
        serviceName: e.service.serviceName,
        basePrice: e.service.price,
        // Tahmini süreyi dakika olarak alıyoruz
        estimatedTime: Duration(minutes: e.service.estimatedMinutes),
      );
    }).toList(growable: false);
  }

  /// Eski methodu yeni seçim yapısına adapte eder.
  void toggleService(ServiceModel service) {
    final item = SaloonServiceItem(
      serviceId: service.serviceId,
      serviceName: service.serviceName,
      price: service.basePrice,
      estimatedMinutes: service.estimatedTime.inMinutes,
    );
    toggle(item);
  }

  /// Eski methodu yeni seçim yapısına adapte eder.
  bool isServiceSelected(ServiceModel service) {
    return _selected.containsKey(service.serviceId);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Data yükleme
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchSalonDetails(String saloonId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _saloonRepository.getSaloonById(saloonId),
        _saloonRepository.getSaloonCategoriesWithServices(saloonId), // ✅ burası
      ]);

      _salon = results[0] as SaloonModel?;
      _categories = (results[1] as List<CategoryWithServices>);

      // (İsteğe bağlı) debug:
      // debugPrint('[VM] salon.services=${_salon?.services.length ?? 0}, categories=${_categories.length}');
    } catch (e) {
      debugPrint('SalonDetailViewModel Hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // ────────────────────────────────────────────────────────────────────────────
  // Favori
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> toggleFavorite() async {
    if (_salon == null) return;

    final prev = _isFavorite;
    _isFavorite = !prev;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _favoritesRepository.addFavorite(_salon!.saloonId);
      } else {
        await _favoritesRepository.removeFavorite(_salon!.saloonId);
      }
    } catch (e) {
      _isFavorite = prev;
      notifyListeners();
      debugPrint('Favori işlemi hatası: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Seçim yönetimi (yeni)
  // ────────────────────────────────────────────────────────────────────────────
  bool isSelected(String serviceId) => _selected.containsKey(serviceId);

  void toggle(SaloonServiceItem item) {
    if (_selected.containsKey(item.serviceId)) {
      _selected.remove(item.serviceId);
    } else {
      _selected[item.serviceId] =
          SelectedItem(service: item, quantity: 1);
    }
    notifyListeners();
  }

  void incQty(String serviceId) {
    final cur = _selected[serviceId];
    if (cur == null) return;
    _selected[serviceId] = cur.copyWith(quantity: cur.quantity + 1);
    notifyListeners();
  }

  void decQty(String serviceId) {
    final cur = _selected[serviceId];
    if (cur == null) return;
    if (cur.quantity <= 1) {
      _selected.remove(serviceId);
    } else {
      _selected[serviceId] = cur.copyWith(quantity: cur.quantity - 1);
    }
    notifyListeners();
  }

  void clearSelections() {
    _selected.clear();
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Tarih/Saat seçimi
  // ────────────────────────────────────────────────────────────────────────────
  void selectNewDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectNewTime(TimeOfDay t) {
    _selectedTime = t;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Randevu oluşturma (RPC: create_reservation)
  //  - SQL fonksiyonunun auth.uid() fallback’li sürümünü kullandığını varsayıyorum.
  //    (Aksi halde userId parametresini gönder)
  // ────────────────────────────────────────────────────────────────────────────
  Future<String?> createReservation({
    String? userId,          // opsiyonel (SQL’de auth.uid() varsa null verilebilir)
    String? personalId,      // opsiyonel
  }) async {
    if (_salon == null) {
      throw Exception('Salon bilgisi yüklenmedi.');
    }
    if (_selected.isEmpty) {
      throw Exception('Lütfen en az bir hizmet seçin.');
    }

    final client = Supabase.instance.client;

    final String reservationTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    try {
      final params = <String, dynamic>{
        'p_user_id'          : userId, // null ise SQL tarafında auth.uid() devreye girer
        'p_saloon_id'        : _salon!.saloonId,
        'p_personal_id'      : personalId,
        'p_reservation_date' : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day).toIso8601String(),
        'p_reservation_time' : reservationTime,
        'p_items'            : selectedItems.map((e) => e.toRpcJson()).toList(),
      };

      final res = await client.rpc('create_reservation', params: params);
      // Başarılıysa fonksiyon reservation_id döndürür
      clearSelections();
      return res?.toString();
    } catch (e) {
      debugPrint('createReservation Hata: $e');
      rethrow;
    }
  }
}
