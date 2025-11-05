import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suresh_app/controller/invoiceController.dart';
import 'package:suresh_app/providers/auth_provider.dart';
import '../model/invoice.dart';

class InvoiceProvider with ChangeNotifier {
  final InvoiceController _controller;

  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _error;
  Invoice? _selectedInvoice;

  InvoiceProvider(this._controller);

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Invoice? get selectedInvoice => _selectedInvoice;

  // 🔹 Fetch all invoices based on user type
  Future<void> fetchInvoices(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await getUserData(context);
      final companyId = userData['companyId'];
      final userType = userData['userType'];

      _invoices = await _controller.fetchInvoices(companyId, userType);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _invoices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Get single invoice by ID
  Future<void> fetchInvoiceById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedInvoice = await _controller.getInvoiceById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedInvoice = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Create new invoice
  Future<bool> createInvoice(BuildContext context, Map<String, dynamic> invoiceData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await getUserData(context);
      final companyId = userData['companyId'];
      final userType = userData['userType'];

      // ✅ Validate data
      final validationError = _controller.validateInvoiceData(invoiceData);
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final newInvoice = await _controller.createInvoice(invoiceData as BuildContext, companyId, userType);
      _invoices.insert(0, newInvoice);

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔹 Update existing invoice
  Future<bool> updateInvoice(int id, Map<String, dynamic> invoiceData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final validationError = _controller.validateInvoiceData(invoiceData);
      if (validationError != null) {
        _error = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedInvoice = await _controller.updateInvoice(id, invoiceData);

      // ✅ Update in list
      final index = _invoices.indexWhere((inv) => inv.id == id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
      }

      // ✅ Update selected invoice if it's the same
      if (_selectedInvoice?.id == id) {
        _selectedInvoice = updatedInvoice;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔹 Delete invoice
  Future<bool> deleteInvoice(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _controller.deleteInvoice(id);
      _invoices.removeWhere((inv) => inv.id == id);

      if (_selectedInvoice?.id == id) {
        _selectedInvoice = null;
      }

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🔹 Download invoice PDF
  Future<void> downloadInvoicePDF(int id, {String copyType = 'Original'}) async {
    try {
      await _controller.downloadInvoicePDF(id, copyType: copyType);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 🔹 Clear selected invoice
  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }

  // 🔹 Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 🔹 Calculate totals
  Map<String, double> calculateTotals(List<Map<String, dynamic>> items) {
    return _controller.calculateInvoiceTotals(items);
  }

  // 🔹 Search invoices
  List<Invoice> searchInvoices(String query) {
    if (query.isEmpty) return _invoices;

    final lowerQuery = query.toLowerCase();
    return _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
          invoice.billNumber.toLowerCase().contains(lowerQuery) ||
          invoice.customer?.customerName.toLowerCase().contains(lowerQuery) == true ||
          invoice.companyProfile?.companyName.toLowerCase().contains(lowerQuery) == true;
    }).toList();
  }

  // 🔹 Filter by date range
  List<Invoice> filterByDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return _invoices;

    return _invoices.where((invoice) {
      final billDate = DateTime.tryParse(invoice.billDate);
      if (billDate == null) return false;

      if (start != null && billDate.isBefore(start)) return false;
      if (end != null && billDate.isAfter(end)) return false;

      return true;
    }).toList();
  }

  // 🔹 Get user details (from AuthProvider or SharedPreferences)
  Future<Map<String, dynamic>> getUserData(BuildContext context) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final authData = auth.authData;

      int? companyId;
      int? userId;
      String? userType;

      // Try AuthProvider first
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

      // Fallback to SharedPreferences
      if (companyId == null || userId == null || userType == null) {
        final prefs = await SharedPreferences.getInstance();
        companyId ??= prefs.getInt('company_id');
        userId ??= prefs.getInt('user_id');
        userType ??= prefs.getString('user_type');
      }

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
}
