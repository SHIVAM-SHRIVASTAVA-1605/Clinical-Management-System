import '../models/patient_model.dart';

// Patient service for API calls
// TODO: Implement actual API calls when backend is ready
class PatientService {
  // Singleton pattern
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  // Mock data storage
  final List<PatientModel> _mockPatients = [];

  // Initialize with mock data
  void _initMockData() {
    _mockPatients.addAll([
      _createMockPatient(
        id: '1',
        firstName: 'John',
        lastName: 'Smith',
        gender: 'Male',
        bloodGroup: 'O+',
        clinicianIds: ['1'],
      ),
      _createMockPatient(
        id: '2',
        firstName: 'Sarah',
        lastName: 'Johnson',
        gender: 'Female',
        bloodGroup: 'A+',
        clinicianIds: ['1', '2'],
      ),
      _createMockPatient(
        id: '3',
        firstName: 'Mike',
        lastName: 'Wilson',
        gender: 'Male',
        bloodGroup: 'B+',
        clinicianIds: ['2'],
      ),
      _createMockPatient(
        id: '4',
        firstName: 'Emma',
        lastName: 'Davis',
        gender: 'Female',
        bloodGroup: 'AB+',
        clinicianIds: ['3'],
      ),
    ]);
  }

  // Get all patients
  Future<List<PatientModel>> getAllPatients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockPatients.isEmpty) {
      _initMockData();
    }
    
    return _mockPatients;
  }

  // Get patient by ID
  Future<PatientModel?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockPatients.isEmpty) {
      _initMockData();
    }
    
    try {
      return _mockPatients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get patients by clinician ID
  Future<List<PatientModel>> getPatientsByClinicianId(String clinicianId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockPatients.isEmpty) {
      _initMockData();
    }
    
    return _mockPatients
        .where((p) => p.assignedClinicianIds.contains(clinicianId))
        .toList();
  }

  // Add new patient
  Future<Map<String, dynamic>> addPatient(PatientModel patient) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    _mockPatients.add(patient);
    
    return {
      'success': true,
      'message': 'Patient added successfully',
      'data': patient.toJson(),
    };
  }

  // Update patient
  Future<Map<String, dynamic>> updatePatient(String id, PatientModel patient) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _mockPatients.indexWhere((p) => p.id == id);
    
    if (index != -1) {
      _mockPatients[index] = patient;
      return {
        'success': true,
        'message': 'Patient updated successfully',
        'data': patient.toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Patient not found',
    };
  }

  // Delete patient
  Future<Map<String, dynamic>> deletePatient(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final initialLength = _mockPatients.length;
    _mockPatients.removeWhere((p) => p.id == id);
    final removed = initialLength != _mockPatients.length;
    
    if (removed) {
      return {
        'success': true,
        'message': 'Patient deleted successfully',
      };
    }
    
    return {
      'success': false,
      'message': 'Patient not found',
    };
  }

  // Search patients
  Future<List<PatientModel>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockPatients.isEmpty) {
      _initMockData();
    }
    
    final lowerQuery = query.toLowerCase();
    
    return _mockPatients.where((patient) {
      return patient.name.firstName.toLowerCase().contains(lowerQuery) ||
          patient.name.lastName.toLowerCase().contains(lowerQuery) ||
          patient.contact.email.toLowerCase().contains(lowerQuery) ||
          patient.contact.phone.contains(query);
    }).toList();
  }

  // Helper to create mock patient
  PatientModel _createMockPatient({
    required String id,
    required String firstName,
    required String lastName,
    required String gender,
    required String bloodGroup,
    required List<String> clinicianIds,
  }) {
    final dob = DateTime.now().subtract(Duration(days: 365 * (25 + int.parse(id) * 5)));
    
    return PatientModel(
      id: id,
      name: PatientName(
        firstName: firstName,
        lastName: lastName,
      ),
      demographics: PatientDemographics(
        dateOfBirth: dob,
        gender: gender,
        bloodGroup: bloodGroup,
        maritalStatus: int.parse(id) % 2 == 0 ? 'Married' : 'Single',
        occupation: 'Software Engineer',
      ),
      contact: PatientContact(
        email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}@email.com',
        phone: '+1-555-0${id}00',
        alternatePhone: '+1-555-0${id}99',
        address: PatientAddress(
          street: '${int.parse(id) * 100} Main Street',
          city: 'New York',
          state: 'NY',
          postalCode: '1000$id',
          country: 'USA',
        ),
      ),
      medicalHistory: MedicalHistory(
        allergies: int.parse(id) % 2 == 0 ? ['Penicillin'] : [],
        chronicConditions: int.parse(id) % 3 == 0 ? ['Diabetes'] : [],
        pastSurgeries: [],
        currentMedications: int.parse(id) % 2 == 0 ? ['Aspirin 100mg'] : [],
        bloodPressure: '120/80',
        height: '${170 + int.parse(id) * 2}',
        weight: '${70 + int.parse(id) * 3}',
      ),
      assignedClinicianIds: clinicianIds,
      emergencyContact: EmergencyContact(
        name: 'Emergency Contact $id',
        relationship: 'Spouse',
        phone: '+1-555-9${id}00',
      ),
      insurance: Insurance(
        provider: 'HealthCare Plus',
        policyNumber: 'HCP-${id}00${id}00',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    );
  }
}