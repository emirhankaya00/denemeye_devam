// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UYGULAMA KAPALIYKEN VEYA ARKA PLANDAYKEN BİLDİRİM GELDİĞİNDE BU FONKSİYON ÇALIŞIR.
// ÖNEMLİ: BU FONKSİYON BİR SINIFIN DIŞINDA, DOSYANIN EN ÜST SEVİYESİNDE OLMALIDIR.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Geliştirme aşamasında loglama yapmak faydalıdır.
  if (kDebugMode) {
    print("--- Arka Plan Bildirimi Geldi ---");
    print("Bildirim Başlığı: ${message.notification?.title}");
    print("Bildirim İçeriği: ${message.notification?.body}");
    print("Özel Veri (Data): ${message.data}");
  }
}

class NotificationService {
  // Firebase Messaging nesnesini tek bir yerden yönetmek için.
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Supabase istemcisini kolay erişim için al.
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Bildirim sistemini başlatan ve gerekli izinleri alan ana fonksiyon.
  Future<void> initialize() async {
    // 1. Apple (iOS, macOS) cihazlar için bildirim izni iste.
    // Android'de bu genellikle otomatik yönetilir ama istemek en iyi pratiktir.
    await _firebaseMessaging.requestPermission();

    // 2. Cihaza özel FCM (Firebase Cloud Messaging) token'ını al.
    final String? fcmToken = await _firebaseMessaging.getToken();

    // Token'ı konsola yazdırarak test et.
    if (kDebugMode) {
      print("====================================");
      print("Cihazın FCM Token'ı: $fcmToken");
      print("====================================");
    }

    // 3. Alınan token'ı Supabase veritabanına kaydet.
    if (fcmToken != null) {
      await _saveTokenToSupabase(fcmToken);
    }

    // 4. Uygulama ön plandayken gelecek bildirimleri dinleyecek listener'ı ayarla.
    _setupForegroundNotificationListener();
  }

  /// Alınan FCM token'ını Supabase'deki ilgili kullanıcının profiline kaydeder veya günceller.
  Future<void> _saveTokenToSupabase(String token) async {
    // Giriş yapmış olan mevcut kullanıcıyı al.
    final currentUser = _supabaseClient.auth.currentUser;

    if (currentUser != null) {
      try {
        // 'fcm_token' -> Bu token'ı saklayacağın sütunun adı. (Bu sütunu tablonuzda oluşturmalısınız)
        await _supabaseClient
            .from('users') // KENDİ KULLANICI TABLONUN ADINI YAZ
            .upsert({
          'id': currentUser.id,
          'fcm_token': token
        });

        if (kDebugMode) {
          print("✅ FCM Token, Supabase'e başarıyla kaydedildi.");
        }
      } catch (error) {
        if (kDebugMode) {
          print("❌ Supabase'e token kaydederken hata oluştu: $error");
        }
      }
    } else {
      if (kDebugMode) {
        print("🤔 Token kaydedilemedi: Aktif bir kullanıcı bulunamadı.");
      }
    }
  }

  /// Uygulama ekranı açıkken (ön planda) gelen bildirimleri dinler.
  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('--- Uygulama Ön Plandayken Bildirim Geldi ---');
        if (message.notification != null) {
          print('Başlık: ${message.notification!.title}');
          print('İçerik: ${message.notification!.body}');

          // TODO: Uygulama açıkken bildirim göstermek için
          // flutter_local_notifications paketini kullanarak burada yerel bir
          // bildirim tetikleyebilirsin.
        }
      }
    });
  }
}