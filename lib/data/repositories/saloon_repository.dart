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

  static final RegExp _uuidRegExp = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  static const String _saloonListSelect = '''
    saloon_id, saloon_name, saloon_description, saloon_address, title_photo_url, latitude, longitude, email,
    saloon_services(id, price, is_active, service_id, services(service_id, service_name)),
    comments(rating)
  ''';

  static const String _saloonDetailSelect = '''
    saloon_id, saloon_name, saloon_description, saloon_address, title_photo_url, latitude, longitude, email,
    saloon_services(id, price, is_active, service_id, services(service_id, service_name)),
    comments(comment_id, rating, comment_text, user_id, created_at)
  ''';

  Future<List<SaloonModel>> _fetchSaloons(String selectQuery) async {
    try {
      final data = await _client.from('saloons').select(selectQuery);
      return (data as List)
          .map((item) => SaloonModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası ($selectQuery): $e');
      return [];
    }
  }

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
      return SaloonModel.fromJson(res);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  Future<List<SaloonModel>> getAllSaloons() {
    debugPrint('Tüm salonlar yükleniyor...');
    return _fetchSaloons(_saloonListSelect);
  }

  Future<List<SaloonModel>> getNearbySaloons() => _fetchSaloons(_saloonListSelect);
  Future<List<SaloonModel>> getTopRatedSaloons() => _fetchSaloons(_saloonListSelect);
  Future<List<SaloonModel>> getCampaignSaloons() => _fetchSaloons(_saloonListSelect);

  Future<List<ServiceModel>> getAllServices() async {
    try {
      final data = await _client.from('services').select('*');
      return (data as List)
          .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getAllServices Hata: $e');
      return [];
    }
  }

  Future<List<SaloonModel>> filterSaloons({
    required List<String> serviceIds,
    required double minRating,
  }) async {
    try {
      final params = {'p_service_ids': serviceIds, 'p_min_rating': minRating};
      final res = await _client.rpc('filter_saloons', params: params);
      return (res as List)
          .map((item) => SaloonModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('filterSaloons Hata: $e');
      return [];
    }
  }

  Future<List<PersonalModel>> getEmployeesBySaloon(String salonId) async {
    try {
      final data = await _client.from('personals').select('*').eq('saloon_id', salonId);
      return (data as List)
          .map((item) => PersonalModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getEmployeesBySaloon Hata: $e');
      return [];
    }
  }

  Future<List<SaloonModel>> getSaloonsByServiceNames(List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];
    try {
      final res = await _client.rpc(
        'get_saloons_by_service_names',
        params: {'p_service_names': serviceNames},
      );
      return (res as List)
          .map((item) => SaloonModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }

  // DÜZELTME: EXTENSION İÇİNDEKİ FONKSİYONLAR DOĞRUDAN ANA SINIFA TAŞINDI

  /// Belirli salonun kategorilere göre gruplandırılmış hizmetlerini getirir.
  Future<List<CategoryWithServices>> getSaloonCategoriesWithServices(String saloonId) async {
    try {
      final res = await _client.rpc('get_saloon_services_grouped_basic', params: {
        'p_saloon_id': saloonId,
      });
      return (res as List)
          .map((item) => CategoryWithServices.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getSaloonCategoriesWithServices Hata: $e');
      return [];
    }
  }

  /// Yeni bir rezervasyon oluşturur.
  Future<String?> createReservation({
    String? userId,
    required String saloonId,
    String? personalId,
    required DateTime date,
    required TimeOfDay time,
    required List<SelectedItem> items,
  }) async {
    try {
      final params = {
        'p_user_id': userId,
        'p_saloon_id': saloonId,
        'p_personal_id': personalId,
        'p_reservation_date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'p_reservation_time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
        'p_items': items.map((e) => e.toRpcJson()).toList(),
      };
      final res = await _client.rpc('create_reservation', params: params);
      return res?.toString();
    } catch (e) {
      debugPrint('createReservation Hata: $e');
      return null;
    }
  }
}