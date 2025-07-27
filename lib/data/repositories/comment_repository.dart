// lib/data/repositories/comment_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart'; // UserModel'i import edin

class CommentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CommentModel>> getCommentsForSalon(String salonId) async {
    try {
      // Supabase'de 'comments' tablosundan yorumları çekerken
      // 'users(*)' ile ilişkili user bilgilerini (tüm sütunları) de çekiyoruz.
      final response = await _supabase
          .from('comments')
          .select('*, users(*)') // Yorumla birlikte kullanıcı bilgilerini de çek
          .eq('saloon_id', salonId)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      final List<CommentModel> comments = (response as List)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return comments;
    } on PostgrestException catch (e) {
      print('Postgrest Hatası (CommentRepository): ${e.message}');
      throw Exception('Veritabanı hatası: ${e.message}');
    } catch (e) {
      print('Yorumları çekerken beklenmeyen bir hata oluştu: $e');
      rethrow;
    }
  }
}