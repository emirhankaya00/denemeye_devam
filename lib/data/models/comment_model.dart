// lib/data/models/comment_model.dart
import 'user_model.dart'; // UserModel'i import edin

class CommentModel {
  final String commentId;
  final String userId;
  final String? saloonId;
  final String? personalId;
  final int rating;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user; // Kullanıcı bilgisi için UserModel eklendi

  CommentModel({
    required this.commentId,
    required this.userId,
    this.saloonId,
    this.personalId,
    required this.rating,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
    this.user, // Constructor'a user eklendi
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    UserModel? parsedUser;
    // Supabase'den 'users' tablosu ilişkilendirilmiş olarak geliyorsa parse et
    if (json['users'] != null && json['users'] is Map<String, dynamic>) {
      try {
        parsedUser = UserModel.fromJson(json['users']);
      } catch (e) {
        print('UserModel parse hatası: $e - Veri: ${json['users']}');
        parsedUser = null;
      }
    }

    return CommentModel(
      commentId: json['comment_id'] as String,
      userId: json['user_id'] as String,
      saloonId: json['saloon_id'] as String?,
      personalId: json['personal_id'] as String?,
      rating: json['rating'] as int,
      commentText: json['comment_text'] as String,
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
      user: parsedUser, // Parse edilmiş user'ı ata
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'user_id': userId,
      'saloon_id': saloonId,
      'personal_id': personalId,
      'rating': rating,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}