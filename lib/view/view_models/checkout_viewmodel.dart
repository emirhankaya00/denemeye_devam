// lib/view/view_models/checkout_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/selected_item.dart';
import '../../data/repositories/saloon_repository.dart';

class CheckoutViewModel extends ChangeNotifier {
  final SaloonRepository _repo;
  CheckoutViewModel(this._repo);

  bool isSubmitting = false;
  String? lastError;

  Future<bool> submit({
    required String saloonId,
    required DateTime date,
    required TimeOfDay time,
    required List<SelectedItem> items,
    String? personalId, // opsiyonel
  }) async {
    // 1) Kullanıcı kimliği
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      lastError = 'Oturum bulunamadı. Lütfen giriş yapınız.';
      return false;
    }

    isSubmitting = true;
    notifyListeners();
    try {
      final reservationId = await _repo.createReservation(
        userId: userId,              // ← ZORUNLU: artık null göndermiyoruz
        saloonId: saloonId,
        personalId: personalId,
        date: date,
        time: time,
        items: items,
      );
      if (reservationId == null) {
        lastError = 'Sunucu yanıtı başarısız. Lütfen tekrar deneyin.';
        return false;
      }
      return true;
    } catch (e) {
      lastError = 'Beklenmeyen hata: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
