import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserType = 'auth_user_type';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyCompanyId = 'auth_company_id';

  Future<void> saveAuth({
    required String token, 
    required int userId, 
    String? userType, 
    String? name, 
    String? email,
    int? companyId,
    Map<String, dynamic>? userData
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, userId);
    if (userType != null) await prefs.setString(_keyUserType, userType);
    if (name != null) await prefs.setString(_keyUserName, name);
    if (email != null) await prefs.setString(_keyUserEmail, email);
    if (companyId != null) await prefs.setInt(_keyCompanyId, companyId);
    if (userData != null) await prefs.setString(_keyUserData, jsonEncode(userData));
  }
  
  Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_response', jsonEncode(response));
    
    final token = response['token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;
    
    if (token != null) await prefs.setString(_keyToken, token);
    if (user != null) {
      final userId = (user['id'] as num?)?.toInt();
      if (userId != null) await prefs.setInt(_keyUserId, userId);
      if (user['name'] != null) await prefs.setString(_keyUserName, user['name']);
      if (user['email'] != null) await prefs.setString(_keyUserEmail, user['email']);
      if (user['userType'] != null) await prefs.setString(_keyUserType, user['userType']);
      if (user['company_id'] != null) await prefs.setInt(_keyCompanyId, (user['company_id'] as num).toInt());
      await prefs.setString(_keyUserData, jsonEncode(user));
    }
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserType);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }
}


