import 'package:flutter/material.dart';
import '../model/gst_master.dart';
import '../services/api_client.dart';
import 'base_provider.dart';

class GstMasterProvider extends BaseProvider {
  final ApiClient _apiClient;
  List<GstMaster> _gstMasters = [];

  GstMasterProvider(this._apiClient);

  List<GstMaster> get gstMasters => _gstMasters;

  Future<void> fetchGstMasters() async {
    setLoading(true);
    clearError();
    
    try {
      final response = await _apiClient.getGstMasters();
      _gstMasters = response;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> addGstMaster(GstMaster gstMaster) async {
    setLoading(true);
    clearError();
    
    try {
      final newGstMaster = await _apiClient.createGstMaster(gstMaster);
      _gstMasters.add(newGstMaster);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateGstMaster(int id, GstMaster gstMaster) async {
    setLoading(true);
    clearError();

    try {
      final updatedGstMaster = await _apiClient.updateGstMaster(id, gstMaster);
      final index = _gstMasters.indexWhere((g) => g.id == id);
      if (index != -1) {
        _gstMasters[index] = updatedGstMaster;
        notifyListeners();
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteGstMaster(String id) async {
    setLoading(true);
    clearError();
    
    try {
      // Convert String id to int
      final int gstId = int.parse(id);
      await _apiClient.deleteGstMaster(gstId);
      _gstMasters.removeWhere((g) => g.id == gstId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}