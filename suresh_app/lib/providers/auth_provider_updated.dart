import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../model/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final StorageService _storage = StorageService();
  
  bool _isLoading = false;
  String _error = '';
  Map<String, dynamic>? _authData;
  String? _token;
  String? _selectedRole;

  AuthProvider(this._apiClient, this._prefs) {
    _initialize();
  }

  bool get isLoading => _isLoading;
  String get error => _error;
  /// Backwards-compatible getter used across the app
  String? get errorMessage => _error.isEmpty ? null : _error;
  Map<String, dynamic>? get authData => _authData;
  String? get token => _token;
  String? get selectedRole => _selectedRole;
  bool get isAuthenticated => _token != null;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> _initialize() async {
    _token = _prefs.getString('auth_token');
    if (_token != null) {
      _apiClient.setToken(_token!);
      // Load user data from preferences
      final userDataStr = _prefs.getString('auth_user_data');
      if (userDataStr != null) {
        try {
          final userMap = Map<String, dynamic>.from(jsonDecode(userDataStr));
          _authData = userMap;
        } catch (e) {
          if (kDebugMode) {
            print('Error loading user data: $e');
          }
        }
      }
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiClient.userLogin(email, password);

      // Save login response
      await _storage.saveLoginResponse(response);

      // Update state
      final user = response['user'] as Map<String, dynamic>?;
      if (user != null) {
        _authData = user;
        // Print userType in debug console
        final userType = user['userType'];
        if (kDebugMode) {
          print('🔐 Login successful - UserType: $userType');
        }
      } else {
        _authData = null;
      }
      _token = response['token'];
      _apiClient.setToken(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.logout();
    } catch (e) {
      // Even if API logout fails, we still clear local data
      if (kDebugMode) {
        print('Logout API error: $e');
      }
    }

    // Clear stored auth data
    await _storage.clearAuth();

    // Reset state
    _authData = null;
    _token = null;
    _error = '';

    _isLoading = false;
    notifyListeners();
  }
}