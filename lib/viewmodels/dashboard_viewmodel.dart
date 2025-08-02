import 'package:flutter/material.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardViewModel extends ChangeNotifier {
  String? locationError;
  GoogleMapController? mapController;
  Position? currentPosition;
  final SaloonRepository _repository = SaloonRepository(Supabase.instance.client);

  // Constructor artık boş. ViewModel oluşturulunca otomatik bir işlem yapmıyor.
  DashboardViewModel();

  /// Cihazın konumunu alır ve `currentPosition` değişkenini günceller.
  /// Hata durumlarını ve izinleri yönetir.
  Future<void> initLocation() async {
    locationError = null;
    notifyListeners();
//
    try {
      // 1) Servis açık mı?
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Konum servisi kapalı. Açın lütfen.';
      }

      // 2) Mevcut izni al
      var perm = await Geolocator.checkPermission();

      // 3) Eğer reddedilmiş (tek seferlik veya kalıcı) ise tekrar sor
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }

      // 4) Hala reddedildiyse hata atmaca
      if (perm == LocationPermission.denied) {
        throw 'Konum izni reddedildi.';
      }

      // 5) Kalıcı reddedildiyse direkt ayarlara yolla
      if (perm == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.';
      }

      // 6) Pozisyonu çek
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      locationError = null;
    } catch (e) {
      locationError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// UI'daki FutureBuilder'ların kullanması için repository'deki metodu doğrudan çağırır.
  Future<List<SaloonModel>> getNearbySaloons() {
    return _repository.getNearbySaloons();
  }

  /// UI'daki FutureBuilder'ların kullanması için repository'deki metodu doğrudan çağırır.
  Future<List<SaloonModel>> getTopRatedSaloons() {
    return _repository.getTopRatedSaloons();
  }

  /// UI'daki FutureBuilder'ların kullanması için repository'deki metodu doğrudan çağırır.
  Future<List<SaloonModel>> getCampaignSaloons() {
    return _repository.getCampaignSaloons();
  }


  // --- Harita Kontrol Metodları (Değişiklik yok) ---

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void moveCameraToUser() {
    if (currentPosition != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentPosition!.latitude,
              currentPosition!.longitude,
            ),
            zoom: 14,
          ),
        ),
      );
    }
  }
}

