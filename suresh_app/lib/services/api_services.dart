import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class ApiService {
  static const String baseUrl = ApiEndpoints.baseUrl;

  static Map<String, String> defaultHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 GET: $uri');
      }
      
      final response = await http
          .get(
            uri,
            headers: defaultHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception(
        'Network error: ${e.message}. Is the server reachable at $baseUrl?',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Connection failed: ${e.message}. Please check:\n'
        '1. Your internet connection\n'
        '2. If the server is running\n'
        '3. Firewall/VPN settings',
      );
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 POST: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      
      final response = await http
          .post(
            uri,
            headers: defaultHeaders(token: token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception(
        'Network error: ${e.message}. Is the server reachable at $baseUrl?',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Connection failed: ${e.message}. Please check:\n'
        '1. Your internet connection\n'
        '2. If the server is running\n'
        '3. Firewall/VPN settings',
      );
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 PUT: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      
      final response = await http
          .put(
            uri,
            headers: defaultHeaders(token: token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception(
        'Network error: ${e.message}. Is the server reachable at $baseUrl?',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Connection failed: ${e.message}. Please check:\n'
        '1. Your internet connection\n'
        '2. If the server is running\n'
        '3. Firewall/VPN settings',
      );
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 DELETE: $uri');
      }
      
      final response = await http
          .delete(
            uri,
            headers: defaultHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network/server.');
    } on SocketException catch (e) {
      throw Exception(
        'Network error: ${e.message}. Is the server reachable at $baseUrl?',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Connection failed: ${e.message}. Please check:\n'
        '1. Your internet connection\n'
        '2. If the server is running\n'
        '3. Firewall/VPN settings',
      );
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📊 Status: ${response.statusCode}');
      print('📋 Content-Type: ${response.headers['content-type']}');
      print('📦 Body Length: ${response.body.length}');
      print('📥 Raw Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    }

    // Check if response is empty
    if (response.body.isEmpty) {
      if (kDebugMode) {
        print('⚠️ Empty response body');
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {};
      }
      
      throw Exception('Empty response from server (Status: ${response.statusCode})');
    }

    // Check content type
    final contentType = response.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json');

    if (kDebugMode) {
      print('🔍 Is JSON: $isJson');
    }

    // If not JSON, check if it's HTML (error page)
    if (!isJson && response.body.trim().startsWith('<')) {
      if (kDebugMode) {
        print('❌ Server returned HTML instead of JSON');
      }
      throw Exception('Server error: Received HTML instead of JSON (Status: ${response.statusCode})');
    }

    // Try to parse JSON
    dynamic parsed;
    if (isJson || response.body.trim().startsWith('{') || response.body.trim().startsWith('[')) {
      try {
        parsed = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ JSON parsed successfully');
        }
      } on FormatException catch (e) {
        if (kDebugMode) {
          print('❌ JSON parsing failed: $e');
          print('Problematic content: ${response.body}');
        }
        throw Exception('Invalid JSON response from server');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Response is not JSON');
      }
      parsed = response.body;
    }

    // Handle success responses
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print('✅ Success response');
      }
      return parsed is Map || parsed is List ? parsed : {'data': parsed};
    }

    // Handle error responses
    if (kDebugMode) {
      print('❌ Error response: ${response.statusCode}');
    }

    String message;
    if (parsed is Map) {
      message = parsed['message']?.toString() ?? 
                parsed['error']?.toString() ?? 
                'Request failed with status: ${response.statusCode}';
    } else {
      message = 'Request failed with status: ${response.statusCode}';
    }

    throw Exception(message);
  }

  static dynamic _tryParseJson(String text) {
    try {
      return jsonDecode(text);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ JSON parse attempt failed: $e');
      }
      return text;
    }
  }
}