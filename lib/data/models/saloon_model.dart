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
  final double rating;        // Ortalama puan (yoksa 0.0)
  final List<double> ratings; // Yorumlardan tekil puanlar

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

  // -----------------------------
  // JSON helpers
  // -----------------------------
  static String _asString(dynamic v) => v == null ? '' : v.toString();

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static DateTime _asDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  /// Hem snake_case hem camelCase alan adlarını destekler.
  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    // --- ID / temel alanlar ---
    final id = _asString(json['saloon_id'] ?? json['saloonId'] ?? json['id']);
    final name = _asString(json['saloon_name'] ?? json['saloonName'] ?? json['name']);
    final desc = json['saloon_description'] ?? json['saloonDescription'] ?? json['description'];
    final addr = json['saloon_address'] ?? json['saloonAddress'] ?? json['address'];
    final photo = json['title_photo_url'] ?? json['titlePhotoUrl'];
    final phone = json['phone_number'] ?? json['phoneNumber'];

    final lat = _asDouble(json['latitude']);
    final lng = _asDouble(json['longitude']);

    final created = _asDateTime(json['created_at'] ?? json['createdAt']);
    final updated = _asDateTime(json['updated_at'] ?? json['updatedAt']);

    // --- Hizmetler (iki olası yapı) ---
    final List<ServiceModel> serviceList = [];
    final rawServices = json['services'] ?? json['saloon_services'] ?? json['saloonServices'];
    if (rawServices is List) {
      for (final item in rawServices) {
        if (item is Map<String, dynamic>) {
          // 1) { ..., services: { service_id, service_name, ... } }
          if (item['services'] is Map<String, dynamic>) {
            serviceList.add(ServiceModel.fromJson(item['services'] as Map<String, dynamic>));
          } else {
            // 2) { service_id, service_name, ... } doğrudan servis satırı olabilir
            serviceList.add(ServiceModel.fromJson(item));
          }
        }
      }
    }

    // --- Rating doğrudan / ortalama ---
    double? avg = _asDouble(json['rating'] ?? json['avg_rating'] ?? json['average_rating']);

    // Yorumlardan tekil puanlar (varsa)
    final List<double> ratingList = [];
    if (json['comments'] is List) {
      for (final c in (json['comments'] as List)) {
        if (c is Map<String, dynamic>) {
          final r = _asDouble(c['rating']);
          if (r != null) ratingList.add(r);
        }
      }
    }
    // Ortalama yoksa yorumlardan hesapla
    avg ??= ratingList.isNotEmpty
        ? ratingList.reduce((a, b) => a + b) / ratingList.length
        : 0.0;

    return SaloonModel(
      saloonId: id,
      titlePhotoUrl: photo as String?,
      saloonName: name.isNotEmpty ? name : 'İsimsiz Salon',
      saloonDescription: desc as String?,
      saloonAddress: addr as String?,
      latitude: lat,
      longitude: lng,
      phoneNumber: phone as String?,
      email: json['email'] as String?,
      createdAt: created,
      updatedAt: updated,
      services: serviceList,
      rating: avg,
      ratings: ratingList,
    );
  }

  Map<String, dynamic> toJson() => {
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
    // Not: services genelde ayrı tabloda; burada yalnızca özet yazmak istersen map’leyebilirsin.
    'rating': rating,
    'ratings': ratings,
  };

  SaloonModel copyWith({
    String? saloonId,
    String? titlePhotoUrl,
    String? saloonName,
    String? saloonDescription,
    String? saloonAddress,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ServiceModel>? services,
    double? rating,
    List<double>? ratings,
  }) {
    return SaloonModel(
      saloonId: saloonId ?? this.saloonId,
      titlePhotoUrl: titlePhotoUrl ?? this.titlePhotoUrl,
      saloonName: saloonName ?? this.saloonName,
      saloonDescription: saloonDescription ?? this.saloonDescription,
      saloonAddress: saloonAddress ?? this.saloonAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      ratings: ratings ?? this.ratings,
    );
  }

  @override
  String toString() =>
      'SaloonModel(id:$saloonId, name:$saloonName, rating:$rating, services:${services.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaloonModel && runtimeType == other.runtimeType && saloonId == other.saloonId;

  @override
  int get hashCode => saloonId.hashCode;
}
