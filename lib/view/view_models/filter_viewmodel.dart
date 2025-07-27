import 'package:flutter/foundation.dart';
import '../../data/models/saloon_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/saloon_repository.dart';
import '../../data/repositories/service_repository.dart';

class FilterOptions {
  List<String> selectedServices; // serviceName[]
  double minRating;

  FilterOptions({
    this.selectedServices = const [],
    this.minRating = 0,
  });

  FilterOptions copyWith({
    List<String>? selectedServices,
    double? minRating,
  }) =>
      FilterOptions(
        selectedServices: selectedServices ?? List.of(this.selectedServices),
        minRating: minRating ?? this.minRating,
      );
}

class FilterViewModel extends ChangeNotifier {
  final ServiceRepository _serviceRepo;
  final SaloonRepository _saloonRepo;

  FilterViewModel(this._serviceRepo, this._saloonRepo);

  bool isLoading = false;

  // Katalog
  List<ServiceModel> allServices = [];

  // Sonuçlar
  List<SaloonModel> filteredSaloons = [];

  // Mevcut ayarlar (Dashboard popup’ı kullanıyor)
  FilterOptions currentFilters = FilterOptions();

  Future<void> loadServicesIfNeeded() async {
    if (allServices.isNotEmpty) return;
    isLoading = true;
    notifyListeners();
    try {
      allServices = await _serviceRepo.getAllServices();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }



  /// 🔧 DÜZELTME:
  /// - Artık serviceName -> serviceId çevirisi YAPMIYORUZ.
  /// - Senin repo imzana uygun olarak, doğrudan `getFilteredSaloons(options)` çağırıyoruz.
  Future<void> applyFiltersAndFetchResults(FilterOptions options) async {
    currentFilters = options;
    isLoading = true;
    notifyListeners();

    try {
      // Servis listesi yüklü değilse yükle (name -> id map için gerekli)
      if (allServices.isEmpty) {
        allServices = await _serviceRepo.getAllServices();
      }

      // serviceName[] --> serviceId[]
      final nameToId = {
        for (final s in allServices) s.serviceName: s.serviceId,
      };
      final serviceIds = options.selectedServices
          .map((n) => nameToId[n])
          .whereType<String>()
          .toList();

      // 🔴 DÜZELTME: mevcut repository metodunu çağır
      filteredSaloons = await _saloonRepo.filterSaloons(
        serviceIds: serviceIds,
        minRating: options.minRating,
      );

      debugPrint('[FilterVM] results: ${filteredSaloons.length}');
    } catch (e, st) {
      debugPrint('[FilterVM] applyFiltersAndFetchResults error: $e\n$st');
      filteredSaloons = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
