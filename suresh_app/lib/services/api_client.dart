import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'endpoints.dart';
import '../model/category.dart';
import '../model/product.dart';
import '../model/customer.dart';
import '../model/gst_master.dart';
import '../model/company_profile.dart';
import '../model/invoice.dart';
import '../model/user.dart';

class ApiClient {
  // Fetch categories by company id using /by-company/:companyid endpoint
  Future<List<Category>> getCategoriesByCompanyId(int companyId) async {
    final data = await get('${ApiEndpoints.categories}/by-company/$companyId');
    final list = _extractList(data);
    return list.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
  }
  final String baseUrl = ApiEndpoints.baseUrl;
  final http.Client _httpClient = http.Client();
  String? _token;

  /// Use a named optional parameter for token to match call sites
  ApiClient({String? token}) : _token = token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Generic API methods
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    // Build URI and attach optional query parameters
    Uri uri = Uri.parse('$baseUrl/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    try {
      if (kDebugMode) {
        print('🌐 GET: $uri');
      }
      
      final response = await _httpClient.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 POST: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      
      final response = await _httpClient.post(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 PATCH: $uri');
        print('📤 Body: ${jsonEncode(data)}');
      }
      
      final response = await _httpClient.patch(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      if (kDebugMode) {
        print('🌐 DELETE: $uri');
      }
      
      final response = await _httpClient.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> uploadFile(String endpoint, File file, String fieldName, {Map<String, dynamic>? data}) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    try {
      var request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      });
      
      // Add file
      String fileName = file.path.split('/').last;
      String mimeType = _getMimeType(fileName);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      // Add other fields if provided
      if (data != null) {
        data.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }
      
      if (kDebugMode) {
        print('🌐 UPLOAD: $uri');
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      return 'image/png';
    } else if (fileName.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }

  dynamic _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String message = 'Unknown error occurred';
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? body['error'] ?? 'Server error';
      } catch (_) {
        message = 'Server error: ${response.statusCode}';
      }
      throw Exception(message);
    }
  }

  void _handleError(dynamic error) {
    if (error is SocketException) {
      throw Exception('Network error. Please check your internet connection.');
    } else if (error is FormatException) {
      throw Exception('Invalid response format from server.');
    } else if (error is Exception) {
      throw error;
    } else {
      throw Exception('An unexpected error occurred: ${error.toString()}');
    }
  }

  // Helper method to extract list from response
  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    } else if (data is Map<String, dynamic>) {
      // Try common wrapper keys
      return (data['data'] ?? data['items'] ?? data['results'] ?? []) as List;
    }
    throw Exception('Unexpected response format: ${data.runtimeType}');
  }

  // Helper method to extract single item from response
  Map<String, dynamic> _extractItem(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Check if data is wrapped
      if (data.containsKey('data') && data['data'] is Map) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    }
    throw Exception('Unexpected response format: ${data.runtimeType}');
  }

  // Categories API
  Future<List<Category>> getCategories({int? companyId, int? userId}) async {
    final queryParams = <String, String>{
      if (companyId != null) 'companyId': companyId.toString(),
      if (userId != null) 'userId': userId.toString(),
    };
    final data = await get(ApiEndpoints.categories, queryParams: queryParams.isEmpty ? null : queryParams);
    final list = _extractList(data);
    return list.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Category> getCategoryById(int id) async {
    final data = await get('${ApiEndpoints.categories}/$id');
    final item = _extractItem(data);
    return Category.fromJson(item);
  }

  Future<Category> getCategoryByCompanyID(int id) async {
    final data = await get('${ApiEndpoints.categories}/by-company/$id');
    final item = _extractItem(data);
    return Category.fromJson(item);
  }

  Future<Category> createCategory(Category category) async {
    final data = await post(ApiEndpoints.categories, category.toJson());
    final item = _extractItem(data);
    return Category.fromJson(item);
  }

  // Create category and optionally attach companyId into payload
  Future<Category> createCategoryWithCompany(Category category, {int? companyId}) async {
  final payload = Map<String, dynamic>.from(category.toJson());
  if (companyId != null) payload['company_id'] = companyId;
  final data = await post(ApiEndpoints.categories, payload);
  final item = _extractItem(data);
  return Category.fromJson(item);
  }

  Future<Category> updateCategory(int id, Category category) async {
    final data = await patch('${ApiEndpoints.categories}/$id', category.toJson());
    final item = _extractItem(data);
    return Category.fromJson(item);
  }

  Future<void> deleteCategory(int id) async {
    await delete('${ApiEndpoints.categories}/$id');
  }

  // Products API
  Future<List<Product>> getProducts({int? companyId, int? userId}) async {
    final queryParams = <String, String>{
      if (companyId != null) 'companyId': companyId.toString(),
      if (userId != null) 'userId': userId.toString(),
    };
    final data = await get(ApiEndpoints.products, queryParams: queryParams.isEmpty ? null : queryParams);
    final list = _extractList(data);
    return list.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Product> getProductById(int id) async {
    final data = await get('${ApiEndpoints.products}/$id');
    final item = _extractItem(data);
    return Product.fromJson(item);
  }

  Future<Product> createProduct(Product product) async {
    final data = await post(ApiEndpoints.products, product.toJson());
    final item = _extractItem(data);
    return Product.fromJson(item);
  }

  // Create product and optionally attach companyId into payload
  Future<Product> createProductWithCompany(Product product, {int? companyId}) async {
    final payload = Map<String, dynamic>.from(product.toJson());
    if (companyId != null) payload['company_id'] = companyId;
    final data = await post(ApiEndpoints.products, payload);
    final item = _extractItem(data);
    return Product.fromJson(item);
  }

  Future<Product> updateProduct(int id, Product product) async {
    final data = await patch('${ApiEndpoints.products}/$id', product.toJson());
    final item = _extractItem(data);
    return Product.fromJson(item);
  }

  Future<void> deleteProduct(int id) async {
    await delete('${ApiEndpoints.products}/$id');
  }

  // Customers API
  Future<List<Customer>> getCustomers({int? companyId, int? userId}) async {
    final queryParams = <String, String>{
      if (companyId != null) 'companyId': companyId.toString(),
      if (userId != null) 'userId': userId.toString(),
    };
    final data = await get(ApiEndpoints.customers, queryParams: queryParams.isEmpty ? null : queryParams);
    final list = _extractList(data);
    return list.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Customer>> getCustomersByCompanyId(int companyId) async {
    if (kDebugMode) {
      print('\n🌐 GET Customers Request:');
      print('URL: ${ApiEndpoints.customers}/company/$companyId');
      print('Headers: $_headers\n');
    }
    final data = await get('${ApiEndpoints.customers}/company/$companyId');
    if (kDebugMode) {
      print('\n📥 GET Customers Response:');
      print('Raw response: $data\n');
    }
    final list = _extractList(data);
    return list.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Customer> getCustomerById(int id) async {
    final data = await get('${ApiEndpoints.customers}/$id');
    final item = _extractItem(data);
    return Customer.fromJson(item);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final data = await post(ApiEndpoints.customers, customer.toJson());
    final item = _extractItem(data);
    return Customer.fromJson(item);
  }

  // Create customer and optionally attach companyId into payload
  Future<Customer> createCustomerWithCompany(Customer customer, {int? companyId}) async {
    final payload = Map<String, dynamic>.from(customer.toJson());
    if (companyId != null) payload['company_id'] = companyId;
    if (kDebugMode) {
      print('\n🌐 POST Customer Request:');
      print('URL: ${ApiEndpoints.customers}');
      print('Headers: $_headers');
      print('Payload: ${jsonEncode(payload)}\n');
    }
    final data = await post(ApiEndpoints.customers, payload);
    if (kDebugMode) {
      print('\n📥 POST Customer Response:');
      print('Raw response: $data\n');
    }
    final item = _extractItem(data);
    return Customer.fromJson(item);
  }

  Future<Customer> updateCustomer(int id, Customer customer) async {
    final data = await patch('${ApiEndpoints.customers}/$id', customer.toJson());
    final item = _extractItem(data);
    return Customer.fromJson(item);
  }

  Future<void> deleteCustomer(int id) async {
    await delete('${ApiEndpoints.customers}/$id');
  }

  // GST Masters API
  Future<List<GstMaster>> getGstMasters() async {
    final data = await get(ApiEndpoints.gstMasters);
    final list = _extractList(data);
    return list.map((item) => GstMaster.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<GstMaster> getGstMasterById(int id) async {
    final data = await get('${ApiEndpoints.gstMasters}/$id');
    final item = _extractItem(data);
    return GstMaster.fromJson(item);
  }

  Future<GstMaster> createGstMaster(GstMaster gstMaster) async {
    final data = await post(ApiEndpoints.gstMasters, gstMaster.toJson());
    final item = _extractItem(data);
    return GstMaster.fromJson(item);
  }

  Future<GstMaster> updateGstMaster(int id, GstMaster gstMaster) async {
    final data = await patch('${ApiEndpoints.gstMasters}/$id', gstMaster.toJson());
    final item = _extractItem(data);
    return GstMaster.fromJson(item);
  }

  Future<void> deleteGstMaster(int id) async {
    await delete('${ApiEndpoints.gstMasters}/$id');
  }

  // Company Profiles API
  Future<List<CompanyProfile>> getCompanyProfiles() async {
    final data = await get(ApiEndpoints.companyProfiles);
    final list = _extractList(data);
    return list.map((item) => CompanyProfile.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<CompanyProfile> getCompanyProfileById(int id) async {
    final data = await get('${ApiEndpoints.companyProfiles}/$id');
    final item = _extractItem(data);
    return CompanyProfile.fromJson(item);
  }

  Future<CompanyProfile> createCompanyProfile(CompanyProfile profile, File? logoFile) async {
    if (logoFile != null) {
      final data = await uploadFile(
        ApiEndpoints.companyProfiles,
        logoFile,
        'companyLogo',
        data: profile.toJson(),
      );
      final item = _extractItem(data);
      return CompanyProfile.fromJson(item);
    } else {
      final data = await post(ApiEndpoints.companyProfiles, profile.toJson());
      final item = _extractItem(data);
      return CompanyProfile.fromJson(item);
    }
  }

  Future<CompanyProfile> updateCompanyProfile(int id, CompanyProfile profile, File? logoFile) async {
    if (logoFile != null) {
      final data = await uploadFile(
        '${ApiEndpoints.companyProfiles}/$id',
        logoFile,
        'companyLogo',
        data: profile.toJson(),
      );
      final item = _extractItem(data);
      return CompanyProfile.fromJson(item);
    } else {
      final data = await patch('${ApiEndpoints.companyProfiles}/$id', profile.toJson());
      final item = _extractItem(data);
      return CompanyProfile.fromJson(item);
    }
  }

  Future<void> deleteCompanyProfile(int id) async {
    await delete('${ApiEndpoints.companyProfiles}/$id');
  }

  // Invoices API
  Future<List<Invoice>> getInvoices() async {
    final data = await get(ApiEndpoints.invoices);
    final list = _extractList(data);
    return list.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Invoice>> getInvoicesByCompany(String companyId) async {
    final data = await get(ApiEndpoints.invoicesByCompany(companyId));
    final list = _extractList(data);
    return list.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Invoice>> getInvoicesByUser(String userId) async {
    final data = await get(ApiEndpoints.invoicesByUser(userId));
    final list = _extractList(data);
    return list.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Invoice> getInvoiceById(int id) async {
    final data = await get('${ApiEndpoints.invoices}/$id');
    final item = _extractItem(data);
    return Invoice.fromJson(item);
  }

  Future<Invoice> createInvoice(Invoice invoice) async {
    final data = await post(ApiEndpoints.invoices, invoice.toJson());
    final item = _extractItem(data);
    return Invoice.fromJson(item);
  }

  Future<Invoice> updateInvoice(int id, Invoice invoice) async {
    final data = await patch('${ApiEndpoints.invoices}/$id', invoice.toJson());
    final item = _extractItem(data);
    return Invoice.fromJson(item);
  }

  Future<void> deleteInvoice(int id) async {
    await delete('${ApiEndpoints.invoices}/$id');
  }

  // Users API
  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final data = await post(ApiEndpoints.adminLogin, {
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> userLogin(String email, String password) async {
    final data = await post(ApiEndpoints.userLogin, {
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await post(ApiEndpoints.logout, {});
  }

  Future<List<User>> getUsers() async {
    final data = await get(ApiEndpoints.users);
    final list = _extractList(data);
    return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<User> getUserById(int id) async {
    final data = await get('${ApiEndpoints.users}/$id');
    final item = _extractItem(data);
    return User.fromJson(item);
  }

  Future<User> createUser(User user) async {
    final data = await post(ApiEndpoints.users, user.toJson());
    final item = _extractItem(data);
    return User.fromJson(item);
  }

  Future<User> updateUser(int id, User user) async {
    final data = await patch('${ApiEndpoints.users}/$id', user.toJson());
    final item = _extractItem(data);
    return User.fromJson(item);
  }

  Future<void> deleteUser(int id) async {
    await delete('${ApiEndpoints.users}/$id');
  }
}