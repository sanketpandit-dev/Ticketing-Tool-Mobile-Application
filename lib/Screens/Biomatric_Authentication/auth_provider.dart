import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final storage = const FlutterSecureStorage();

  String? _token;

  String? get token => _token;

  Future<void> loadToken() async {
    _token = await storage.read(key: 'authToken');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await storage.delete(key: 'authToken');
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await storage.write(key: 'authToken', value: token);
    notifyListeners();
  }
}
