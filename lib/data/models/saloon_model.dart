import 'package:flutter/foundation.dart';
import 'service_model.dart'; // Bu import'un doğru olduğundan emin ol

/// Salonları ve onlara bağlı hizmetleri temsil eden, değişmez (immutable) veri modeli.
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
    this.services = const [], // Varsayılan olarak boş liste ata
  });

  /// Veritabanından gelen JSON verisini bir [SaloonModel] nesnesine dönüştürür.
  factory SaloonModel.fromJson(Map<String, dynamic> json) {
    // --- KESİN ÇÖZÜM: 'services' LİSTESİNİ AYRIŞTIRMA MANTIĞI DÜZELTİLDİ ---
    // SQL fonksiyonumuz artık hizmetleri 'services' anahtarı altında
    // temiz bir liste olarak gönderiyor. Bu mantık doğrudan o listeyi işler.
    final List<ServiceModel> serviceList;
    if (json['services'] != null && json['services'] is List) {
      // Gelen listedeki her bir JSON objesini ServiceModel'e çeviriyoruz.
      // Hatalı veri gelme ihtimaline karşı try-catch bloğu eklenebilir ama şimdilik bu yeterli.
      serviceList = (json['services'] as List)
          .map((serviceJson) => ServiceModel.fromJson(serviceJson as Map<String, dynamic>))
          .toList();
    } else {
      // 'services' alanı null veya liste değilse, boş bir liste atıyoruz.
      serviceList = const [];
    }

    return SaloonModel(
      saloonId: json['saloon_id'] as String? ?? '',
      titlePhotoUrl: json['title_photo_url'] as String?,
      saloonName: json['saloon_name'] as String? ?? 'İsimsiz Salon',
      saloonDescription: json['description'] as String?, // Veritabanı sütun adını kontrol et ('saloon_description' olabilir)
      saloonAddress: json['address'] as String?, // Veritabanı sütun adını kontrol et ('saloon_address' olabilir)
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      services: serviceList,
    );
  }

  /// [SaloonModel] nesnesini bir JSON haritasına dönüştürür.
  /// Bu metod genellikle veritabanına veri gönderirken kullanılır.
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
      // services listesini de JSON'a eklemek istersen:
      // 'services': services.map((s) => s.toJson()).toList(),
    };
  }
}