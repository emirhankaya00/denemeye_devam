import 'package:flutter/foundation.dart';
import 'category_with_services.dart';

@immutable
class SelectedItem {
  final SaloonServiceItem service;
  final int quantity;

  const SelectedItem({required this.service, required this.quantity});

  SelectedItem copyWith({SaloonServiceItem? service, int? quantity}) =>
      SelectedItem(service: service ?? this.service, quantity: quantity ?? this.quantity);

  double get lineTotal => service.price * quantity;

  Map<String, dynamic> toRpcJson() => {
    'service_id': service.serviceId,
    'quantity'  : quantity,
  };
}
