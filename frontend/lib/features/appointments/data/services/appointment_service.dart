import 'dart:convert';

import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AppointmentService {
  static final AppointmentService _instance = AppointmentService._internal();
  factory AppointmentService() => _instance;
  AppointmentService._internal();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  List<AppointmentModel> _parseAppointmentList(dynamic payload) {
    if (payload is List) {
      return payload
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final directList = payload['appointments'] ?? payload['data'] ?? payload['items'];
      if (directList is List) {
        return directList
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (payload['data'] is Map<String, dynamic>) {
        final nested = (payload['data'] as Map<String, dynamic>)['appointments'] ??
            (payload['data'] as Map<String, dynamic>)['items'];
        if (nested is List) {
          return nested
              .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return <AppointmentModel>[];
  }

  Future<List<AppointmentModel>> getAllAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    String? clinicianId,
    String? patientId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (status != null && status.isNotEmpty) 'status': status,
        if (clinicianId != null && clinicianId.isNotEmpty) 'clinicianId': clinicianId,
        if (patientId != null && patientId.isNotEmpty) 'patientId': patientId,
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.appointments}')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return _parseAppointmentList(body);
      }

      return <AppointmentModel>[];
    } catch (_) {
      return <AppointmentModel>[];
    }
  }

  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.appointmentById(id)}',
      );
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (data['appointment'] ?? data['data'] ?? data) as Map<String, dynamic>;
        return AppointmentModel.fromJson(raw);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addAppointment(AppointmentModel appointment) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.appointments}');
      final response = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(appointment.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = AppointmentModel.fromJson(
          (data['appointment'] ?? data['data'] ?? data) as Map<String, dynamic>,
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Appointment booked successfully',
          'data': created.toJson(),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to book appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> scheduleAppointment(AppointmentModel appointment) =>
      addAppointment(appointment);

  Future<Map<String, dynamic>> updateAppointment(
    String id,
    AppointmentModel appointment,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.appointmentById(id)}',
      );
      final response = await http.put(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(appointment.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final updated = AppointmentModel.fromJson(
          (data['appointment'] ?? data['data'] ?? data) as Map<String, dynamic>,
        );
        return {
          'success': true,
          'message': data['message'] ?? 'Appointment updated successfully',
          'data': updated.toJson(),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(
    String id,
    String status,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.appointmentStatus(id)}',
      );
      final response = await http.patch(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Appointment status updated',
          'data': data['appointment'] ?? data['data'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteAppointment(String id) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.appointmentById(id)}',
      );
      final response = await http.delete(uri, headers: await _authHeaders());

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Appointment deleted successfully',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to delete appointment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Convenience methods for existing provider/UI without adding new endpoints.
  Future<List<AppointmentModel>> getAppointmentsByPatientId(String patientId) =>
      getAllAppointments(patientId: patientId);

  Future<List<AppointmentModel>> getAppointmentsByClinicianId(String clinicianId) =>
      getAllAppointments(clinicianId: clinicianId);

  Future<List<AppointmentModel>> getAppointmentsByStatus(String status) =>
      getAllAppointments(status: status);

  Future<List<AppointmentModel>> getTodaysAppointments() async {
    final all = await getAllAppointments();
    return all.where((a) => a.isToday).toList();
  }

  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    final all = await getAllAppointments();
    return all.where((a) => a.isUpcoming).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Future<Map<String, dynamic>> cancelAppointment(String id) =>
      updateAppointmentStatus(id, AppointmentStatus.cancelled);

  Future<Map<String, dynamic>> completeAppointment(String id) =>
      updateAppointmentStatus(id, AppointmentStatus.completed);
}
