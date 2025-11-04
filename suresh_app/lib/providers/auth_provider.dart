import 'package:flutter/foundation.dart';
import 'package:suresh_app/services/api_services.dart';
import '../services/storage_service.dart';
import '../services/endpoints.dart';

enum AuthRole { user, admin }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService? _storage;

  AuthProvider({StorageService? storage}) : _storage = storage;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _authData;
  String? _token;
  AuthRole _selectedRole = AuthRole.user;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get authData => _authData;
  String? get token => _token;
  AuthRole get selectedRole => _selectedRole;
  bool get initialized => _initialized;

  void setRole(AuthRole role) {
    if (_selectedRole != role) {
      _selectedRole = role;
      notifyListeners();
    }
  }

  /// 🔐 Login for Admin or User
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final endpoint = _selectedRole == AuthRole.admin
          ? ApiEndpoints.adminLogin
          : ApiEndpoints.userLogin;

      final response = await _apiService.post(endpoint, {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        // Extract token and user info
        _token = response['token'] ?? response['data']?['token'];
        _authData = response['user'] ?? response['data'] ?? {};

        if (_token != null) {
          final storage = _storage ?? StorageService();
          await storage.saveLoginResponse({
            ...response,
            'role': _selectedRole.name,
          });
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Invalid token received from server';
        }
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('❌ Login error: $e');
    } finally {
      _setLoading(false);
    }

    return false;
  }

  /// 🧠 Initialize from local storage (auto-login)
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final storage = _storage ?? StorageService();
      final existingToken = await storage.getToken();
      final userType = await storage.getUserType();
      final userId = await storage.getUserId();
      final name = await storage.getUserName();
      final email = await storage.getUserEmail();

      if (existingToken != null && userId != null) {
        _token = existingToken;
        _authData = {
          'id': userId,
          'name': name,
          'email': email,
          'userType': userType,
        };
        _selectedRole =
            (userType?.toLowerCase() == 'admin') ? AuthRole.admin : AuthRole.user;
      }
    } catch (e) {
      if (kDebugMode) print('Auth init error: $e');
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiService.post(ApiEndpoints.logout, {}, token: _token);
    } catch (e) {
      if (kDebugMode) print('Logout error: $e');
    } finally {
      _authData = null;
      _token = null;

      try {
        final storage = _storage ?? StorageService();
        await storage.clearAuth();
      } catch (_) {}

      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
