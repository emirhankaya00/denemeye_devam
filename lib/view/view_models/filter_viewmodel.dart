import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/saloon_model.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/saloon_repository.dart';

/// Kullanıcının seçtiği filtreleri tutar
class FilterOptions {
  final List<String> selectedServices;
  final double       minRating;

  const FilterOptions({
    this.selectedServices = const [],
    this.minRating       = 0.0,
  });

  FilterOptions copyWith({
    List<String>? selectedServices,
    double?       minRating,
  }) =>
      FilterOptions(
        selectedServices: selectedServices ?? this.selectedServices,
        minRating:       minRating       ?? this.minRating,
      );
}

class FilterViewModel extends ChangeNotifier {
  final SaloonRepository _repo =
  SaloonRepository(Supabase.instance.client);

  bool _loading = false;
  bool get isLoading => _loading;

  List<SaloonModel> _all = [];        // tüm salonlar (önbellek)
  List<SaloonModel> _filtered = [];   // ekranda gösterilecek
  List<SaloonModel> get filteredSaloons => _filtered;

  List<ServiceModel> _allServices = [];   // popup listesi
  List<ServiceModel> get allServices => _allServices;

  FilterOptions _current = const FilterOptions();
  FilterOptions get currentFilters => _current;

  // -------------------------------- init
  FilterViewModel() {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    final res = await Future.wait([
      _repo.getAllSaloons(),
      _repo.getAllServices(),
    ]);

    _all         = res[0] as List<SaloonModel>;
    _allServices = res[1] as List<ServiceModel>;

    _loading = false;
    notifyListeners();
  }

  /// Popup > “Filtrelenen Salonları Gör” tıklandığında çağrılır
  Future<void> applyFiltersAndFetchResults(FilterOptions opt) async {
    if (_all.isEmpty) await _init();   // ilk açılış güvenliği
    _loading = true;
    _current = opt;
    notifyListeners();

    final lcNames =
    opt.selectedServices.map((e) => e.toLowerCase()).toList();

    _filtered = _all.where((salon) {
      final serviceOK = lcNames.isEmpty ||
          salon.services.any((s) =>
              lcNames.contains(s.serviceName.toLowerCase()));
      final ratingOK  = salon.rating >= opt.minRating;
      return serviceOK && ratingOK;
    }).toList();

    _loading = false;
    notifyListeners();
  }
}
