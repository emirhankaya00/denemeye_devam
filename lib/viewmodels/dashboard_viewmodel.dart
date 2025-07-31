import 'package:flutter/material.dart';
import 'package:denemeye_devam/models/saloon_model.dart';
import 'package:denemeye_devam/repositories/saloon_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardViewModel extends ChangeNotifier {
  GoogleMapController? mapController;
  Position? currentPosition;
  final SaloonRepository _repository = SaloonRepository(Supabase.instance.client);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SaloonModel> _nearbySaloons = [];
  List<SaloonModel> get nearbySaloons => _nearbySaloons;

  // --- YENİ LİSTELER EKLİYORUZ ---
  List<SaloonModel> _topRatedSaloons = [];
  List<SaloonModel> get topRatedSaloons => _topRatedSaloons;

  List<SaloonModel> _campaignSaloons = [];
  List<SaloonModel> get campaignSaloons => _campaignSaloons;


  DashboardViewModel() {
    fetchDashboardData();
  }
  Future<void> initLocation() async {
    // 1. Servis kontrol
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error('Konum servisi kapalı');
    }
    // 2. İzin iste
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        return Future.error('Konum izni reddedildi');
      }
    }
    if (perm == LocationPermission.deniedForever) {
      return Future.error('Konum izni kalıcı olarak reddedildi');
    }
    // 3. Konumu al
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  void moveCamera(LatLng newPosition, {double zoom = 14}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newPosition, zoom: zoom),
      ),
    );
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

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    // Tüm verileri aynı anda çekmek için Future.wait kullanabiliriz (daha verimli)
    final results = await Future.wait([
      _repository.getNearbySaloons(),
      _repository.getTopRatedSaloons(),
      _repository.getCampaignSaloons(), // <-- ÇAĞRIYI GERİ EKLEDİK
    ]);

    _nearbySaloons = results[0];
    _topRatedSaloons = results[1];
    _campaignSaloons = results[2]; // <-- LİSTEYİ DOLDURUYORUZ

    _isLoading = false;
    notifyListeners();
  }
}