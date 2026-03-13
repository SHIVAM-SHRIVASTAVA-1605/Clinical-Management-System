import 'package:frontend/features/patients/data/models/patient_model.dart';

class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;

  PatientService._internal();

  final List<PatientModel> _patients = [];

  List<PatientModel> getAllPatients() {
    return List<PatientModel>.from(_patients);
  }

  List<PatientModel> getPatientsByClinicianId(String clinicianId) {
    return _patients.where((p) => p.clinicianId == clinicianId).toList();
  }

  Future<Map<String, dynamic>> addPatient(PatientModel patient) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final idExists = _patients.any((p) => p.id == patient.id);
    if (idExists) {
      return {
        'success': false,
        'message': 'A patient with this _id already exists.',
      };
    }

    _patients.add(patient);
    return {
      'success': true,
      'message': 'Patient added successfully.',
      'data': patient,
    };
  }
}
