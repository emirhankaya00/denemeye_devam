class SaloonModel {
  final String saloonId;
  final String? titlePhotoUrl;
  final String saloonName;
  final String? saloonDescription;
  final String? saloonAddress;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaloonModel({
    required this.saloonId,
    this.titlePhotoUrl,
    required this.saloonName,
    this.saloonDescription,
    this.saloonAddress,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    return SaloonModel(
      saloonId: json['saloon_id'],
      titlePhotoUrl: json['title_photo_url'],
      saloonName: json['saloon_name'],
      saloonDescription: json['saloon_description'],
      saloonAddress: json['saloon_address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'],
      email: json['email'],
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saloon_id': saloonId,
      'title_photo_url': titlePhotoUrl,
      'saloon_name': saloonName,
      'saloon_description': saloonDescription,
      'saloon_address': saloonAddress,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
