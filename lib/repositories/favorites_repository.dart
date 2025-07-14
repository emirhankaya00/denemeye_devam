import 'package:denemeye_devam/models/FavouriteModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  final SupabaseClient _client;
  FavoritesRepository(this._client);

  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  // Belirli bir kullanıcının favorilerini getiren fonksiyon
  Future<List<FavouriteModel>> getFavoriteSaloons(String userId) async {
    try {
      // Bu sorgu, bizim için sihirli bir iş yapıyor:
      // 1. 'favourites' tablosuna git.
      // 2. 'user_id' sütunu, bizim verdiğimiz userId ile eşleşen kayıtları bul.
      // 3. Bulduğun her kayıt için, ona bağlı olan 'saloons' ve 'personals'
      //    tablolarındaki tüm bilgileri de (*) yanına ekleyerek getir.
      final data = await _client
          .from('favourites')
          .select('*, saloons(*), personals(*)')
          .eq('user_id', userId);

      // Gelen JSON listesini, FavouriteModel listesine çevirip döndür.
      return data.map((item) => FavouriteModel.fromJson(item)).toList();
    } catch (e) {
      print('Favoriler çekilirken hata: $e');
      return [];
    }
  }

  // Favoriye ekleme fonksiyonu
  Future<void> addFavorite(String salonId) async {
    final currentUserId = getCurrentUserId();
    if (currentUserId != null) {
      try {
        await _client.from('favourites').insert({
          'user_id': currentUserId,
          'saloon_id': salonId,
          // 'favourite_type': 'saloon' // FavouriteModel'ine göre bu da gerekli olabilir
        });
        print('Favorilere eklendi: $salonId');
      } catch (e) {
        // Hata yönetimi için catch bloğu eklemek her zaman iyidir.
        print('Favoriye eklenirken hata oluştu: $e');
      }
    }
  }

  // Favoriden çıkarma fonksiyonu
  Future<void> removeFavorite(String salonId) async {
    final currentUserId = getCurrentUserId();
    if (currentUserId != null) {
      try {
        // Hem kullanıcı ID'si hem de salon ID'si eşleşen kaydı sil
        await _client
            .from('favourites')
            .delete()
            .eq('user_id', currentUserId) // Bu kullanıcının
            .eq('saloon_id', salonId);     // Bu salona ait favorisini sil

        print('Favorilerden kaldırıldı: $salonId');
      } catch (e) {
        print('Favori kaldırılırken hata oluştu: $e');
      }
    }
  }
}