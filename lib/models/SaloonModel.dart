import 'package:denemeye_devam/models/ServiceModel.dart'; // <-- ServiceModel'i import etmemiz gerekiyor!
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
  final List<ServiceModel> services; // <-- 1. YENİ ALAN: Hizmet listesi

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
    this.services = const []
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
      services: json['saloon_services'] != null
          ? (json['saloon_services'] as List)
      // Her bir 'saloon_service' kaydının içindeki 'services' nesnesini alıyoruz.
          .map((saloonServiceJson) {
        // Eğer içteki 'services' nesnesi null değilse, onu ServiceModel'e çevir.
        if (saloonServiceJson['services'] != null) {
          return ServiceModel.fromJson(saloonServiceJson['services']);
        }
        // Eğer bir şekilde null gelirse, bu adımı atla (null kontrolü)
        return null;
      })
      // Listede oluşabilecek null değerleri temizle.
          .where((service) => service != null)
          .cast<ServiceModel>()
          .toList()
          : [], // Eğer 'saloon_services' listesi gelmezse, boş bir liste ata.
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
