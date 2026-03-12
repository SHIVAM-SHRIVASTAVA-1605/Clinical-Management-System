import 'package:flutter/material.dart';
import '../../data/models/patient_model.dart';
import '../../data/services/patient_service.dart';

// Patient provider for state management
class PatientProvider extends ChangeNotifier {
  final PatientService _patientService = PatientService();

  List<PatientModel> _patients = [];
  PatientModel? _selectedPatient;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PatientModel> get patients => _patients;
  PatientModel? get selectedPatient => _selectedPatient;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all patients
  Future<void> fetchPatients() async {
    _setLoading(true);
    _clearError();

    try {
      _patients = await _patientService.getAllPatients();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load patients: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch patient by ID
  Future<void> fetchPatientById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedPatient = await _patientService.getPatientById(id);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load patient: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch patients by clinician ID
  Future<void> fetchPatientsByClinicianId(String clinicianId) async {
    _setLoading(true);
    _clearError();

    try {
      _patients = await _patientService.getPatientsByClinicianId(clinicianId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load patients: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new patient
  Future<bool> addPatient(PatientModel patient) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _patientService.addPatient(patient);
      
      if (response['success'] == true) {
        await fetchPatients(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to add patient');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to add patient: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update patient
  Future<bool> updatePatient(String id, PatientModel patient) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _patientService.updatePatient(id, patient);
      
      if (response['success'] == true) {
        await fetchPatients(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update patient');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update patient: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete patient
  Future<bool> deletePatient(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _patientService.deletePatient(id);
      
      if (response['success'] == true) {
        await fetchPatients(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete patient');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete patient: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Search patients
  Future<void> searchPatients(String query) async {
    if (query.isEmpty) {
      await fetchPatients();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _patients = await _patientService.searchPatients(query);
      _setLoading(false);
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Clear selected patient
  void clearSelectedPatient() {
    _selectedPatient = null;
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