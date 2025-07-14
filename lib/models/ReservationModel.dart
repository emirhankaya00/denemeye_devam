
enum ReservationStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow
}

class ReservationModel {
  final String reservationId;
  final String userId;
  final String saloonId;
  final String personalId;
  final DateTime reservationDate;     // sadece tarih
  final String reservationTime;       // saat kısmı, HH:mm:ss string olarak alınır
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservationModel({
    required this.reservationId,
    required this.userId,
    required this.saloonId,
    required this.personalId,
    required this.reservationDate,
    required this.reservationTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      reservationId: json['reservation_id'],
      userId: json['user_id'],
      saloonId: json['saloon_id'],
      personalId: json['personal_id'],
      reservationDate: DateTime.parse(json['reservation_date']),
      reservationTime: json['reservation_time'],
      totalPrice: (json['total_price'] as num).toDouble(),
      status: ReservationStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ReservationStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservation_id': reservationId,
      'user_id': userId,
      'saloon_id': saloonId,
      'personal_id': personalId,
      'reservation_date': reservationDate.toIso8601String().split('T')[0], // sadece tarih
      'reservation_time': reservationTime, // genelde string tutulur (örn: "14:30:00")
      'total_price': totalPrice,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
