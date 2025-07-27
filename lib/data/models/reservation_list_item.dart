// lib/data/models/reservation_list_item.dart
import 'package:flutter/material.dart';

@immutable
class ReservationListItem {
  final String reservationId;
  final String saloonId;
  final String saloonName;
  final String? saloonPhoto;
  final DateTime date; // Tarih + saat birleşik
  final String status; // pending / approved / offered ...
  final double totalPrice;
  final List<ReservationServiceLine> lines;
  final DateTime? proposedDate; // Salondan gelen yeni tarih teklifi

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
    this.proposedDate,
  });

  factory ReservationListItem.fromJson(Map<String, dynamic> json) {
    // --- Yardımcı Fonksiyon (Tarih ve Saati Birleştirmek İçin) ---
    DateTime _combine(DateTime d, String t) {
      var h = 0, m = 0, s = 0;
      final p = t.toString().split(':');
      if (p.isNotEmpty) h = int.tryParse(p[0]) ?? 0;
      if (p.length >= 2) m = int.tryParse(p[1]) ?? 0;
      if (p.length >= 3) s = int.tryParse(p[2]) ?? 0;
      return DateTime(d.year, d.month, d.day, h, m, s);
    }

    // --- Alanları Ayrıştırma (Parsing) ---

    // 1. Orijinal Randevu Tarihi
    final rawDate = json['reservation_date'];
    final rawTime = json['reservation_time'];
    DateTime dt;
    if (rawDate is DateTime) {
      dt = (rawTime is String && rawTime.isNotEmpty)
          ? _combine(rawDate, rawTime)
          : rawDate;
    } else {
      final dStr = (rawDate ?? '').toString().split('T').first;
      final tStr = (rawTime ?? '').toString();
      dt = DateTime.tryParse('${dStr}T$tStr') ??
          DateTime.tryParse('$dStr $tStr') ??
          DateTime.tryParse((rawDate ?? '').toString()) ??
          DateTime.now();
    }

    // 2. Salon Bilgisi
    final salon = json['saloons'] as Map<String, dynamic>?;

    // 3. Hizmet Satırları
    final lines = (json['reservation_services'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ReservationServiceLine.fromJson)
        .toList();

    // 4. Toplam Fiyat
    final totalRaw = json['total_price'];
    final total = (totalRaw is num)
        ? totalRaw.toDouble()
        : double.tryParse(totalRaw?.toString() ?? '') ?? 0.0;

    // 5. Yeni Teklif Tarihi (varsa)
    final rawProposedDate = json['proposed_date'];
    final DateTime? proposedDate = rawProposedDate == null
        ? null
        : DateTime.tryParse(rawProposedDate.toString());

    // --- Modeli Oluşturup Geri Döndürme ---
    return ReservationListItem(
      reservationId: json['reservation_id'].toString(),
      saloonId: json['saloon_id'].toString(),
      saloonName: (salon?['saloon_name'] ?? '').toString(),
      saloonPhoto: salon?['title_photo_url'] as String?,
      date: dt,
      status: (json['status'] ?? 'pending').toString(),
      totalPrice: total,
      lines: lines,
      proposedDate: proposedDate, // Düzeltilmiş ve doğru yere eklenmiş alan
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

    int _parseEstimatedMinutes(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      final s = v.toString();
      final parts = s.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m;
      }
      return int.tryParse(s) ?? 0;
    }

    double _parsePrice(Map<String, dynamic> j) {
      final raw = j['unit_price'] ?? j['service_price_at_res'] ?? j['price'] ?? 0;
      if (raw is num) return raw.toDouble();
      return double.tryParse(raw.toString()) ?? 0.0;
    }

    int _parseQty(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse((v ?? '1').toString()) ?? 1;
    }

    return ReservationServiceLine(
      serviceId: (svc?['service_id'] ?? json['service_id']).toString(),
      serviceName: (svc?['service_name'] ?? json['service_name'] ?? '').toString(),
      estimatedMinutes: _parseEstimatedMinutes(
        svc?['estimated_time'] ?? svc?['estimated_minutes'] ?? json['estimated_minutes'],
      ),
      quantity: _parseQty(json['quantity']),
      unitPrice: _parsePrice(json),
    );
  }
}