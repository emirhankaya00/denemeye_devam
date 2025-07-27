// lib/view/view_models/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/saloon_model.dart';
import '../../data/models/selected_item.dart';
import '../../data/models/category_with_services.dart';
import '../../data/repositories/saloon_repository.dart';
import '../../data/repositories/favorites_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  SalonDetailViewModel(this._saloonRepo);

  final SaloonRepository _saloonRepo;
  final FavoritesRepository _favoritesRepo =
  FavoritesRepository(Supabase.instance.client);


  // --- STATE ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SaloonModel? _salon;
  SaloonModel? get salon => _salon;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  /// Dinamik kategoriler + hizmetler (RPC’den)
  final List<CategoryWithServices> _categories = [];
  List<CategoryWithServices> get categories => List.unmodifiable(_categories);

  /// Seçili hizmetler (adet mantığı YOK — her servis 1 kere seçilebilir)
  final List<SelectedItem> _selectedItems = [];
  List<SelectedItem> get selectedItems => List.unmodifiable(_selectedItems);

  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay get selectedTime => _selectedTime;

  // --- COMPUTED ---
  int get totalCount => _selectedItems.length;

  double get totalPrice =>
      _selectedItems.fold(0.0, (sum, e) => sum + e.lineTotal);

  // --- LOAD ---
  Future<void> fetchSalonDetails(String saloonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _saloonRepo.getSaloonById(saloonId),
        _saloonRepo.getSaloonCategoriesWithServices(saloonId),
      ]);

      _salon = results[0] as SaloonModel?;
      final cats = results[1] as List<CategoryWithServices>;
      _categories
        ..clear()
        ..addAll(cats);

      // Favori durumu
      if (_salon != null) {
        _isFavorite = await _favoritesRepo.isFavorite(_salon!.saloonId);
      }
    } catch (e) {
      debugPrint('SalonDetailViewModel.fetchSalonDetails Hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FAVORİ ---
  Future<void> toggleFavorite() async {
    if (_salon == null) return;
    _isFavorite = !_isFavorite;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _favoritesRepo.addFavorite(_salon!.saloonId);
      } else {
        await _favoritesRepo.removeFavorite(_salon!.saloonId);
      }
    } catch (e) {
      // geri al
      _isFavorite = !_isFavorite;
      notifyListeners();
    }
  }

  // --- DATE/TIME ---
  void selectNewDate(DateTime d) {
    _selectedDate = d;
    notifyListeners();
  }

  void selectNewTime(TimeOfDay t) {
    _selectedTime = t;
    notifyListeners();
  }

  // --- SEÇİM MANTIĞI (adet yok) ---
  bool isSelected(String serviceId) {
    return _selectedItems.any((e) => e.service.serviceId == serviceId);
  }

  /// YALNIZCA ekle/çıkar. Adet yok → her servis en fazla 1.
  void toggle(SaloonServiceItem item) {
    final idx = _selectedItems.indexWhere(
          (e) => e.service.serviceId == item.serviceId,
    );
    if (idx >= 0) {
      _selectedItems.removeAt(idx);
    } else {
      _selectedItems.add(SelectedItem(
        service: item,
        quantity: 1, // sabit
      ));
    }
    notifyListeners();
  }

  void preselectByServiceIds(List<String> ids) {
    final idSet = ids.toSet();
    for (final cat in _categories) {
      for (final item in cat.services) {
        if (idSet.contains(item.serviceId) && !isSelected(item.serviceId)) {
          _selectedItems.add(SelectedItem(
            service: item,
            quantity: 1,
          ));
        }
      }
    }
    notifyListeners();
  }

  /// Eski ServiceModel listesi için uyumluluk (projenizde referans varsa)
  final List<ServiceModelCompat> _legacySelected = [];
  bool isServiceSelected(ServiceModelCompat s) =>
      _legacySelected.any((e) => e.serviceId == s.serviceId);

  void toggleService(ServiceModelCompat s) {
    final i = _legacySelected.indexWhere((e) => e.serviceId == s.serviceId);
    if (i >= 0) {
      _legacySelected.removeAt(i);
    } else {
      _legacySelected.add(s);
    }
    notifyListeners();
  }

  // --- TEMİZLE ---
  void clearSelections() {
    _selectedItems.clear();
    _legacySelected.clear();
    notifyListeners();
  }
}

/// Eski ServiceModel yapınıza uyumluluk için küçük bir köprü.
/// Eğer gerekmiyorsa kaldırabilirsiniz.
class ServiceModelCompat {
  final String serviceId;
  final String serviceName;
  final double basePrice;
  final Duration estimatedTime;

  ServiceModelCompat({
    required this.serviceId,
    required this.serviceName,
    required this.basePrice,
    required this.estimatedTime,
  });
}
