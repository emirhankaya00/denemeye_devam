// lib/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Arka planda gelen bildirimleri işler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('--- Background Notification Received ---');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body : ${message.notification?.body}');
    debugPrint('Data : ${message.data}');
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// İzinleri ister, token alır, Supabase'e kaydeder, foreground ve background listener'ları ayarlar
  Future<void> initialize() async {
    // .env'i yükle (main'de de yapılmış olabilir)
    await dotenv.load();

    // 1) İzin iste
    await _messaging.requestPermission();

    // 2) Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3) Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('--- Foreground Notification ---');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body : ${message.notification?.body}');
        debugPrint('Data : ${message.data}');
      }
      // TODO: flutter_local_notifications ile bildirim göster
    });

    // 4) Token al ve Supabase'e kaydet
    final token = await _messaging.getToken();
    if (kDebugMode) debugPrint('FCM Token: $token');
    if (token != null) {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('users')
            .upsert({'id': user.id, 'fcm_token': token});
        if (kDebugMode) debugPrint('FCM token kaydedildi.');
      }
    }
  }

  /// Rezervasyon durumu güncellendiğinde sunucuya bildirim isteği gönderir
  static Future<void> sendReservationNotification({
    required String userId,
    required String status,
  }) async {
    // .env'den fonksiyon URL'sini al
    final functionsUrl = dotenv.env['SUPABASE_FUNCTIONS_URL'];
    if (functionsUrl == null) {
      if (kDebugMode) debugPrint('☠️ SUPABASE_FUNCTIONS_URL .env içinde yok!');
      return;
    }
    final endpoint = '\$functionsUrl/send-notification';
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'status': status,
        }),
      );
      if (kDebugMode && res.statusCode != 200) {
        debugPrint('❌ Notification send failed: \$res.statusCode \$res.body');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 NotificationService error: \$e');
    }
  }
}
