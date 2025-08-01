// lib/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!Firebase.apps.isNotEmpty) await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('--- Background Notification ---');
    debugPrint('title: ${message.notification?.title}');
    debugPrint('body: ${message.notification?.body}');
    debugPrint('data: ${message.data}');
  }
}

class NotificationService {
  late final FirebaseMessaging _messaging;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      if (kDebugMode) {
        debugPrint('--- Foreground Notification ---');
        debugPrint('title: ${msg.notification?.title}');
        debugPrint('body: ${msg.notification?.body}');
        debugPrint('data: ${msg.data}');
      }
    });
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (kDebugMode) debugPrint('FCM Token: $token');
    if (token != null) {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('users')
            .upsert({'id': user.id, 'fcm_token': token});
        if (kDebugMode) debugPrint('✅ Token kaydedildi');
      }
    }
  }

  static Future<void> sendReservationNotification({
    required String userId,
    required String status,
  }) async {
    final functionsUrl = dotenv.env['SUPABASE_FUNCTIONS_URL'];
    if (functionsUrl == null) {
      if (kDebugMode) debugPrint('SUPABASE_FUNCTIONS_URL eksik');
      return;
    }
    final endpoint = '$functionsUrl/send-notification';
    if (kDebugMode) {
      debugPrint('📨 Sending to $endpoint');
      debugPrint('Payload: {userId: $userId, status: $status}');
    }
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'status': status}),
      );
      if (kDebugMode) debugPrint('Response: ${res.statusCode} ${res.body}');
      if (res.statusCode != 200) throw Exception('Notification failed');
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending notification: $e');
    }
  }
}