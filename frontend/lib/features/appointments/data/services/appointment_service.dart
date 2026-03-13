import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/core/constants/api_constants.dart';

// Appointment service for API calls
// TODO: Implement actual API calls when backend is ready

class AppointmentService {
  
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  // Mock data storage
  final List<AppointmentModel> _mockAppointments = [];

  // Initialize with mock data
  void _initMockData() {
    final now = DateTime.now();
    
    _mockAppointments.addAll([
      // Today's appointments
      _createMockAppointment(
        id: '1',
        patientId: '1',
        patientName: 'John Smith',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        scheduledAt: DateTime(now.year, now.month, now.day, 9, 0),
        type: AppointmentType.consultation,
        status: AppointmentStatus.scheduled,
      ),
      _createMockAppointment(
        id: '2',
        patientId: '2',
        patientName: 'Sarah Johnson',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        scheduledAt: DateTime(now.year, now.month, now.day, 11, 30),
        type: AppointmentType.followUp,
        status: AppointmentStatus.confirmed,
      ),
      _createMockAppointment(
        id: '3',
        patientId: '3',
        patientName: 'Mike Wilson',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        scheduledAt: DateTime(now.year, now.month, now.day, 14, 0),
        type: AppointmentType.checkup,
        status: AppointmentStatus.scheduled,
      ),
      
      // Tomorrow's appointments
      _createMockAppointment(
        id: '4',
        patientId: '4',
        patientName: 'Emma Davis',
        clinicianId: '3',
        clinicianName: 'Nurse Sarah Davis',
        scheduledAt: DateTime(now.year, now.month, now.day + 1, 10, 0),
        type: AppointmentType.consultation,
        status: AppointmentStatus.scheduled,
      ),
      _createMockAppointment(
        id: '5',
        patientId: '1',
        patientName: 'John Smith',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        scheduledAt: DateTime(now.year, now.month, now.day + 1, 15, 30),
        type: AppointmentType.procedure,
        status: AppointmentStatus.scheduled,
      ),
      
      // Past appointments
      _createMockAppointment(
        id: '6',
        patientId: '2',
        patientName: 'Sarah Johnson',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        scheduledAt: DateTime(now.year, now.month, now.day - 2, 10, 0),
        type: AppointmentType.consultation,
        status: AppointmentStatus.completed,
      ),
      _createMockAppointment(
        id: '7',
        patientId: '3',
        patientName: 'Mike Wilson',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        scheduledAt: DateTime(now.year, now.month, now.day - 5, 14, 30),
        type: AppointmentType.followUp,
        status: AppointmentStatus.cancelled,
      ),
    ]);
  }

  // Get all appointments
  Future<List<AppointmentModel>> getAllAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments;
  }

  // Get appointment by ID
  Future<AppointmentModel?> getAppointmentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    try {
      return _mockAppointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get appointments by patient ID
  Future<List<AppointmentModel>> getAppointmentsByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments.where((a) => a.patientId == patientId).toList();
  }

  // Get appointments by clinician ID
  Future<List<AppointmentModel>> getAppointmentsByClinicianId(String clinicianId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments.where((a) => a.clinicianId == clinicianId).toList();
  }

  // Get today's appointments
  Future<List<AppointmentModel>> getTodaysAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments.where((a) => a.isToday).toList();
  }

  // Get upcoming appointments
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Get appointments by status
  Future<List<AppointmentModel>> getAppointmentsByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockAppointments.isEmpty) {
      _initMockData();
    }
    
    return _mockAppointments.where((a) => a.status == status).toList();
  }

  // Add new appointment
  Future<Map<String, dynamic>> addAppointment(AppointmentModel appointment) async {
    final endpoint = ApiConstants.appointments;
    // TODO: Replace mock flow with POST endpoint call
    await Future.delayed(const Duration(milliseconds: 800));
    
    _mockAppointments.add(appointment);
    
    return {
      'success': true,
      'message': 'Appointment booked successfully',
      'endpoint': endpoint,
      'data': appointment.toJson(),
    };
  }

  // Update appointment
  Future<Map<String, dynamic>> updateAppointment(String id, AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _mockAppointments.indexWhere((a) => a.id == id);
    
    if (index != -1) {
      _mockAppointments[index] = appointment;
      return {
        'success': true,
        'message': 'Appointment updated successfully',
        'data': appointment.toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Appointment not found',
    };
  }

  // Update appointment status
  Future<Map<String, dynamic>> updateAppointmentStatus(String id, String status) async {
    final endpoint = ApiConstants.appointmentStatus(id);
    // TODO: Replace mock flow with PUT endpoint call
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockAppointments.indexWhere((a) => a.id == id);
    
    if (index != -1) {
      _mockAppointments[index] = _mockAppointments[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      return {
        'success': true,
        'message': 'Appointment status updated',
        'endpoint': endpoint,
        'data': _mockAppointments[index].toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Appointment not found',
    };
  }

  // Cancel appointment
  Future<Map<String, dynamic>> cancelAppointment(String id) async {
    return await updateAppointmentStatus(id, AppointmentStatus.cancelled);
  }

  // Complete appointment
  Future<Map<String, dynamic>> completeAppointment(String id) async {
    return await updateAppointmentStatus(id, AppointmentStatus.completed);
  }

  // Delete appointment
  Future<Map<String, dynamic>> deleteAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final initialLength = _mockAppointments.length;
    _mockAppointments.removeWhere((a) => a.id == id);
    final removed = initialLength != _mockAppointments.length;
    
    if (removed) {
      return {
        'success': true,
        'message': 'Appointment deleted successfully',
      };
    }
    
    return {
      'success': false,
      'message': 'Appointment not found',
    };
  }

  // Endpoint-aligned: POST /appointments
  Future<Map<String, dynamic>> scheduleAppointment(AppointmentModel appointment) {
    return addAppointment(appointment);
  }

  // Endpoint-aligned: GET /appointments/patient/:id with pagination
  Future<Map<String, dynamic>> getAppointmentsByPatientPaginated(
    String patientId, {
    int page = 1,
    int limit = 10,
  }) async {
    final endpoint = ApiConstants.appointmentsByPatient(patientId);
    // TODO: Replace mock flow with GET endpoint call and query params
    final records = await getAppointmentsByPatientId(patientId);
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit < 1 ? 10 : limit;
    final start = (safePage - 1) * safeLimit;
    final end = start + safeLimit;
    final paged = start >= records.length
        ? <AppointmentModel>[]
        : records.sublist(start, end > records.length ? records.length : end);

    return {
      'success': true,
      'endpoint': endpoint,
      'data': paged.map((e) => e.toJson()).toList(),
      'pagination': {
        'page': safePage,
        'limit': safeLimit,
        'total': records.length,
        'totalPages': (records.length / safeLimit).ceil(),
      },
    };
  }

  // Endpoint-aligned: GET /appointments/clinician/:id with filters
  Future<List<AppointmentModel>> getAppointmentsByClinicianWithFilters(
    String clinicianId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = ApiConstants.appointmentsByClinician(clinicianId);
    // TODO: Replace mock flow with GET endpoint call and query filters
    var result = await getAppointmentsByClinicianId(clinicianId);

    if (status != null && status.isNotEmpty) {
      result = result.where((a) => a.status == status).toList();
    }
    if (startDate != null) {
      result = result.where((a) => !a.scheduledAt.isBefore(startDate)).toList();
    }
    if (endDate != null) {
      result = result.where((a) => !a.scheduledAt.isAfter(endDate)).toList();
    }
    if (endpoint.isEmpty) return <AppointmentModel>[];
    return result;
  }

  // Helper to create mock appointment
  AppointmentModel _createMockAppointment({
    required String id,
    required String patientId,
    required String patientName,
    required String clinicianId,
    required String clinicianName,
    required DateTime scheduledAt,
    required String type,
    required String status,
  }) {
    return AppointmentModel(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      appointmentType: type,
      status: status,
      scheduledAt: scheduledAt,
      duration: type == AppointmentType.procedure ? 60 : 30,
      location: type == AppointmentType.procedure 
          ? AppointmentLocation.mainClinic 
          : AppointmentLocation.telehealth,
      notes: 'Patient appointment for $type',
      billing: BillingInfo(
        amount: type == AppointmentType.procedure ? 500.0 : 150.0,
        status: status == AppointmentStatus.completed ? 'Paid' : 'Pending',
        insuranceDetails: InsuranceDetails(
          provider: 'HealthCare Plus',
          policyNumber: 'HCP-$patientId${id}00',
        ),
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      patientName: patientName,
      clinicianName: clinicianName,
    );
  }
}