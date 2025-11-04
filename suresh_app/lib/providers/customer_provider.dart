import 'package:flutter/material.dart';
import '../model/customer.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import 'base_provider.dart';

class CustomerProvider extends BaseProvider {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  List<Customer> _customers = [];

  CustomerProvider(this._apiClient);

  List<Customer> get customers => _customers;

  Future<void> fetchCustomers({int? companyId}) async {
    setLoading(true);
    clearError();
    try {
      // If caller didn't provide companyId, try to read from storage
      if (companyId == null) {
        companyId = await _storage.getCompanyId();
      }
      print('Fetching customers for companyId: $companyId');
      if (companyId != null) {
        final response = await _apiClient.getCustomersByCompanyId(companyId);
        _customers = response;
      } else {
        _customers = [];
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    setLoading(true);
    clearError();
    
    try {
      final int? companyId = await _storage.getCompanyId();
      final newCustomer = await _apiClient.createCustomerWithCompany(customer, companyId: companyId);
      _customers.add(newCustomer);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCustomer(int id, Customer customer) async {
    setLoading(true);
    clearError();
    
    try {
      final updatedCustomer = await _apiClient.updateCustomer(id, customer);
      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteCustomer(String id) async {
    setLoading(true);
    clearError();
    
    try {
      // Convert String id to int
      final int customerId = int.parse(id);
      await _apiClient.deleteCustomer(customerId);
      _customers.removeWhere((c) => c.id == customerId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}