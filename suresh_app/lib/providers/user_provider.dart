import 'package:flutter/material.dart';
import '../model/user.dart';
import '../services/api_service.dart';

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
      final response = await _apiService.get('/users');
      
      if (response['success'] == true) {
        final List<dynamic> usersData = response['data'] ?? response['users'] ?? [];
        _users = usersData.map((json) => User.fromJson(json)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch users';
        _users = [];
      }
    } catch (error) {
      _errorMessage = error.toString();
      _users = [];
      debugPrint('Error fetching users: $error');
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
      final userData = user.toJson();
      userData['password'] = password;
      
      final response = await _apiService.post('/users', userData);
      
      if (response['success'] == true) {
        final newUser = User.fromJson(response['data'] ?? response['user']);
        _users.add(newUser);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to add user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding user: $error');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(String userId, User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put('/users/$userId', user.toJson());
      
      if (response['success'] == true) {
        final index = _users.indexWhere((u) => u.id.toString() == userId);
        if (index != -1) {
          _users[index] = User.fromJson(response['data'] ?? response['user']);
        }
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to update user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating user: $error');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete('/users/$userId');
      
      if (response['success'] == true) {
        _users.removeWhere((u) => u.id.toString() == userId);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to delete user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting user: $error');
      return false;
    }
  }

  // Clear all data
  void clear() {
    _users = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}