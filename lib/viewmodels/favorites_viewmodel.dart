import 'package:denemeye_devam/models/FavouriteModel.dart';
import 'package:denemeye_devam/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/SaloonModel.dart';
import 'package:denemeye_devam/repositories/favorites_repository.dart';
import '../repositories/saloon_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository = FavoritesRepository(
    Supabase.instance.client,
  );
  final currentUser = Supabase.instance.client.auth.currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SaloonModel> _favoriteSaloons = [];
  List<SaloonModel> get favoriteSaloons => _favoriteSaloons;

  List<SaloonModel> _filteredFavoriteSaloons = [];
  List<SaloonModel> get filteredFavoriteSaloons => _filteredFavoriteSaloons;

  Future<void> fetchFavoriteSaloons() async {
    _isLoading = true;
    notifyListeners();
    final currentUser = _repository.getCurrentUserId();
    if (currentUser != null) {
      final fetchedSaloons = await _repository.getFavoriteSaloons(currentUser);
    } else {
      // Eğer kullanıcı yoksa listeleri boşalt
      _favoriteSaloons = [];
      _filteredFavoriteSaloons = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  void searchFavorites(String query) {
    if (query.isEmpty) {
      _filteredFavoriteSaloons = _favoriteSaloons;
    } else {
      _filteredFavoriteSaloons = _favoriteSaloons.where((salon) {
        return salon.saloonName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> removeFavorite(String salonId) async {
    await _repository.removeFavorite(salonId);
    await fetchFavoriteSaloons();
  }

  Future<void> bookAppointment(BuildContext context, SaloonModel salon) async {
    await _repository.addFavorite(salon.saloonId);
    await fetchFavoriteSaloons();
  }
}
