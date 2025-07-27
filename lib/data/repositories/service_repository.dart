import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_model.dart';

class ServiceRepository {
  final _client = Supabase.instance.client;

  Future<List<ServiceModel>> getAllServices() async {
    final res = await _client
        .from('services')
        .select('service_id, service_name, description, estimated_time, base_price')
        .order('service_name');

    return (res as List).map((e) {
      return ServiceModel(
        serviceId:    e['service_id'] as String,
        serviceName:  e['service_name'] as String,
        description:  e['description'] as String?,
        estimatedTime: _parseInterval(e['estimated_time']),
        basePrice:    (e['base_price'] is num)
            ? (e['base_price'] as num).toDouble()
            : double.tryParse('${e['base_price']}') ?? 0.0,
      );
    }).toList();
  }

  /// "HH:MM:SS" / "H:MM:SS" gibi değerleri Duration'a çevirir.
  Duration _parseInterval(dynamic v) {
    if (v == null) return Duration.zero;
    final s = v.toString();
    final parts = s.split(':');
    if (parts.length < 2) return Duration.zero;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final sec = (parts.length > 2) ? int.tryParse(parts[2]) ?? 0 : 0;
    return Duration(hours: h, minutes: m, seconds: sec);
  }
}
