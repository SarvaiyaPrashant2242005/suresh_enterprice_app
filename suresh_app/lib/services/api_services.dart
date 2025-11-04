import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class ApiService {
  final String baseUrl = ApiEndpoints.baseUrl;

  Map<String, String> defaultHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) print('🌐 GET: $uri');
      final response = await http
          .get(uri, headers: defaultHeaders(token: token))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('⏰ Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception('🌐 Network error: ${e.message}');
    } catch (e) {
      throw Exception('⚠️ Error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 POST: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      final response = await http
          .post(uri,
              headers: defaultHeaders(token: token), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('⏰ Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception('🌐 Network error: ${e.message}');
    } catch (e) {
      throw Exception('⚠️ Error: ${e.toString()}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 PUT: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      final response = await http
          .put(uri,
              headers: defaultHeaders(token: token), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('⏰ Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception('🌐 Network error: ${e.message}');
    } catch (e) {
      throw Exception('⚠️ Error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) print('🌐 DELETE: $uri');
      final response = await http
          .delete(uri, headers: defaultHeaders(token: token))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('⏰ Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception('🌐 Network error: ${e.message}');
    } catch (e) {
      throw Exception('⚠️ Error: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📊 Status: ${response.statusCode}');
      print('📋 Content-Type: ${response.headers['content-type']}');
      print('📦 Body Length: ${response.body.length}');
      try {
        final preview = response.body.length > 500
            ? response.body.substring(0, 500)
            : response.body;
        print('📥 Body: $preview');
      } catch (_) {
        print('⚠️ Could not preview body');
      }
    }

    if (response.body.isEmpty) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': {}};
      }
      throw Exception('Empty response from server');
    }

    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');
    dynamic parsed;

    if (isJson ||
        response.body.trim().startsWith('{') ||
        response.body.trim().startsWith('[')) {
      try {
        parsed = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response: $e');
      }
    } else {
      parsed = response.body;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return parsed is Map
          ? {'success': true, ...parsed}
          : {'success': true, 'data': parsed};
    }

    final message = parsed is Map
        ? (parsed['message'] ?? parsed['error'] ?? 'Unknown error')
        : 'Request failed (${response.statusCode})';
    throw Exception(message);
  }
}
