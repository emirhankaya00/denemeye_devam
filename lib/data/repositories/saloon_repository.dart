import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/saloon_model.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  // Sorguyu tek bir yerden yönetmek için sabit olarak tanımlıyoruz.
  // Bu sorgu, salon bilgisini, salon-hizmet ilişkisini ve hizmetin kendi detaylarını getirir.
  static const String _saloonWithServicesQuery =
      '*, saloon_services(*, services(*))';

  /// Verilen sorguya göre salonları getiren ana fonksiyon.
  /// Hata yönetimini merkezi olarak yapar.
  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<dynamic> data = await _client.from('saloons').select(query);
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası: $e');
      return []; // Hata durumunda boş liste döndürür.
    }
  }

  /// Tüm salonları getirir.
  Future<List<SaloonModel>> getAllSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// Yakınlardaki salonları getirir. (Şimdilik tüm salonları getiriyor, konum bazlı filtreleme eklenebilir)
  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// En yüksek puanlı salonları getirir. (Şimdilik tüm salonları getiriyor, puan bazlı sıralama eklenebilir)
  Future<List<SaloonModel>> getTopRatedSaloons() {
    // Örnek: '*, comments(rating)' sorgusuyla puanları da getirebiliriz.
    return _fetchSaloons('$_saloonWithServicesQuery, comments(rating)');
  }

  /// Kampanyalı salonları getirir. (Şimdilik tüm salonları getiriyor, kampanya filtresi eklenebilir)
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  /// Belirli bir salonu ID'sine göre tüm detaylarıyla getirir.
  Future<SaloonModel?> getSaloonById(String salonId) async {
    try {
      final response = await _client
          .from('saloons')
          .select('$_saloonWithServicesQuery, comments(*)') // Ana sorguya yorumları da ekliyoruz
          .eq('saloon_id', salonId)
          .single(); // Tek bir kayıt döneceği için .single() kullanıyoruz.

      return SaloonModel.fromJson(response);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  /// Bir salona bağlı tüm çalışanları (personelleri) getirir.
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

  /// **YENİ EKLENEN FONKSİYON**
  /// Verilen hizmet adları listesine göre bu hizmetleri sunan salonları getirir.
  /// Sanal kategori mantığı için bu fonksiyonu kullanacağız.
  Future<List<SaloonModel>> getSaloonsByServiceNames(List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];

    try {
      // Bu fonksiyon, verdiğimiz hizmet isimlerini (`serviceNames`) içeren salonları
      // bulmak için Supabase üzerinde bir veritabanı fonksiyonu (RPC) çağırır.
      // Bu, performansı artırır ve kodu temiz tutar.
      final response = await _client.rpc(
        'get_saloons_by_service_names',
        params: {'p_service_names': serviceNames},
      );

      return (response as List<dynamic>)
          .map((saloon) => SaloonModel.fromJson(saloon))
          .toList();

    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}