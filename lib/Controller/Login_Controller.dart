import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Model/Login_Request.dart';
import 'package:tickteting_tool/Model/Login_Response.dart';
import 'package:tickteting_tool/Screens/Biomatric_Authentication/auth_provider.dart';
import 'package:tickteting_tool/Service/Api_service.dart';


class AuthController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;


  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(username: username, password: password);
      final result = await _apiService.login(loginRequest);

      print('Login result data: $result');
      print('Result type: ${result.runtimeType}');

      if (result['success'] == true && result['data'] != null) {
        try {
          // Extract the nested data object
          final userData = result['data'] as Map<String, dynamic>;
          _currentUser = LoginResponse.fromJson(userData);
          print('Successfully parsed login response: ${_currentUser?.username}');

          // Store user data in secure storage
          await _storeUserData(_currentUser!);

          // Debug print: check what is saved in secure storage
          String? savedUserId = await _secureStorage.read(key: 'userId');
          print('Saved userId in secure storage: $savedUserId');

          _isLoading = false;
          notifyListeners();
          return true;
        } catch (parseError) {
          print('Error parsing login response: $parseError');
          _errorMessage = "Failed to process login data: $parseError";
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        String message = "Login failed";
        if (result['message'] != null) {
          message = result['message'] as String;
        } else if (result['data'] != null && result['data']['remark'] != null) {
          message = result['data']['remark'] as String;
        }

        _errorMessage = message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _errorMessage = "An error occurred: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Store user data in secure storage
  Future<void> _storeUserData(LoginResponse userData) async {
    print('Storing userId: ${userData.userId}');
    
    try {
      await _secureStorage.write(key: 'userId', value: userData.userId?.toString() ?? "");
      await _secureStorage.write(key: 'username', value: userData.username ?? "");
      await _secureStorage.write(key: 'roleId', value: userData.roleId?.toString() ?? "");
      await _secureStorage.write(key: 'userType', value: userData.userType ?? "");
      await _secureStorage.write(key: 'roleDescription', value: userData.roleDescription ?? "");

      // Store the full user object as JSON for convenience
      final userJson = jsonEncode({
        'userId': userData.userId,
        'username': userData.username,
        'roleId': userData.roleId,
        'userType': userData.userType ?? "",
        'roleDescription': userData.roleDescription ?? "",
        'isPassReset': userData.isPassReset,
      });
      await _secureStorage.write(key: 'userData', value: userJson);
      
      // Verify the data was stored
      final storedUserId = await _secureStorage.read(key: 'userId');
      print('Verified stored userId: $storedUserId');
    } catch (e) {
      print('Error storing user data: $e');
      throw e;
    }
  }

  // Check if user is logged in on app start
  Future<bool> checkLoginStatus() async {
    final userJson = await _secureStorage.read(key: 'userData');
    if (userJson != null) {
      try {
        _currentUser = LoginResponse.fromJson(jsonDecode(userJson));
        notifyListeners();
        return true;
      } catch (e) {
        // Invalid stored data - clear it
        await _secureStorage.deleteAll();
        return false;
      }
    }
    return false;
  }


  Future<void> logout() async {
    await _secureStorage.deleteAll();
    _currentUser = null;
    notifyListeners();
  }

}