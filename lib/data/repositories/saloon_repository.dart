// lib/data/repositories/saloon_repository.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_with_services.dart';
import '../models/personal_model.dart';
import '../models/saloon_model.dart';
import '../models/selected_item.dart';
import '../models/service_model.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  /// UUID doğrulama (boş/hatalı id ile sorguyu atlamak için)
  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// Liste ekranları için hafif SELECT (yorumlardan sadece rating topluyoruz)
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

  /// Detay ekranı için geniş SELECT (yorumların tamamı)
  /// DİKKAT: services(...) içinde estimated_minutes kaldırıldı (tablonuzda yok).
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

  /// Ortak SELECT helper
  Future<List<SaloonModel>> _fetchSaloons(String selectQuery) async {
    try {
      final data = await _client.from('saloons').select(selectQuery);
      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map(SaloonModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası ($selectQuery): $e');
      return [];
    }
  }

  /// Belirli bir salonu ID ile getir (hizmetler + yorumlar dahil)
  Future<SaloonModel?> getSaloonById(String salonId) async {
    if (salonId.isEmpty || !_uuidRegExp.hasMatch(salonId)) {
      debugPrint('getSaloonById: geçersiz UUID → "$salonId" (çağrı atlandı)');
      return null;
    }
    try {
      final res = await _client
          .from('saloons')
          .select(_saloonDetailSelect)
          .eq('saloon_id', salonId)
          .single();

      if (res is! Map<String, dynamic>) return null;
      return SaloonModel.fromJson(res);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  /// Tüm salonları getirir (liste seçimiyle)
  Future<List<SaloonModel>> getAllSaloons() {
    debugPrint('Tüm salonlar yükleniyor...');
    return _fetchSaloons(_saloonListSelect);
  }

  /// Yakınlardaki salonlar
  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// En yüksek puanlı salonlar
  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// Kampanyalı salonlar
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonListSelect);
  }

  /// Filtre ekranındaki hizmetleri getirir
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final data = await _client.from('services').select('*');
      if (data is! List) return [];
      return data
          .cast<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
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
          .map(SaloonModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('filterSaloons Hata: $e');
      return [];
    }
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
          .map(PersonalModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('getEmployeesBySaloon Hata: $e');
      return [];
    }
  }

  /// Kategori sayfası: hizmet ad(lar)ına göre salonlar (RPC)
  Future<List<SaloonModel>> getSaloonsByServiceNames(
      List<String> serviceNames,
      ) async {
    if (serviceNames.isEmpty) return [];
    try {
      final res = await _client.rpc(
        'get_saloons_by_service_names',
        params: {'p_service_names': serviceNames},
      );
      if (res is! List) return [];
      return res
          .cast<Map<String, dynamic>>()
          .map(SaloonModel.fromJson)
          .toList();
    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}

/// Rezervasyon ve kategorili hizmetler için ek uçlar
extension BookingApi on SaloonRepository {
  /// (1) Belirli salonun kategorilere göre gruplandırılmış hizmetleri
  /// Supabase RPC: get_saloon_services_grouped_basic
  Future<List<CategoryWithServices>> getSaloonCategoriesWithServices(
      String saloonId,
      ) async {
    try {
      final res = await _client.rpc('get_saloon_services_grouped_basic', params: {
        'p_saloon_id': saloonId,
      });
      if (res is! List) return [];
      return res
          .cast<Map<String, dynamic>>()
          .map(CategoryWithServices.fromJson)
          .toList();
    } catch (e) {
      debugPrint('getSaloonCategoriesWithServices Hata: $e');
      return [];
    }
  }

  /// (2) Rezervasyon oluşturma
  /// SQL fonksiyonunda `auth.uid()` fallback’i varsa p_user_id göndermen gerekmez.
  /// items → SelectedItem.toRpcJson() ile gönderiliyor.
  Future<String?> createReservation({
    String? userId, // opsiyonel; null ise SQL tarafında auth.uid()
    required String saloonId,
    String? personalId,
    required DateTime date,
    required TimeOfDay time,
    required List<SelectedItem> items,
  }) async {
    try {
      final params = {
        'p_user_id': userId, // null olabilir
        'p_saloon_id': saloonId,
        'p_personal_id': personalId,
        'p_reservation_date':
        DateTime(date.year, date.month, date.day).toIso8601String(),
        'p_reservation_time':
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
        'p_items': items.map((e) => e.toRpcJson()).toList(),
      };
      final res = await _client.rpc('create_reservation', params: params);
      // res genelde rezervasyon_id döndürür; stringe çevirip veriyoruz
      return res?.toString();
    } catch (e) {
      debugPrint('createReservation Hata: $e');
      return null;
    }
  }
}
