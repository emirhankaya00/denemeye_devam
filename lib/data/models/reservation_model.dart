// lib/data/models/reservation_model.dart

import 'package:flutter/foundation.dart';
import 'saloon_model.dart';
import 'service_model.dart';

// --- ENUM TANIMI BURADA OLMALI ---
// ReservationStatus, randevunun durumunu belirtmek için kullanılır.
// String veya integer kullanmak yerine enum kullanmak,
// olası yazım hatalarını engeller ve kodu daha anlaşılır kılar.
enum ReservationStatus {
  pending,
  offered,
  confirmed,
  completed,
  cancelled,
  noShow, rejected
}

class ReservationModel {
  final String reservationId;
  final String userId;
  final String saloonId;
  final String? personalId;
  final DateTime reservationDate;
  final String reservationTime;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SaloonModel? saloon;
  final ServiceModel? service;

  ReservationModel({
    required this.reservationId,
    required this.userId,
    required this.saloonId,
    this.personalId,
    required this.reservationDate,
    required this.reservationTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.saloon,
    this.service,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // 1. Salon bilgisini güvenli bir şekilde parse et
    SaloonModel? parsedSaloon;
    if (json['saloons'] != null && json['saloons'] is Map<String, dynamic>) {
      try {
        parsedSaloon = SaloonModel.fromJson(json['saloons']);
      } catch (e) {
        debugPrint("SaloonModel parse hatası: $e");
        parsedSaloon = null; // Hata durumunda null ata
      }
    }

    // 2. Servis bilgisini güvenli bir şekilde parse et
    ServiceModel? parsedService;
    if (json['reservation_services'] != null && (json['reservation_services'] as List).isNotEmpty) {
      // Genelde bir randevuda bir ana hizmet olur, bu yüzden ilk elemanı alıyoruz.
      final serviceData = json['reservation_services'][0]['services'];
      if (serviceData != null && serviceData is Map<String, dynamic>) {
        try {
          parsedService = ServiceModel.fromJson(serviceData);
        } catch (e) {
          debugPrint("ServiceModel parse hatası: $e");
          parsedService = null; // Hata durumunda null ata
        }
      }
    }

    return ReservationModel(
      reservationId: json['reservation_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      saloonId: json['saloon_id'] as String? ?? '',
      personalId: json['personal_id'] as String?,
      reservationDate: DateTime.tryParse(json['reservation_date'] ?? '') ?? DateTime.now(),
      reservationTime: json['reservation_time'] as String? ?? '00:00',
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending, // Eşleşme bulunmazsa varsayılan ata
      ),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      saloon: parsedSaloon,
      service: parsedService,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'user_id': userId,
      'saloon_id': saloonId,
      'personal_id': personalId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0],
      'reservation_time': reservationTime,
      'total_price': totalPrice,
      'status': status.name, // Enum'ı string'e çevirerek kaydet
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}