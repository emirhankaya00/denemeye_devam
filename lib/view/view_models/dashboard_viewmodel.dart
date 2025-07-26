// lib/view/view_models/dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/saloon_model.dart';
import '../../data/repositories/saloon_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);

  /// --- KESİN ÇÖZÜM: Arayüz (View) ve Veritabanı (DB) ile UYUMLU KATEGORİLER ---
  /// Buradaki anahtarlar ('Saç Hizmetleri' vb.) artık dashboard_screen.dart'taki
  /// kategori listesiyle birebir aynı.
  /// İçindeki servis listeleri ise doğrudan sizin veritabanınızdan alınmıştır.
  final Map<String, List<String>> virtualCategories = {
    'Saç Hizmetleri': [
      'Saç Kesim',
      'Modern Saç Kesimi',
      'sac kesimi', // DB'deki küçük harfli versiyon
      'Saç Boyama',
      'Saç Boyama (Dip)',
      'Keratin Bakımı',
      'Keratin Düzleştirme'
    ],
    'Yüz ve Cilt Bakımı': [
      'Cilt Bakımı',
      'Klasik Cilt Bakımı',
      'Kaş ve Bıyık Alımı' // DB'deki birleşik isim
    ],
    'El & Ayak Bakımı': [
      'Manikür',
      'Klasik manikür & oje' // DB'deki isim
    ],
    'Erkek Bakım': [
      'Sakal Tıraşı ve Şekillendirme'
    ]
  };

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SaloonModel> _nearbySaloons = [];
  List<SaloonModel> get nearbySaloons => _nearbySaloons;

  List<SaloonModel> _topRatedSaloons = [];
  List<SaloonModel> get topRatedSaloons => _topRatedSaloons;

  List<SaloonModel> _campaignSaloons = [];
  List<SaloonModel> get campaignSaloons => _campaignSaloons;

  List<SaloonModel> _categorySaloons = [];
  List<SaloonModel> get categorySaloons => _categorySaloons;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchDashboardData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _saloonRepository.getNearbySaloons(),
        _saloonRepository.getTopRatedSaloons(),
        _saloonRepository.getCampaignSaloons(),
      ]);

      _nearbySaloons = results[0];
      _topRatedSaloons = results[1];
      _campaignSaloons = results[2];

    } catch (e) {
      debugPrint("Dashboard verileri alınırken hata: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSaloonsByCategory(String categoryName) async {
    _setLoading(true);
    _categorySaloons = [];
    notifyListeners();

    final serviceNames = virtualCategories[categoryName] ?? [];

    if (serviceNames.isEmpty) {
      debugPrint("'$categoryName' için servis bulunamadı. ViewModel'daki anahtar (key) ile eşleşmiyor olabilir.");
      _setLoading(false);
      return;
    }

    try {
      _categorySaloons = await _saloonRepository.getSaloonsByServiceNames(serviceNames);
    } catch (e) {
      debugPrint("'$categoryName' kategorisindeki salonlar alınırken hata: $e");
    } finally {
      _setLoading(false);
    }
  }
}