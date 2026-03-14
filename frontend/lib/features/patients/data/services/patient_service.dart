import 'dart:convert';

import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/features/patients/data/models/patient_model.dart';
import 'package:http/http.dart' as http;

class PatientService {
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;

  PatientService._internal();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  List<PatientModel> _parsePatients(dynamic payload) {
    if (payload is List) {
      return payload
          .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final direct = payload['patients'] ?? payload['data'] ?? payload['items'];
      if (direct is List) {
        return direct
            .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (payload['data'] is Map<String, dynamic>) {
        final nested = (payload['data'] as Map<String, dynamic>)['patients'] ??
            (payload['data'] as Map<String, dynamic>)['items'];
        if (nested is List) {
          return nested
              .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return <PatientModel>[];
  }

  Future<List<PatientModel>> getAllPatients() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.patients}');
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return _parsePatients(body);
      }

      return <PatientModel>[];
    } catch (_) {
      return <PatientModel>[];
    }
  }

  Future<PatientModel?> getPatientById(String id) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.patientById(id)}',
      );
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (body['patient'] ?? body['data'] ?? body) as Map<String, dynamic>;
        return PatientModel.fromJson(raw);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> addPatient(PatientModel patient) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.patients}');
      final response = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(patient.toJson()),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = (body['patient'] ?? body['data'] ?? body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': body['message'] ?? 'Patient added successfully.',
          'data': PatientModel.fromJson(raw),
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Failed to create patient.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updatePatient(
    String id,
    PatientModel patient,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.patientById(id)}',
      );
      final response = await http.put(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(patient.toJson()),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        final raw = (body['patient'] ?? body['data'] ?? body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': body['message'] ?? 'Patient updated successfully.',
          'data': PatientModel.fromJson(raw),
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update patient.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deletePatient(String id) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.patientById(id)}',
      );
      final response = await http.delete(uri, headers: await _authHeaders());

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Patient deleted successfully.',
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Failed to delete patient.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
