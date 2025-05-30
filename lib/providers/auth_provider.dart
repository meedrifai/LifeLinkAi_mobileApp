import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      setLoading(true);
      setError(null);
      // TODO: Implement your login logic here
      // For example:
      // final response = await authService.login(email, password);
      // _user = User.fromJson(response.data);
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      setLoading(true);
      // TODO: Implement your logout logic here
      _user = null;
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }
} 