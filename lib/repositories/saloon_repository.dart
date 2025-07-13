import 'package:denemeye_devam/main.dart'; // supabase client'ına erişmek için
import 'package:denemeye_devam/models/SaloonModel.dart'; // Veriyi bu modele çevireceğiz
import 'package:supabase_flutter/supabase_flutter.dart';

class SaloonRepository {
  final SupabaseClient _client;
  SaloonRepository(this._client);
  // Yakındaki salonları getiren fonksiyon
  Future<List<SaloonModel>> getNearbySaloons() async {
    try {
      // 1. Supabase'deki 'saloons' tablosundan tüm veriyi (*) seç.
      // .select() metodu List<Map<String, dynamic>> tipinde bir liste döndürür.
      final List<Map<String, dynamic>> data = await _client.from('saloons').select('*, services(*)');

      // 2. Gelen her bir Map'i (her bir salonun JSON verisi),
      //    daha önce yazdığın SaloonModel.fromJson'ı kullanarak bir SaloonModel nesnesine çevir.
      final saloons = data.map((item) => SaloonModel.fromJson(item)).toList();

      // 3. Oluşturulan SaloonModel listesini geri döndür.
      return saloons;

    } catch (e) {
      // 4. Bir hata oluşursa, hatayı konsola yazdır ve boş bir liste döndür.
      //    (Gerçek bir uygulamada burada daha detaylı bir hata yönetimi yapılır)
      print('Salonları çekerken hata: $e');
      return [];
    }
  }

// En yüksek puanlıları getirmek için de benzer bir fonksiyon yazabilirsin.
// Örneğin, Supabase'de bir RPC (veritabanı fonksiyonu) yazıp onu çağırabilirsin.
// Future<List<SaloonModel>> getTopRatedSaloons() async { ... }
}