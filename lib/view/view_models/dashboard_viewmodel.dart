// lib/view/view_models/dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/saloon_model.dart';
import '../../data/repositories/saloon_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  /// Depolama katmanına erişim için bir örnek (instance) oluşturuyoruz.
  final SaloonRepository _saloonRepository = SaloonRepository(Supabase.instance.client);

  /// **"Sanal" kategorilerimiz burada tanımlanıyor.**
  /// Her kategori adı, veritabanındaki bir veya daha fazla hizmet adına (`service_name`) karşılık gelir.
  /// Bu haritayı genişleterek veya düzenleyerek kategorilerinizi yönetebilirsiniz.
  final Map<String, List<String>> virtualCategories = {
    'Yüz ve Cilt Bakımı': ['Cilt Bakımı', 'Hydrafacial', 'Dermapen', 'Klasik Cilt Bakımı'],
    'Tüy Alımı ve Ağda': ['Tüm Bacak Ağda', 'Kaş Dizaynı', 'Bıyık İp', 'Lazer Epilasyon'],
    'El & Ayak Bakımı': ['Manikür', 'Pedikür', 'Kalıcı Oje', 'Protez Tırnak'],
    'Saç Hizmetleri': ['Saç Kesimi', 'Fön', 'Boya', 'Röfle', 'Ombre'],
    'Makyaj': ['Gündüz Makyajı', 'Gece Makyajı', 'Gelin Makyajı'],
  };

  // --- Durum Yönetimi Değişkenleri ---

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- Ana Sayfa Listeleri ---

  List<SaloonModel> _nearbySaloons = [];
  List<SaloonModel> get nearbySaloons => _nearbySaloons;

  List<SaloonModel> _topRatedSaloons = [];
  List<SaloonModel> get topRatedSaloons => _topRatedSaloons;

  List<SaloonModel> _campaignSaloons = [];
  List<SaloonModel> get campaignSaloons => _campaignSaloons;

  // --- Kategoriye Özel Salonlar Listesi ---

  List<SaloonModel> _categorySaloons = [];
  List<SaloonModel> get categorySaloons => _categorySaloons;

  /// Yükleme durumunu güncelleyen ve arayüzü yeniden çizmesi için dinleyicileri tetikleyen yardımcı fonksiyon.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Ana sayfa ilk açıldığında gerekli olan tüm verileri (yakındaki, puanlı, kampanyalı salonlar) çeker.
  Future<void> fetchDashboardData() async {
    _setLoading(true);
    try {
      // API çağrılarını aynı anda (paralel) başlatarak zaman kazanıyoruz.
      final results = await Future.wait([
        _saloonRepository.getNearbySaloons(),
        _saloonRepository.getTopRatedSaloons(),
        _saloonRepository.getCampaignSaloons(),
      ]);

      // Sonuçları ilgili listelere atıyoruz.
      _nearbySaloons = results[0];
      _topRatedSaloons = results[1];
      _campaignSaloons = results[2];

    } catch (e) {
      debugPrint("Dashboard verileri alınırken hata: $e");
    } finally {
      // İşlem bitince (hata olsa da olmasa da) yükleme durumunu kapatıyoruz.
      _setLoading(false);
    }
  }

  /// Bir kategori adına tıklandığında o kategoriye ait salonları getiren fonksiyon.
  Future<void> fetchSaloonsByCategory(String categoryName) async {
    _setLoading(true);
    _categorySaloons = []; // Yeni bir arama öncesi eski sonuçları temizliyoruz.
    notifyListeners(); // Arayüzün temizlendiğini görmesi için tetikliyoruz.

    // Sanal kategori haritasından ilgili hizmet adlarının listesini alıyoruz.
    // Eğer kategori bulunamazsa, güvenlik için boş bir liste kullanıyoruz.
    final serviceNames = virtualCategories[categoryName] ?? [];

    try {
      // Depolama katmanındaki fonksiyonu çağırarak salonları getiriyoruz.
      _categorySaloons = await _saloonRepository.getSaloonsByServiceNames(serviceNames);
    } catch (e) {
      debugPrint("'$categoryName' kategorisindeki salonlar alınırken hata: $e");
    } finally {
      _setLoading(false);
    }
  }
}