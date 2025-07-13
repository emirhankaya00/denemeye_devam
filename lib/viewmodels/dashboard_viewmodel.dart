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

  // --- YENİ LİSTELER EKLİYORUZ ---
  List<SaloonModel> _topRatedSaloons = [];
  List<SaloonModel> get topRatedSaloons => _topRatedSaloons;

  List<SaloonModel> _campaignSaloons = [];
  List<SaloonModel> get campaignSaloons => _campaignSaloons;


  DashboardViewModel() {
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Tüm verileri aynı anda çekmek için Future.wait kullanabiliriz (daha verimli)
    final results = await Future.wait([
      _repository.getNearbySaloons(),
      _repository.getTopRatedSaloons(),
    ]);

    _nearbySaloons = results[0];
    _topRatedSaloons = results[1];

    _isLoading = false;
    notifyListeners();
  }
}