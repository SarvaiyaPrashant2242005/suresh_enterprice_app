import 'package:flutter/foundation.dart';
import '../model/product.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductProvider(this._apiClient);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts({int? companyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (companyId == null) {
        companyId = await _storage.getCompanyId();
      }
      final all = await _apiClient.getProducts(companyId: companyId);
      // server may filter; if not, apply client-side fallback
      if (companyId != null) {
        _products = all.where((p) => p.companyId == companyId).toList();
      } else {
        _products = all;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Product?> createProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int? companyId = product.companyId;
      if (companyId == null) {
        companyId = await _storage.getCompanyId();
      }
      final newProduct = await _apiClient.createProductWithCompany(product, companyId: companyId);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return newProduct;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Product?> updateProduct(int id, Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = await _apiClient.updateProduct(id, product);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isLoading = false;
      notifyListeners();
      return updatedProduct;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}