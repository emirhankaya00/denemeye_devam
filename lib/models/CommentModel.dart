class CommentModel {
  final String commentId;
  final String userId;
  final String? saloonId;
  final String? personalId;
  final int rating;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.commentId,
    required this.userId,
    this.saloonId,
    this.personalId,
    required this.rating,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'],
      userId: json['user_id'],
      saloonId: json['saloon_id'],
      personalId: json['personal_id'],
      rating: json['rating'],
      commentText: json['comment_text'],
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
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
