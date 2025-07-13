import 'package:denemeye_devam/main.dart'; // supabase client'ına erişmek için
import 'package:denemeye_devam/models/SaloonModel.dart'; // Veriyi bu modele çevireceğiz
import 'package:supabase_flutter/supabase_flutter.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);

  Future<List<SaloonModel>> _fetchSaloons(String query) async {
    try {
      final List<Map<String, dynamic>> data = await _client.from('saloons').select(query);
      return data.map((item) => SaloonModel.fromJson(item)).toList();
    } catch (e) {
      // Hatayı daha detaylı görmek için konsola yazdır! Bu çok önemli!
      print('Supabase sorgu hatası: $e');
      return [];
    }
  }

  // Sorguyu tek bir yerden yönetmek daha temiz.
  static const String _saloonWithServicesQuery = '*, saloon_services(*, services(*))';

  Future<List<SaloonModel>> getNearbySaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }

  Future<List<SaloonModel>> getTopRatedSaloons() {
    // order ve limit gibi eklemeleri burada yapabiliriz.
    return _fetchSaloons('$_saloonWithServicesQuery, comments(rating)');
  }

  Future<List<SaloonModel>> getCampaignSaloons() {
    return _fetchSaloons(_saloonWithServicesQuery);
  }
}