import 'package:flutter/foundation.dart';
import 'package:suresh_app/services/api_client.dart';
import '../services/api_services.dart';
import '../services/storage_service.dart';

enum AuthRole { user, admin }

class AuthProvider extends ChangeNotifier {
  AuthProvider(ApiClient apiClient, {StorageService? storage}) : _storage = storage;

  bool _isLoading = false;
  String? _errorMessage;  
  Map<String, dynamic>? _authData;
  String? _token;
  AuthRole _selectedRole = AuthRole.user;
  StorageService? _storage;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get authData => _authData;
  String? get token => _token;
  AuthRole get selectedRole => _selectedRole;
  bool get initialized => _initialized;

  void setRole(AuthRole role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final endpoint = _selectedRole == AuthRole.admin
          ? 'api/users/admin-login'
          : 'api/users/login';

      final resp = await ApiService.post(endpoint, {
        'email': email,
        'password': password,
      });

      if (resp is Map<String, dynamic>) {
        _token = resp['token'] as String?;
        final user = resp['user'];
        _authData = user is Map<String, dynamic> ? user : resp;
        
        try {
          (_storage ??= StorageService());
          // Save the complete login response
          await _storage!.saveLoginResponse(resp);
          return true; // Login successful
        } catch (e) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('Failed to persist auth: ' + e.toString());
          }
        }
      } else {
        _authData = null;
        _errorMessage = 'Invalid response from server';
      }
    } catch (e) {
      _authData = null;
      _errorMessage = e.toString();
      if (kDebugMode) {
        // ignore: avoid_print
        print(e);
      }
    } finally {
      _setLoading(false);
    }
    return false; // Login failed
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      (_storage ??= StorageService());
      final existingToken = await _storage!.getToken();
      final userId = await _storage!.getUserId();
      final userType = await _storage!.getUserType();
      final name = await _storage!.getUserName();
      final email = await _storage!.getUserEmail();
      if (existingToken != null && userId != null && userType == 'Admin User') {
        _token = existingToken;
        _authData = {
          'id': userId,
          'userType': userType,
          if (name != null) 'name': name,
          if (email != null) 'email': email,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Auth initialize failed: ' + e.toString());
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await ApiService.post('api/users/logout', {}, token: _token);
      _authData = null;
      _token = null;
      try {
        (_storage ??= StorageService());
        await _storage!.clearAuth();
      } catch (_) {}
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        // ignore: avoid_print
        print(e);
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


