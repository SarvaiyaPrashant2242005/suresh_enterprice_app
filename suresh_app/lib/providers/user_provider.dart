import 'package:flutter/material.dart';
import 'package:suresh_app/services/api_services.dart';
import '../model/user.dart';
import '../services/endpoints.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all users
  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.users);

      if (response['success'] == true) {
        final List<dynamic> usersData =
            response['data'] ?? response['users'] ?? [];
        _users = usersData.map((json) => User.fromJson(json)).toList();
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch users';
        _users = [];
      }
    } catch (error) {
      _errorMessage = error.toString();
      _users = [];
      debugPrint('❌ Error fetching users: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new user
  Future<bool> addUser(User user, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = user.toJson()..['password'] = password;
      final response = await _apiService.post(ApiEndpoints.users, userData);

      if (response['success'] == true) {
        final newUser = User.fromJson(response['data'] ?? response['user']);
        _users.add(newUser);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to add user';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      debugPrint('❌ Error adding user: $error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Update user
  Future<bool> updateUser(String userId, User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _apiService.put('${ApiEndpoints.users}/$userId', user.toJson());

      if (response['success'] == true) {
        final index = _users.indexWhere((u) => u.id.toString() == userId);
        if (index != -1) {
          _users[index] = User.fromJson(response['data'] ?? response['user']);
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to update user';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      debugPrint('❌ Error updating user: $error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await _apiService.delete('${ApiEndpoints.users}/$userId');

      if (response['success'] == true) {
        _users.removeWhere((u) => u.id.toString() == userId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to delete user';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      debugPrint('❌ Error deleting user: $error');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Clear all data
  void clear() {
    _users.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
