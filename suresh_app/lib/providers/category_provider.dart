import 'package:flutter/foundation.dart' hide Category;
import '../model/category.dart' as model;
import '../services/api_client.dart';
import '../services/storage_service.dart';
import 'dart:async';

// Use model.Category instead of Category to avoid conflicts

class CategoryProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  List<model.Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  CategoryProvider(this._apiClient);

  List<model.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories({int? companyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (companyId == null) {
        companyId = await _storage.getCompanyId();
      }
      final categories = await _apiClient.getCategoriesByCompanyId(companyId!);
      _categories = categories;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<model.Category?> createCategory(model.Category category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int? companyId = await _storage.getCompanyId();
      final newCategory = await _apiClient.createCategoryWithCompany(category, companyId: companyId);
      _categories.add(newCategory);
      _isLoading = false;
      notifyListeners();
      return newCategory;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<model.Category?> updateCategory(int id, model.Category category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCategory = await _apiClient.updateCategory(id, category);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _isLoading = false;
      notifyListeners();
      return updatedCategory;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
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