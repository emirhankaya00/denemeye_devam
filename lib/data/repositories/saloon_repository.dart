import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/personal_model.dart';
import '../models/saloon_model.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  static const String _saloonWithServicesQuery =
      '*, saloon_services(*, services(*))';

  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<dynamic> data = await _client.from('saloons').select(query);
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Supabase salon sorgu hatası: $e');
      return [];
    }
  }

  Future<List<SaloonModel>> getAllSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _fetchSaloons('$_saloonWithServicesQuery, comments(rating)');
  }

  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

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

  /// KESİN ÇÖZÜM: RPC'den gelen veriyi güvenli bir şekilde işleyen kod.
  /// Bu fonksiyon, aşağıdaki SQL koduyla birlikte çalışacak şekilde tasarlanmıştır.
  Future<List<SaloonModel>> getSaloonsByServiceNames(List<String> serviceNames) async {
    if (serviceNames.isEmpty) return [];

    try {
      final response = await _client.rpc(
        'get_saloons_by_service_names',
        params: {'p_service_names': serviceNames},
      );

      // Gelen verinin null olmadığını ve bir liste olduğunu kontrol ediyoruz.
      if (response == null || response is! List) {
        debugPrint('RPC beklenen formatta bir liste döndürmedi. Veritabanı fonksiyonunu güncellediğinizden emin olun.');
        return [];
      }

      // Gelen listedeki her bir JSON objesini SaloonModel'e çeviriyoruz.
      return (response as List<dynamic>)
          .map((saloon) => SaloonModel.fromJson(saloon as Map<String, dynamic>))
          .toList();

    } catch (e) {
      debugPrint('getSaloonsByServiceNames Hata: $e');
      return [];
    }
  }
}