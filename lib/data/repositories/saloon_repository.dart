import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/saloon_model.dart';
import '../models/service_model.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// Liste ekranları için hafif seçim (yorumlarda sadece rating)
  static const String _saloonListSelect = '''
    saloon_id,
    saloon_name,
    saloon_description,
    saloon_address,
    title_photo_url,
    latitude,
    longitude,
    email,
    saloon_services(
      id,
      price,
      is_active,
      service_id,
      services(service_id, service_name)
    ),
    comments(rating)
  ''';

  /// Detay ekranı için geniş seçim (yorumların tamamı)
  static const String _saloonDetailSelect = '''
    saloon_id,
    saloon_name,
    saloon_description,
    saloon_address,
    title_photo_url,
    latitude,
    longitude,
    email,
    saloon_services(
      id,
      price,
      is_active,
      service_id,
      services(service_id, service_name)
    ),
    comments(
      comment_id,
      rating,
      comment_text,
      user_id,
      created_at
    )
  ''';

  /// Genel SELECT yardımcı fonksiyonu
  Future<List<SaloonModel>> _fetchSaloons(String selectQuery) async {
    try {
      final data = await _client.from('saloons').select(selectQuery);
      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map((item) => SaloonModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası ($selectQuery): $e');
      return [];
    }
  }

  /// Belirli bir salonu ID ile getirir (hizmetler + yorumlar dahil)
  Future<SaloonModel?> getSaloonById(String salonId) async {
    if (salonId.isEmpty || !_uuidRegExp.hasMatch(salonId)) {
      debugPrint('getSaloonById: geçersiz UUID → "$salonId" (çağrı atlandı)');
      return null;
    }
    try {
      final res = await _client
          .from('saloons')
          .select(_saloonDetailSelect) // senin son sürümünde tanımlı
          .eq('saloon_id', salonId)
          .single();

      if (res is! Map<String, dynamic>) return null;
      return SaloonModel.fromJson(res);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  /// Tüm salonları getirir
  Future<List<SaloonModel>> getAllSaloons() {
    debugPrint('Tüm salonlar yükleniyor...');
    return _fetchSaloons(_saloonListSelect);
  }

  /// Filtre ekranındaki hizmetleri getirir
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final data = await _client.from('services').select('*');
      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map((service) => ServiceModel.fromJson(service))
          .toList();
    } catch (e) {
      debugPrint('getAllServices Hata: $e');
      return [];
    }
  }

  /// Hizmet(ler) + minimum puan ile filtre (RPC: filter_saloons)
  Future<List<SaloonModel>> filterSaloons({
    required List<String> serviceIds, // uuid[]
    required double minRating,
  }) async {
    try {
      final params = {
        'p_service_ids': serviceIds, // boş [] → hizmet filtresi yok
        'p_min_rating': minRating,
      };
      final res = await _client.rpc('filter_saloons', params: params);
      if (res is! List) return [];
      return res
          .cast<Map<String, dynamic>>()
          .map((e) => SaloonModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('filterSaloons Hata: $e');
      return [];
    }
  }

  /// Yakınlardaki salonlar (şimdilik aynı seçim; konum filtrelemesini VM’de yapabilirsin)
  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// En yüksek puanlı salonlar (listeyi aldıktan sonra VM’de sırala veya SQL’de view ile getir)
  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// Kampanyalı salonlar (kampanya alanı varsa SQL filtre ekleyebilirsin)
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// Bir salona ait çalışanları getirir
  Future<List<PersonalModel>> getEmployeesBySaloon(String salonId) async {
    try {
      final data = await _client
          .from('personals')
          .select('*')
          .eq('saloon_id', salonId);

      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map((item) => PersonalModel.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('getEmployeesBySaloon Hata: $e');
      return [];
    }
  }

  /// Kategori sayfası: hizmet ad(lar)ına göre salonlar (RPC)
  Future<List<SaloonModel>> getSaloonsByServiceNames(
      List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];
    try {
      final res = await _client.rpc(
        'get_saloons_by_service_names',
        params: {'p_service_names': serviceNames},
      );
      if (res == null || res is! List) return [];
      return res
          .cast<Map<String, dynamic>>()
          .map((saloon) => SaloonModel.fromJson(saloon))
          .toList();
    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}
