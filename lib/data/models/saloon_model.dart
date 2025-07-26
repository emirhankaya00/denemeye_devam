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
  final double rating; // YENİ: Ortalama puan alanı

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
    this.rating = 0.0, // Varsayılan değer
  });

  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    // ... (Hizmet listesini ayrıştıran kod aynı kalıyor)
    final List<ServiceModel> serviceList;
    if (json['services'] != null && json['services'] is List) {
      serviceList = (json['services'] as List).map((serviceJson) => ServiceModel.fromJson(serviceJson as Map<String, dynamic>)).toList();
    } else if (json['saloon_services'] != null && json['saloon_services'] is List) {
      serviceList = (json['saloon_services'] as List).map((s) => ServiceModel.fromJson(s['services'])).whereType<ServiceModel>().toList();
    } else {
      serviceList = const [];
    }

    return SaloonModel(
      saloonId: json['saloon_id'] as String? ?? '',
      titlePhotoUrl: json['title_photo_url'] as String?,
      saloonName: json['saloon_name'] as String? ?? 'İsimsiz Salon',
      saloonDescription: json['saloon_description'] as String? ?? json['description'] as String?,
      saloonAddress: json['saloon_address'] as String? ?? json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      services: serviceList,
      // YENİ: SQL'de hesaplanan ortalama puanı okuyoruz.
      rating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}