import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/saloon_model.dart';
import '../models/service_model.dart';
import '../../view/view_models/filter_viewmodel.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  // Salon + hizmetler + yorumlardan puan
  static const String _saloonWithServicesAndRatingsQuery =
      '*, saloon_services(*, services(*)), comments(rating)';

  /// Genel sorgu yapan yardımcı fonksiyon
  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<dynamic> data = await _client.from('saloons').select(query);
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası ($query): $e');
      return [];
    }
  }

  /// Tüm salonları getirir
  Future<List<SaloonModel>> getAllSaloons() {
    debugPrint("Tüm salonlar yükleniyor...");
    return _fetchSaloons(_saloonWithServicesAndRatingsQuery);
  }

  /// Filtre ekranındaki hizmetleri getirir
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

  /// Filtreleme popup'ındaki veriye göre özel filtre uygular
  Future<List<SaloonModel>> getFilteredSaloons(FilterOptions options) async {
    try {
      final response = await _client.rpc(
        'get_filtered_saloons',
        params: {
          'p_min_rating': options.minRating,
          'p_service_names': options.selectedServices,
        },
      );

      if (response == null || response is! List) {
        debugPrint('getFilteredSaloons RPC beklenen formatta değil.');
        return [];
      }

      return response.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('getFilteredSaloons Hata: $e');
      return [];
    }
  }

  /// Yakınlardaki salonları getirir
  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesAndRatingsQuery);
  }

  /// En yüksek puanlı salonları getirir
  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _fetchSaloons(_saloonWithServicesAndRatingsQuery);
  }

  /// Kampanyalı salonları getirir
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesAndRatingsQuery);
  }

  /// Belirli bir salonu ID ile getirir (hizmetler + yorumlar dahil)
  Future<SaloonModel?> getSaloonById(String salonId) async {
    try {
      final response = await _client
          .from('saloons')
          .select('$_saloonWithServicesAndRatingsQuery, comments(*)')
          .eq('saloon_id', salonId)
          .single();

      return SaloonModel.fromJson(response);
    } catch (e) {
      debugPrint('getSaloonById Hata: $e');
      return null;
    }
  }

  /// Bir salona ait çalışanları getirir
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

  /// Kategori sayfası için: Belirli hizmetlere göre salon getirir
  Future<List<SaloonModel>> getSaloonsByServiceNames(List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];
    try {
      final response = await _client
          .rpc('get_saloons_by_service_names', params: {'p_service_names': serviceNames});

      if (response == null || response is! List) return [];

      return response.map((saloon) => SaloonModel.fromJson(saloon)).toList();
    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}
