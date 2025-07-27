// lib/data/models/reservation_list_item.dart
import 'package:flutter/material.dart';

@immutable
class ReservationListItem {
  final String reservationId;
  final String saloonId;
  final String saloonName;
  final String? saloonPhoto;

  /// Tarih + saat birleşik
  final DateTime date;

  /// pending / approved / rejected / canceled_by_user ...
  final String status;

  /// reservations.total_price (toplam)
  final double totalPrice;

  /// Satırlar (reservation_services + services join)
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
    // ── Tarih+Saat ─────────────────────────────────────────────────────────────
    final rawDate = json['reservation_date'];
    final rawTime = json['reservation_time'];

    DateTime _combine(DateTime d, String t) {
      var h = 0, m = 0, s = 0;
      final p = (t).toString().split(':');
      if (p.isNotEmpty) h = int.tryParse(p[0]) ?? 0;
      if (p.length >= 2) m = int.tryParse(p[1]) ?? 0;
      if (p.length >= 3) s = int.tryParse(p[2]) ?? 0;
      return DateTime(d.year, d.month, d.day, h, m, s);
    }

    DateTime dt;
    if (rawDate is DateTime) {
      dt = (rawTime is String && rawTime.isNotEmpty)
          ? _combine(rawDate, rawTime)
          : rawDate;
    } else {
      final dStr = (rawDate ?? '').toString().split('T').first; // YYYY-MM-DD
      final tStr = (rawTime ?? '').toString(); // HH:MM[:SS]
      dt = DateTime.tryParse('${dStr}T$tStr') ??
          DateTime.tryParse('$dStr $tStr') ??
          DateTime.tryParse((rawDate ?? '').toString()) ??
          DateTime.now();
    }

    // ── Salon bilgisi (join: saloons(*)) ──────────────────────────────────────
    final salon = json['saloons'] as Map<String, dynamic>?;

    // ── Satırlar (join: reservation_services(*, services(*))) ─────────────────
    final lines = (json['reservation_services'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ReservationServiceLine.fromJson)
        .toList();

    // ── Toplam fiyat ──────────────────────────────────────────────────────────
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
      lines: lines,
    );
  }
}

@immutable
class ReservationServiceLine {
  final String serviceId;
  final String serviceName;

  /// Dakika cinsinden tahmini süre
  final int estimatedMinutes;

  final int quantity;

  /// Satır birim fiyatı (reservation_services.service_price_at_res)
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

    // Süre: services.estimated_time (interval: "HH:MM:SS") veya estimated_minutes (int)
    int _parseEstimatedMinutes(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      final s = v.toString();
      final parts = s.split(':'); // "HH:MM:SS" / "MM:SS"
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m;
      }
      return int.tryParse(s) ?? 0;
    }

    // Fiyat: repository’de alias kullandıysan (unit_price:service_price_at_res) direkt unit_price gelir.
    // Yine de fallback koyalım.
    double _parsePrice(Map<String, dynamic> j) {
      final raw = j['unit_price'] ?? j['service_price_at_res'] ?? j['price'] ?? 0;
      if (raw is num) return raw.toDouble();
      return double.tryParse(raw.toString()) ?? 0.0;
    }

    // Adet
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
