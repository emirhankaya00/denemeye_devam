import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:denemeye_devam/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  late final AuthRepository _repository;
  late final StreamSubscription<AuthState> _authStateSubscription;

  User? _user;
  User? get user => _user;

  AuthViewModel() {
    // Repository'yi başlat
    _repository = AuthRepository(Supabase.instance.client);
    // O anki kullanıcıyı al
    _user = _repository.currentUser;
    // Auth durumunu dinlemeye başla
    _authStateSubscription = _repository.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners(); // Kullanıcı durumu değiştiğinde (giriş/çıkış) dinleyicileri uyar
    });
  }

  // ViewModel temizlendiğinde Stream'i kapat (hafıza sızıntısını önlemek için önemli)
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> signIn(String email, String password) async {
    await _repository.signIn(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await _repository.signUp(email, password);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }
}