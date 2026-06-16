import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.register(name: name, email: email, password: password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
