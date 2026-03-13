import 'package:flutter/material.dart';
import 'package:frontend/features/patients/data/models/patient_model.dart';
import 'package:frontend/features/patients/data/services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  final PatientService _service = PatientService();

  List<PatientModel> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PatientModel> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<PatientModel> getPatientsByClinicianId(String clinicianId) {
    return _patients.where((p) => p.clinicianId == clinicianId).toList();
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = _service.getAllPatients();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addPatient(PatientModel patient) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.addPatient(patient);
      if (result['success'] == true) {
        _patients = _service.getAllPatients();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
