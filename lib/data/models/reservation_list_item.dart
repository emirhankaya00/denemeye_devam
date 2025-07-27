// lib/data/models/reservation_list_item.dart
import 'package:flutter/material.dart';

@immutable
class ReservationListItem {
  final String reservationId;
  final String saloonId;
  final String saloonName;
  final String? saloonPhoto;
  /// Tarih + saat birleşik DateTime
  final DateTime date;
  /// pending / approved / rejected / cancelled ...
  final String status;
  final double totalPrice;
  final List<ReservationServiceLine> lines;

  bool get isUpcoming => date.isAfter(DateTime.now());

  const ReservationListItem({
    required this.reservationId,
    required this.saloonId,
    required this.saloonName,
    required this.saloonPhoto,
    required this.date,
    required this.status,
    required this.totalPrice,
    required this.lines,
  });

  factory ReservationListItem.fromJson(Map<String, dynamic> json) {
    // --- Tarih + saat birleştir ---
    final rawDate = json['reservation_date'];
    final rawTime = json['reservation_time'];

    DateTime parseWithTime(DateTime d, String t) {
      var h = 0, m = 0, s = 0;
      final parts = t.split(':');
      if (parts.isNotEmpty) h = int.tryParse(parts[0]) ?? 0;
      if (parts.length >= 2) m = int.tryParse(parts[1]) ?? 0;
      if (parts.length >= 3) s = int.tryParse(parts[2]) ?? 0;
      return DateTime(d.year, d.month, d.day, h, m, s);
    }

    DateTime dt;
    if (rawDate is DateTime) {
      // reservation_date DateTime gelmiş
      if (rawTime is String && rawTime.isNotEmpty) {
        dt = parseWithTime(rawDate, rawTime);
      } else {
        dt = rawDate;
      }
    } else {
      // String / diğer tipler
      final dateStr = (rawDate ?? '').toString().split('T').first; // 'YYYY-MM-DD'
      final timeStr = (rawTime ?? '').toString();                   // 'HH:MM:SS'
      dt = DateTime.tryParse('${dateStr}T$timeStr')  // ISO biçimi
          ?? DateTime.tryParse('$dateStr $timeStr')  // boşluklu biçim
          ?? DateTime.tryParse((rawDate ?? '').toString()) // belki tek başına tarih
          ?? DateTime.now();
    }

    // --- Salon bilgisi (join: saloons(*)) ---
    final salon = json['saloons'] as Map<String, dynamic>?;

    // --- Kalemler (join: reservation_services(*, services(*))) ---
    final rs = (json['reservation_services'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ReservationServiceLine.fromJson)
        .toList();

    // --- Fiyat ---
    final totalRaw = json['total_price'];
    final total = (totalRaw is num)
        ? totalRaw.toDouble()
        : double.tryParse(totalRaw?.toString() ?? '') ?? 0.0;

    return ReservationListItem(
      reservationId: json['reservation_id'].toString(),
      saloonId: json['saloon_id'].toString(),
      saloonName: (salon?['saloon_name'] ?? '').toString(),
      saloonPhoto: salon?['title_photo_url'] as String?,
      date: dt,
      status: (json['status'] ?? 'pending').toString(),
      totalPrice: total,
      lines: rs,
    );
  }
}

@immutable
class ReservationServiceLine {
  final String serviceId;
  final String serviceName;
  final int estimatedMinutes;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;

  const ReservationServiceLine({
    required this.serviceId,
    required this.serviceName,
    required this.estimatedMinutes,
    required this.quantity,
    required this.unitPrice,
  });

  factory ReservationServiceLine.fromJson(Map<String, dynamic> json) {
    final svc = json['services'] as Map<String, dynamic>?;

    // estimated_minutes güvenli parse
    final estRaw = svc?['estimated_minutes'] ?? json['estimated_minutes'] ?? 0;
    final est = (estRaw is num)
        ? estRaw.toInt()
        : int.tryParse(estRaw.toString()) ?? 0;

    // quantity güvenli parse
    final qtyRaw = json['quantity'] ?? 1;
    final qty = (qtyRaw is num)
        ? qtyRaw.toInt()
        : int.tryParse(qtyRaw.toString()) ?? 1;

    // unitPrice güvenli parse (unit_price yoksa price'a düş)
    final unitRaw = json['unit_price'] ?? json['price'] ?? 0;
    final price = (unitRaw is num)
        ? unitRaw.toDouble()
        : double.tryParse(unitRaw.toString()) ?? 0.0;

    return ReservationServiceLine(
      serviceId: (svc?['service_id'] ?? json['service_id']).toString(),
      serviceName: (svc?['service_name'] ?? json['service_name'] ?? '').toString(),
      estimatedMinutes: est,
      quantity: qty,
      unitPrice: price,
    );
  }
}
