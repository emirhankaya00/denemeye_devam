import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Diğer dosyalardan gerekli modelleri import ediyoruz.
import '../models/personal_model.dart';
import '../models/saloon_model.dart';
import '../models/service_model.dart';
// FilterViewModel'den FilterOptions modelini kullanmak için bu import gerekli.
import '../../view/view_models/filter_viewmodel.dart';

/// Bu sınıf, salonlarla ilgili tüm veritabanı işlemlerini (okuma, yazma, filtreleme)
/// merkezi bir yerden yönetir. Uygulamanın geri kalanı, Supabase ile nasıl konuşulduğunu
/// bilmek zorunda kalmaz, sadece bu repository'deki metodları çağırır.
class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  /// Sorguları tekrar tekrar yazmamak için standart bir sorgu metni.
  /// Salonun tüm alanlarını (`*`) ve ona bağlı tüm hizmetleri (`saloon_services` aracılığıyla) getirir.
  static const String _saloonWithServicesQuery =
      '*, saloon_services(*, services(*))';

  /// Tek bir yerden hata yönetimi yapan ve salon listesi getiren ana metod.
  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<dynamic> data = await _client.from('saloons').select(query);
      // Gelen her bir JSON objesini SaloonModel'e çeviriyoruz.
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası ($query): $e');
      return []; // Hata durumunda her zaman boş ve güvenli bir liste döndürür.
    }
  }

  /// **FİLTRELEME İÇİN GEREKLİ ANA FONKSİYON**
  /// Tüm salonları, üzerinde işlem yapabilmemiz için bütün detaylarıyla birlikte çeker.
  Future<List<SaloonModel>> getAllSaloons() {
    debugPrint("Tüm salonlar hizmetleriyle birlikte çekiliyor...");
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// **FİLTRE POPUP'I İÇİN YENİ FONKSİYON**
  /// Filtre popup'ında hizmetleri listeleyebilmemiz için tüm hizmetleri getirir.
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final data = await _client.from('services').select('*');
      return (data as List<dynamic>)
          .map((service) => ServiceModel.fromJson(service))
          .toList();
    } catch (e) {
      debugPrint('getAllServices Hata: $e');
      return [];
    }
  }

  /// **YENİ VE AKILLI FİLTRELEME FONKSİYONU**
  /// Popup'ta seçilen filtre seçeneklerine göre veritabanındaki özel RPC'yi çağırır.
  /// Bu, en performanslı ve doğru filtreleme yöntemidir.
  Future<List<SaloonModel>> getFilteredSaloons(FilterOptions options) async {
    try {
      final response = await _client.rpc(
        'get_filtered_saloons', // En son oluşturduğumuz akıllı SQL fonksiyonu
        params: {
          'p_min_rating': options.minRating,
          'p_service_names': options.selectedServices,
        },
      );
      if (response == null || response is! List) {
        debugPrint('getFilteredSaloons RPC beklenen formatta bir liste döndürmedi.');
        return [];
      }
      return (response).map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('getFilteredSaloons Hata: $e');
      return [];
    }
  }


  // --- MEVCUT VE ÇALIŞAN FONKSİYONLAR (DEĞİŞTİRİLMEDİ) ---

  /// Yakınlardaki salonları getirir.
  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// En yüksek puanlı salonları getirir.
  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _fetchSaloons('$_saloonWithServicesQuery, comments(rating)');
  }

  /// Kampanyalı salonları getirir.
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// Tek bir salonu ID'sine göre, hizmetleri ve yorumları ile birlikte getirir.
  Future<SaloonModel?> getSaloonById(String salonId) async {
    try {
      final response = await _client
          .from('saloons')
          .select('$_saloonWithServicesQuery, comments(*)')
          .eq('saloon_id', salonId)
          .single();

      return SaloonModel.fromJson(response);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  /// Bir salona ait tüm personelleri getirir.
  Future<List<PersonalModel>> getEmployeesBySaloon(String salonId) async {
    try {
      final response = await _client
          .from('personals')
          .select('*')
          .eq('saloon_id', salonId);

      return response.map((item) => PersonalModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('getEmployeesBySaloon Hata: $e');
      return [];
    }
  }

  /// Kategori sayfaları için belirli hizmetleri sunan salonları getirir.
  Future<List<SaloonModel>> getSaloonsByServiceNames(List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];
    try {
      // Bu fonksiyon eski ve daha basit olan RPC'yi çağırır.
      // Eğer kategori ve filtre mantığını birleştirmek istersen, bu da getFilteredSaloons'u kullanabilir.
      final response = await _client.rpc('get_saloons_by_service_names', params: {'p_service_names': serviceNames});
      if (response == null || response is! List) return [];
      return (response).map((saloon) => SaloonModel.fromJson(saloon as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}