enum FavouriteType {
  saloon,
  personal
}
class FavouriteModel {
  final String id;
  final String userId;
  final String? saloonId;
  final String? personalId;
  final FavouriteType favouriteType;
  final DateTime createdAt;

  FavouriteModel({
    required this.id,
    required this.userId,
    this.saloonId,
    this.personalId,
    required this.favouriteType,
    required this.createdAt,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'],
      userId: json['user_id'],
      saloonId: json['saloon_id'],
      personalId: json['personal_id'],
      favouriteType: FavouriteType.values.firstWhere(
          (e) => e.name == json['favourite_type'],
          orElse: () => FavouriteType.saloon,
      ),
      createdAt: DateTime.tryParse(json['created_at' ?? '']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'saloon_id': saloonId,
      'personal_id': personalId,
      'favourite_type': favouriteType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
