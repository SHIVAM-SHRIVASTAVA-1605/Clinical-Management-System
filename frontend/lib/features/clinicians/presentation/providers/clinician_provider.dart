import 'package:flutter/material.dart';
import 'package:frontend/features/clinicians/data/models/clinician_model.dart';
import 'package:frontend/features/clinicians/data/services/clinician_service.dart';

// Clinician provider for state management
class ClinicianProvider extends ChangeNotifier {
  final ClinicianService _clinicianService = ClinicianService();

  List<ClinicianModel> _clinicians = [];
  ClinicianModel? _selectedClinician;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ClinicianModel> get clinicians => _clinicians;
  ClinicianModel? get selectedClinician => _selectedClinician;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all clinicians
  Future<void> fetchClinicians() async {
    _setLoading(true);
    _clearError();

    try {
      _clinicians = await _clinicianService.getAllClinicians();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load clinicians: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch clinician by ID
  Future<void> fetchClinicianById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedClinician = await _clinicianService.getClinicianById(id);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load clinician: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new clinician
  Future<bool> addClinician(ClinicianModel clinician) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _clinicianService.addClinician(clinician);
      
      if (response['success'] == true) {
        // refresh list
        await fetchClinicians();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to add clinician');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to add clinician: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update clinician
  Future<bool> updateClinician(String id, ClinicianModel clinician) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _clinicianService.updateClinician(id, clinician);
      
      if (response['success'] == true) {
        // refresh list
        await fetchClinicians();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update clinician');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update clinician: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete clinician
  Future<bool> deleteClinician(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _clinicianService.deleteClinician(id);
      
      if (response['success'] == true) {
        // refresh list
        await fetchClinicians();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete clinician');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete clinician: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Search clinicians
  Future<void> searchClinicians(String query) async {
    if (query.isEmpty) {
      await fetchClinicians();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _clinicians = await _clinicianService.searchClinicians(query);
      _setLoading(false);
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Clear selected clinician
  void clearSelectedClinician() {
    _selectedClinician = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}