import '../models/clinician_model.dart';
import 'package:frontend/core/constants/api_constants.dart';

// Clinician service for API calls
// TODO: Implement actual API calls when backend is ready
class ClinicianService {

  static final ClinicianService _instance = ClinicianService._internal();
  factory ClinicianService() => _instance;
  ClinicianService._internal();

  // Mock data storage
  final List<ClinicianModel> _mockClinicians = [];

  // Initialize with mock data
  void _initMockData() {
    // Intentionally empty: no hardcoded clinician data.
  }

  // Get all clinicians
  Future<List<ClinicianModel>> getAllClinicians() async {

    // TODO: Replace with actual API call
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    if (_mockClinicians.isEmpty) {
      _initMockData();
    }
    
    return _mockClinicians;
  }

  // Get clinician by ID
  Future<ClinicianModel?> getClinicianById(String id) async {
    final endpoint = ApiConstants.clinicianById(id);
    // TODO: Replace mock flow with GET endpoint call
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockClinicians.isEmpty) {
      _initMockData();
    }
    
    try {
      final clinician = _mockClinicians.firstWhere((c) => c.id == id);
      // Keep endpoint referenced until backend integration.
      if (endpoint.isEmpty) return null;
      return clinician;
    } catch (e) {
      return null;
    }
  }

  // Add new clinician
  Future<Map<String, dynamic>> addClinician(ClinicianModel clinician) async {
    final endpoint = ApiConstants.clinicians;
    // TODO: Replace mock flow with POST endpoint call
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    _mockClinicians.add(clinician);
    
    return {
      'success': true,
      'message': 'Clinician added successfully',
      'endpoint': endpoint,
      'data': clinician.toJson(),
    };
  }

  // Update clinician
  Future<Map<String, dynamic>> updateClinician(String id, ClinicianModel clinician) async {
    final endpoint = ApiConstants.clinicianById(id);
    // TODO: Replace mock flow with PUT endpoint call
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _mockClinicians.indexWhere((c) => c.id == id);
    
    if (index != -1) {
      _mockClinicians[index] = clinician;
      return {
        'success': true,
        'message': 'Clinician updated successfully',
        'endpoint': endpoint,
        'data': clinician.toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Clinician not found',
    };
  }

  // Delete clinician
  Future<Map<String, dynamic>> deleteClinician(String id) async {
    // TODO: Replace with actual API call
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final initialLength = _mockClinicians.length;
    _mockClinicians.removeWhere((c) => c.id == id);
    final removed = initialLength != _mockClinicians.length;
    
    if (removed) {
      return {
        'success': true,
        'message': 'Clinician deleted successfully',
      };
    }
    
    return {
      'success': false,
      'message': 'Clinician not found',
    };
  }

  // Update clinician availability schedule
  Future<Map<String, dynamic>> updateClinicianAvailability(
    String id,
    List<ClinicianAvailability> availability,
  ) async {
    final endpoint = ApiConstants.clinicianAvailability(id);
    // TODO: Replace mock flow with PUT endpoint call
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockClinicians.indexWhere((c) => c.id == id);
    if (index != -1) {
      final existing = _mockClinicians[index];
      _mockClinicians[index] = ClinicianModel(
        id: existing.id,
        name: existing.name,
        credentials: existing.credentials,
        contact: existing.contact,
        availability: availability,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
      return {
        'success': true,
        'message': 'Clinician availability updated successfully',
        'endpoint': endpoint,
        'data': _mockClinicians[index].toJson(),
      };
    }

    return {
      'success': false,
      'message': 'Clinician not found',
    };
  }

  // Endpoint-aligned alias for clinician registration
  Future<Map<String, dynamic>> registerClinician(ClinicianModel clinician) {
    // POST /clinicians
    return addClinician(clinician);
  }

  // Search clinicians
  Future<List<ClinicianModel>> searchClinicians(String query) async {
    // TODO: Replace with actual API call
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockClinicians.isEmpty) {
      _initMockData();
    }
    
    final lowerQuery = query.toLowerCase();
    
    return _mockClinicians.where((clinician) {
      return clinician.name.firstName.toLowerCase().contains(lowerQuery) ||
          clinician.name.lastName.toLowerCase().contains(lowerQuery) ||
          clinician.credentials.specialty.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Helper to create mock clinician
  ClinicianModel _createMockClinician({
    required String id,
    required String firstName,
    required String lastName,
    required String title,
    required String specialty,
    required String licenseNumber,
  }) {
    return ClinicianModel(
      id: id,
      name: ClinicianName(
        firstName: firstName,
        lastName: lastName,
        title: title,
      ),
      credentials: ClinicianCredentials(
        licenseNumber: licenseNumber,
        specialty: specialty,
        certifications: [
          Certification(
            name: 'Board Certification',
            issuedBy: 'Medical Board',
            issueDate: DateTime(2020, 1, 1),
          ),
        ],
      ),
      contact: ClinicianContact(
        email: '${firstName.toLowerCase()}.${lastName.toLowerCase()}@clinic.com',
        phone: '+1-555-0${id}00',
        officeAddress: OfficeAddress(
          street: '123 Medical Plaza',
          city: 'New York',
          state: 'NY',
          postalCode: '10001',
          country: 'USA',
        ),
      ),
      availability: [
        ClinicianAvailability(
          dayOfWeek: 'Monday',
          startTime: '09:00',
          endTime: '17:00',
          location: 'Main Clinic',
        ),
        ClinicianAvailability(
          dayOfWeek: 'Wednesday',
          startTime: '09:00',
          endTime: '17:00',
          location: 'Main Clinic',
        ),
        ClinicianAvailability(
          dayOfWeek: 'Friday',
          startTime: '09:00',
          endTime: '13:00',
          location: 'Downtown Branch',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    );
  }
}