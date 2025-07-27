import 'package:flutter/foundation.dart';

@immutable
class SaloonServiceItem {
  final String serviceId;
  final String serviceName;
  final double price;          // salona özel fiyat (yoksa base_price)
  final int estimatedMinutes;  // RPC int döndürüyor

  const SaloonServiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.estimatedMinutes,
  });

  factory SaloonServiceItem.fromJson(Map<String, dynamic> json) => SaloonServiceItem(
    serviceId: (json['service_id'] ?? json['serviceId']).toString(),
    serviceName: (json['service_name'] ?? json['serviceName']).toString(),
    price: (json['price'] as num).toDouble(),
    estimatedMinutes: (json['estimated_minutes'] as num).toInt(),
  );
}

@immutable
class CategoryWithServices {
  final String categoryId;
  final String categoryName;
  final List<SaloonServiceItem> services;

  const CategoryWithServices({
    required this.categoryId,
    required this.categoryName,
    required this.services,
  });

  factory CategoryWithServices.fromJson(Map<String, dynamic> json) => CategoryWithServices(
    categoryId: (json['category_id'] ?? json['categoryId']).toString(),
    categoryName: (json['category_name'] ?? json['categoryName']).toString(),
    services: (json['services'] as List<dynamic>)
        .map((e) => SaloonServiceItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
