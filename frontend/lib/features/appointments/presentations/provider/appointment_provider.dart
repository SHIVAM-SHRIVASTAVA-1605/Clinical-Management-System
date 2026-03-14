import 'package:flutter/material.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/data/services/appointment_service.dart';


// Appointment provider for state management
class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<AppointmentModel> _appointments = [];
  AppointmentModel? _selectedAppointment;
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'All';

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  AppointmentModel? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;

  // Filtered appointments based on status
  List<AppointmentModel> get filteredAppointments {
    if (_filterStatus == 'All') {
      return _appointments;
    }
    return _appointments.where((a) => a.status == _filterStatus).toList();
  }

  // Today's appointments
  List<AppointmentModel> get todaysAppointments {
    return _appointments.where((a) => a.isToday).toList();
  }

  // Upcoming appointments
  List<AppointmentModel> get upcomingAppointments {
    return _appointments.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Set filter status
  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Fetch all appointments
  Future<void> fetchAppointments() async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAllAppointments();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch appointment by ID
  Future<void> fetchAppointmentById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedAppointment = await _appointmentService.getAppointmentById(id);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointment: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch appointments by patient ID
  Future<void> fetchAppointmentsByPatientId(String patientId) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAppointmentsByPatientId(patientId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch appointments by clinician ID
  Future<void> fetchAppointmentsByClinicianId(String clinicianId) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAppointmentsByClinicianId(clinicianId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch today's appointments
  Future<void> fetchTodaysAppointments() async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getTodaysAppointments();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch upcoming appointments
  Future<void> fetchUpcomingAppointments() async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getUpcomingAppointments();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch appointments by status
  Future<void> fetchAppointmentsByStatus(String status) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAppointmentsByStatus(status);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load appointments: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new appointment
  Future<bool> addAppointment(AppointmentModel appointment) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _appointmentService.addAppointment(appointment);
      
      if (response['success'] == true) {
        await fetchAppointments();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to book appointment');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to book appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update appointment
  Future<bool> updateAppointment(String id, AppointmentModel appointment) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _appointmentService.updateAppointment(id, appointment);
      
      if (response['success'] == true) {
        await fetchAppointments();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update appointment');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String id, String status) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _appointmentService.updateAppointmentStatus(id, status);
      
      if (response['success'] == true) {
        await fetchAppointments();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update status');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String id) async {
    return await updateAppointmentStatus(id, AppointmentStatus.cancelled);
  }

  // Complete appointment
  Future<bool> completeAppointment(String id) async {
    return await updateAppointmentStatus(id, AppointmentStatus.completed);
  }

  // Delete appointment
  Future<bool> deleteAppointment(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _appointmentService.deleteAppointment(id);
      
      if (response['success'] == true) {
        await fetchAppointments(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete appointment');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete appointment: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Clear selected appointment
  void clearSelectedAppointment() {
    _selectedAppointment = null;
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