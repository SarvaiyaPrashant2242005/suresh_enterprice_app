import 'package:flutter/foundation.dart';

class BaseProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Backwards-compatible getter expected by screens/providers
  String? get error => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error convenience method used by several providers
  void clearError() {
    setError(null);
  }

  Future<T?> handleApiCall<T>(Future<T> Function() apiCall) async {
    setLoading(true);
    setError(null);

    try {
      final result = await apiCall();
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return null;
    }
  }
}