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
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Konum servisi kapalı. Lütfen aktif hale getirin.';
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          throw 'Konum izni reddedildi.';
        }
      }
      if (perm == LocationPermission.deniedForever) {
        throw 'Konum izni kalıcı olarak reddedildi. Ayarlardan izin vermeniz gerekmektedir.';
      }
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Konum alındığında dinleyicileri (UI'ı) bilgilendir.
      notifyListeners();
    } catch (e) {
      debugPrint("Konum alınamadı: $e");
      locationError = e.toString();
      // UI'da gösterilecek bir hata durumu da yönetilebilir.
    }
    finally {
      notifyListeners(); // <-- Başarılı veya hatalı her durumda UI'ı güncelle
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