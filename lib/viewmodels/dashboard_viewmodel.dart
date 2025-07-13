import 'package:flutter/material.dart';
import 'package:denemeye_devam/models/SaloonModel.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardViewModel extends ChangeNotifier {
  final SaloonRepository _repository = SaloonRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SaloonModel> _nearbySaloons = [];
  List<SaloonModel> get nearbySaloons => _nearbySaloons;

  DashboardViewModel() {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Artık Repository'deki GERÇEK fonksiyonu çağırıyoruz.
    _nearbySaloons = await _repository.getNearbySaloons();

    _isLoading = false;
    notifyListeners();
  }
}