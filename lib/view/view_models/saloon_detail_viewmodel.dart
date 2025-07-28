// lib/view/view_models/saloon_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/saloon_model.dart';
import '../../data/models/selected_item.dart';
import '../../data/models/category_with_services.dart';
import '../../data/repositories/saloon_repository.dart';
import '../../data/repositories/favorites_repository.dart';
// DÜZELTME: Yorum ve Rezervasyon repository'leri eklendi
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/reservation_repository.dart';

class SalonDetailViewModel extends ChangeNotifier {
  // --- REPOSITORIES ---
  final SaloonRepository _saloonRepo;
  final FavoritesRepository _favoritesRepo = FavoritesRepository(Supabase.instance.client);
  // DÜZELTME: Yeni repository'ler eklendi
  final CommentRepository _commentRepo = CommentRepository(Supabase.instance.client);
  final ReservationRepository _reservationRepo = ReservationRepository(Supabase.instance.client);

  SalonDetailViewModel(this._saloonRepo);


  // --- STATE ---
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SaloonModel? _salon;
  SaloonModel? get salon => _salon;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  // DÜZELTME: Yorum yapma yetkisi için yeni state
  bool _canUserComment = false;
  bool get canUserComment => _canUserComment;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final List<CategoryWithServices> _categories = [];
  List<CategoryWithServices> get categories => List.unmodifiable(_categories);

  final List<SelectedItem> _selectedItems = [];
  List<SelectedItem> get selectedItems => List.unmodifiable(_selectedItems);

  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay get selectedTime => _selectedTime;


  // --- COMPUTED ---
  int get totalCount => _selectedItems.length;
  double get totalPrice => _selectedItems.fold(0.0, (sum, e) => sum + e.lineTotal);


  // --- LOAD ---
  Future<void> fetchSalonDetails(String saloonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Salon detaylarını, hizmetleri ve favori durumunu aynı anda çek
      final results = await Future.wait([
        _saloonRepo.getSaloonById(saloonId),
        _saloonRepo.getSaloonCategoriesWithServices(saloonId),
        _favoritesRepo.isFavorite(saloonId),
        // DÜZELTME: Yorum yapma yetkisini de aynı anda kontrol et
        _reservationRepo.canUserComment(saloonId),
      ]);

      _salon = results[0] as SaloonModel?;
      final cats = results[1] as List<CategoryWithServices>;
      _categories
        ..clear()
        ..addAll(cats);
      _isFavorite = results[2] as bool;
      _canUserComment = results[3] as bool;

    } catch (e) {
      debugPrint('SalonDetailViewModel.fetchSalonDetails Hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ACTIONS ---

  Future<void> toggleFavorite() async {
    if (_salon == null) return;
    _isFavorite = !_isFavorite;
    notifyListeners();

    try {
      if (_isFavorite) {
        await _favoritesRepo.addFavorite(_salon!.saloonId);
      } else {
        await _favoritesRepo.removeFavorite(_salon!.saloonId);
      }
    } catch (e) {
      _isFavorite = !_isFavorite;
      notifyListeners();
    }
  }

  // DÜZELTME: Yorumu göndermek için yeni fonksiyon
  /// Kullanıcının yorumunu ve puanını veritabanına kaydeder.
  Future<bool> submitComment({
    required int rating,
    required String commentText,
  }) async {
    if (_salon == null) return false;

    try {
      await _commentRepo.addComment(
        saloonId: _salon!.saloonId,
        rating: rating,
        commentText: commentText,
      );
      // Yorum gönderildikten sonra, kullanıcının tekrar yorum yapmasını engellemek için
      // yetkiyi 'false' yapıyoruz. Sayfa yenilendiğinde gerçek durum tekrar çekilir.
      _canUserComment = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Yorum gönderme hatası: $e");
      // Arayüzde bir hata mesajı göstermek için bu bilgi kullanılabilir.
      return false;
    }
  }

  // --- DATE/TIME ---
  void selectNewDate(DateTime d) {
    _selectedDate = d;
    notifyListeners();
  }

  void selectNewTime(TimeOfDay t) {
    _selectedTime = t;
    notifyListeners();
  }

  // --- SELECTION LOGIC ---
  bool isSelected(String serviceId) {
    return _selectedItems.any((e) => e.service.serviceId == serviceId);
  }

  void toggle(SaloonServiceItem item) {
    final idx = _selectedItems.indexWhere((e) => e.service.serviceId == item.serviceId);
    if (idx >= 0) {
      _selectedItems.removeAt(idx);
    } else {
      _selectedItems.add(SelectedItem(service: item, quantity: 1));
    }
    notifyListeners();
  }

  void preselectByServiceIds(List<String> ids) {
    final idSet = ids.toSet();
    for (final cat in _categories) {
      for (final item in cat.services) {
        if (idSet.contains(item.serviceId) && !isSelected(item.serviceId)) {
          _selectedItems.add(SelectedItem(service: item, quantity: 1));
        }
      }
    }
    notifyListeners();
  }

  void clearSelections() {
    _selectedItems.clear();
    notifyListeners();
  }
}