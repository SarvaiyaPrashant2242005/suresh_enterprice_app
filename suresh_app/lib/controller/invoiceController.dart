import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suresh_app/providers/auth_provider.dart';
import '../services/api_client.dart';
import '../model/invoice.dart';

class InvoiceController {
  final ApiClient _apiClient;

  InvoiceController(this._apiClient);

  // ✅ Get user data (companyId, userId, userType)
  Future<Map<String, dynamic>> getUserData(BuildContext context) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final authData = auth.authData;

      int? companyId;
      int? userId;
      String? userType;

      // Step 1: Try to get from AuthProvider
      if (authData != null) {
        final dynamic c = authData['company_id'] ??
            authData['companyId'] ??
            (authData['user'] is Map
                ? (authData['user']['company_id'] ??
                    authData['user']['companyId'])
                : null);
        if (c is num) companyId = c.toInt();
        if (c is String) companyId = int.tryParse(c);

        final dynamic u = authData['id'] ??
            (authData['user'] is Map ? authData['user']['id'] : null);
        if (u is num) userId = u.toInt();
        if (u is String) userId = int.tryParse(u);

        userType = authData['userType'] ??
            (authData['user'] is Map ? authData['user']['userType'] : null);
      }

      // Step 2: Fallback to SharedPreferences if missing
      if (companyId == null || userId == null || userType == null) {
        final prefs = await SharedPreferences.getInstance();
        companyId ??= prefs.getInt('company_id');
        userId ??= prefs.getInt('user_id');
        userType ??= prefs.getString('user_type');
      }

      // Step 3: Return result
      return {
        'companyId': companyId,
        'userId': userId,
        'userType': userType,
      };
    } catch (e) {
      debugPrint("Error getting user data: $e");
      return {
        'companyId': null,
        'userId': null,
        'userType': null,
      };
    }
  }

  // ✅ Fetch invoices based on user type
  Future<List<Invoice>> fetchInvoices(BuildContext context, userType) async {
    try {
      final userData = await getUserData(context);
      final userType = userData['userType'];
      final userId = userData['userId'];
      final companyId = userData['companyId'];

      if (userType == 'Admin') {
        // Admin sees all invoices
        return await _apiClient.getInvoices();
      } else {
        // Regular user sees company or user-specific invoices
        if (companyId != null) {
          return await _apiClient.getInvoicesByCompany(companyId.toString());
        } else if (userId != null) {
          return await _apiClient.getInvoicesByUser(userId.toString());
        } else {
          throw Exception('No company or user ID found');
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  // ✅ Get single invoice by ID
  Future<Invoice> getInvoiceById(int id) async {
    try {
      return await _apiClient.getInvoiceById(id);
    } catch (e) {
      throw Exception('Failed to fetch invoice: $e');
    }
  }

  // ✅ Create new invoice
  Future<Invoice> createInvoice(
      BuildContext context, Map<String, dynamic> invoiceData, userType) async {
    try {
      final userData = await getUserData(context);
      final userId = userData['userId'];

      // Add user_id to invoice data
      if (userId != null) {
        invoiceData['user_id'] = userId;
      }

      // Convert to Invoice object
      final invoice = Invoice.fromJson(invoiceData);
      return await _apiClient.createInvoice(invoice);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }

  // ✅ Update existing invoice
  Future<Invoice> updateInvoice(int id, Map<String, dynamic> invoiceData) async {
    try {
      final invoice = Invoice.fromJson(invoiceData);
      return await _apiClient.updateInvoice(id, invoice);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  // ✅ Delete invoice
  Future<void> deleteInvoice(int id) async {
    try {
      await _apiClient.deleteInvoice(id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  // ✅ Download invoice PDF
  Future<void> downloadInvoicePDF(int id, {String copyType = 'Original'}) async {
    try {
      final baseUrl = _apiClient.baseUrl;
      final url = '$baseUrl/api/invoices/$id/pdf?copyType=$copyType';
      // Use url_launcher or dio for actual download
      throw UnimplementedError(
          'PDF download needs to be implemented with url_launcher or dio');
    } catch (e) {
      throw Exception('Failed to download invoice PDF: $e');
    }
  }

  // ✅ Calculate totals
  Map<String, double> calculateInvoiceTotals(
      List<Map<String, dynamic>> items) {
    double totalAssesValue = 0;

    for (var item in items) {
      final quantity = (item['quantity'] ?? 1).toDouble();
      final rate = (item['rate'] ?? 0).toDouble();
      totalAssesValue += quantity * rate;
    }

    return {
      'totalAssesValue': totalAssesValue,
    };
  }

  // ✅ Validate invoice data
  String? validateInvoiceData(Map<String, dynamic> data) {
    if (data['customerId'] == null) {
      return 'Customer is required';
    }
    if (data['companyProfileId'] == null) {
      return 'Company profile is required';
    }
    if (data['billDate'] == null || data['billDate'].toString().isEmpty) {
      return 'Bill date is required';
    }
    if (data['items'] == null || (data['items'] as List).isEmpty) {
      return 'At least one item is required';
    }

    final items = data['items'] as List;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item['productId'] == null) {
        return 'Product is required for item ${i + 1}';
      }
      if (item['uom'] == null || item['uom'].toString().isEmpty) {
        return 'UOM is required for item ${i + 1}';
      }
      if (item['rate'] == null ||
          double.tryParse(item['rate'].toString()) == null ||
          double.parse(item['rate'].toString()) <= 0) {
        return 'Valid rate is required for item ${i + 1}';
      }
    }

    return null;
  }
}
