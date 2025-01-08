import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get token => _token;

  Future<void> setAuthenticationStatus(bool status, {String? token, String? userId}) async {
    _isAuthenticated = status;
    _token = token;
    _userId = userId;

    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    }

    notifyListeners();
  }

  void setToken(String? token) {
    setAuthenticationStatus(token != null, token: token);
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _userId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }
} 