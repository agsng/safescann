import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    // Add your actual authentication logic here
    // For now, we'll just simulate successful login
    _isLoggedIn = true;
    notifyListeners(); // This will rebuild the Consumer in main.dart
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}