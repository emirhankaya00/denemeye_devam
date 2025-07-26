import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/saloon_model.dart';
import '../../data/repositories/saloon_repository.dart';

/// Ana sayfanın (Dashboard) tüm veri ve durum yönetimini üstlenir.
class DashboardViewModel extends ChangeNotifier {
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);

  /// Sanal kategoriler. Arayüz, bu map'in anahtarlarını ('Saç Hizmetleri' vb.)
  /// kategori isimleri olarak dinamik bir şekilde çeker.
  /// Bu yapı, kategori mantığını tek bir yerden yönetmeyi sağlar.
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

  /// **DÜZELTME: Arayüzün kategori isimlerini dinamik olarak almasını sağlayan getter.**
  /// Bu sayede arayüzdeki kategori listesi, her zaman buradaki `virtualCategories`
  /// haritasının anahtarlarıyla senkronize olur.
  List<String> get categoryNames => virtualCategories.keys.toList();

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

  /// Yükleme durumunu günceller ve arayüzü bilgilendirir.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Ana sayfada gösterilecek tüm temel listeleri (yakınlardakiler, en iyiler vb.)
  /// eş zamanlı olarak çeker.
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

  /// Tıklanan bir kategoriye ait salonları getirir.
  Future<void> fetchSaloonsByCategory(String categoryName) async {
    _setLoading(true);
    _categorySaloons = []; // Yeni arama öncesi eski sonuçları temizle
    notifyListeners();

    // Verilen kategori adına göre hizmet isimlerini haritadan bulur.
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