// lib/data/repositories/comment_repository.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final SupabaseClient _client;
  CommentRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  /// Belirtilen salona ait tüm yorumları, kullanıcı bilgileriyle birlikte çeker.
  Future<List<CommentModel>> getCommentsForSalon(String salonId) async {
    try {
      final response = await _client
          .from('comments')
          .select('*, users(*)') // Yorumla birlikte kullanıcı bilgilerini de çek
          .eq('saloon_id', salonId)
          .order('created_at', ascending: false);

        return response
            .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      return [];
    } on PostgrestException catch (e) {
      debugPrint('Postgrest Hatası (getCommentsForSalon): ${e.message}');
      throw Exception('Yorumlar yüklenirken bir veritabanı hatası oluştu.');
    } catch (e) {
      debugPrint('Yorumları çekerken beklenmeyen bir hata oluştu: $e');
      throw Exception('Yorumlar yüklenemedi.');
    }
  }

  /// Yeni bir yorumu veritabanına ekler.
  Future<void> addComment({
    required String saloonId,
    required int rating,
    required String commentText,
    String? reservationId, // Opsiyonel olarak randevu ID'si
  }) async {
    if (_userId == null) {
      throw Exception('Yorum yapmak için giriş yapmalısınız.');
    }

    try {
      await _client.from('comments').insert({
        'user_id': _userId,
        'saloon_id': saloonId,
        'rating': rating,
        'comment_text': commentText,
        'reservation_id': reservationId, // Eğer null ise, veritabanı da null kabul etmeli
      });
    } on PostgrestException catch (e) {
      debugPrint('Postgrest Hatası (addComment): ${e.message}');
      throw Exception('Yorumunuz gönderilirken bir veritabanı hatası oluştu.');
    } catch (e) {
      debugPrint('Yorum eklenirken hata: $e');
      throw Exception('Yorumunuz gönderilemedi. Lütfen tekrar deneyin.');
    }
  }
}