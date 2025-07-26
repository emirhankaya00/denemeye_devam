import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/saloon_model.dart';
import '../../data/models/service_model.dart'; // YENİ IMPORT
import '../../data/repositories/saloon_repository.dart';

// Filtre seçeneklerini tutan model güncellendi
class FilterOptions {
  final RangeValues priceRange;
  final double minRating;
  final bool hasDiscount;
  final List<String> selectedServices; // YENİ: Seçilen hizmetler listesi

  FilterOptions({
    this.priceRange = const RangeValues(0, 2500),
    this.minRating = 1.0,
    this.hasDiscount = false,
    this.selectedServices = const [], // Başlangıçta boş
  });

  FilterOptions copyWith({
    RangeValues? priceRange,
    double? minRating,
    bool? hasDiscount,
    List<String>? selectedServices,
  }) {
    return FilterOptions(
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      selectedServices: selectedServices ?? this.selectedServices,
    );
  }
}

class FilterViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDataLoaded = false; // Verinin ilk kez yüklenip yüklenmediğini kontrol eder

  List<SaloonModel> _originalSaloons = [];
  List<SaloonModel> _filteredSaloons = [];
  List<SaloonModel> get filteredSaloons => _filteredSaloons;

  List<ServiceModel> _allServices = []; // YENİ: Tüm hizmetlerin listesi
  List<ServiceModel> get allServices => _allServices;

  FilterOptions _currentFilters = FilterOptions();
  FilterOptions get currentFilters => _currentFilters;

  // Constructor'da verileri yükle
  FilterViewModel() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_isDataLoaded) return; // Veri zaten yüklendiyse tekrar yükleme

    _isLoading = true;
    notifyListeners();

    // Salonları ve hizmetleri eş zamanlı olarak çek
    final results = await Future.wait([
      _saloonRepository.getAllSaloons(),
      _saloonRepository.getAllServices(),
    ]);

    _originalSaloons = results[0] as List<SaloonModel>;
    _allServices = results[1] as List<ServiceModel>;
    _isDataLoaded = true;

    _isLoading = false;
    notifyListeners();
  }

  // Filtreleri uygulama ve sonuçları getirme
  Future<void> applyFiltersAndFetchResults(FilterOptions filters) async {
    _isLoading = true;
    _currentFilters = filters;
    notifyListeners();

    // Ana salon listesi boşsa, verileri yükle (güvenlik önlemi)
    if (_originalSaloons.isEmpty) {
      await _loadInitialData();
    }

    _filteredSaloons = _originalSaloons.where((saloon) {
      // 1. Hizmet Filtresi
      // Eğer hiç hizmet seçilmemişse, bu filtreyi geç.
      // Seçilmişse, salonun hizmetlerinden EN AZ BİRİ'nin seçilenler listesinde olup olmadığını kontrol et.
      final serviceMatches = filters.selectedServices.isEmpty ||
          saloon.services.any((service) => filters.selectedServices.contains(service.serviceName));
      if (!serviceMatches) return false; // Eşleşmiyorsa, salonu direkt ele.

      // 2. Fiyat Filtresi
      final hasServiceInPriceRange = saloon.services.any((service) {
        return service.basePrice >= filters.priceRange.start && service.basePrice <= filters.priceRange.end;
      });
      if (!hasServiceInPriceRange) return false;

      // TODO: Puan ve indirim filtreleri için SaloonModel'e alanlar eklenmeli.

      return true; // Tüm filtrelerden geçtiyse listeye ekle
    }).toList();

    _isLoading = false;
    notifyListeners();
  }
}