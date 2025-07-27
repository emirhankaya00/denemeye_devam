import 'package:flutter/foundation.dart';
import 'service_model.dart';

@immutable
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
  final List<ServiceModel> services;
  final double rating;                // ✔️ Ortalama puan
  final List<double> ratings;         // ✔️ İstersen yorum puanlarını sakla

  const SaloonModel({
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
    this.services = const [],
    this.rating = 0.0,
    this.ratings = const [],
  });

  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    /* ---- Hizmet listesi aynen bırakıldı ---- */
    List<ServiceModel> serviceList = [];
    if (json['services'] is List) {
      serviceList = (json['services'] as List)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['saloon_services'] is List) {
      serviceList = (json['saloon_services'] as List)
          .map((e) => e['services'] != null
          ? ServiceModel.fromJson(e['services'] as Map<String, dynamic>)
          : null)
          .whereType<ServiceModel>()
          .toList();
    }

    /* ---- YENİ: yorum puanlarını topla ---- */
    List<double> ratings = [];
    if (json['comments'] is List) {
      ratings = (json['comments'] as List)
          .map((c) => (c as Map<String, dynamic>)['rating'])
          .whereType<num>()
          .map((n) => n.toDouble())
          .toList();
    }

    // avg_rating SQL’den geliyorsa kullan; yoksa comments dizisinden hesapla
    double avgRating = json['avg_rating'] != null
        ? (json['avg_rating'] as num).toDouble()
        : (ratings.isNotEmpty
        ? ratings.reduce((a, b) => a + b) / ratings.length
        : 0.0);

    return SaloonModel(
      saloonId: json['saloon_id'] as String? ?? '',
      titlePhotoUrl: json['title_photo_url'] as String?,
      saloonName: json['saloon_name'] as String? ?? 'İsimsiz Salon',
      saloonDescription: json['saloon_description'] as String? ??
          json['description'] as String?,
      saloonAddress:
      json['saloon_address'] as String? ?? json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      services: serviceList,
      rating: avgRating,
      ratings: ratings,
    );
  }
}
