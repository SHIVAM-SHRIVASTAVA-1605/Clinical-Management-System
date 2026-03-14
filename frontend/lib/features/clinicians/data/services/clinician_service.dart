import 'dart:convert';

import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../models/clinician_model.dart';

class ClinicianService {
  static final ClinicianService _instance = ClinicianService._internal();
  factory ClinicianService() => _instance;
  ClinicianService._internal();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // POST /api/clinicians — Register a new clinician
  Future<Map<String, dynamic>> addClinician(ClinicianModel clinician) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.clinicians}');
      final response = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(clinician.toJson()),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = ClinicianModel.fromJson(
          (data['clinician'] ?? data['data'] ?? data) as Map<String, dynamic>,
        );
        return {'success': true, 'message': data['message'] ?? 'Clinician registered', 'data': created.toJson()};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to register clinician'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Alias kept for backward compatibility
  Future<Map<String, dynamic>> registerClinician(ClinicianModel clinician) =>
      addClinician(clinician);

  // GET /api/clinicians/:id — Get clinician details by ID
  Future<ClinicianModel?> getClinicianById(String id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.clinicianById(id)}');
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final raw = (data['clinician'] ?? data['data'] ?? data) as Map<String, dynamic>;
        return ClinicianModel.fromJson(raw);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // PUT /api/clinicians/:id/availability — Update clinician availability schedule
  Future<Map<String, dynamic>> updateClinicianAvailability(
    String id,
    List<ClinicianAvailability> availability,
  ) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.clinicianAvailability(id)}',
      );
      final response = await http.put(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode({'availability': availability.map((a) => a.toJson()).toList()}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Availability updated'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update availability'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // --- No backend endpoint provided yet for the methods below ---

  Future<List<ClinicianModel>> getAllClinicians() async {
    // TODO: wire once GET /api/clinicians endpoint is available
    return [];
  }

  Future<Map<String, dynamic>> updateClinician(String id, ClinicianModel clinician) async {
    // TODO: wire once PUT /api/clinicians/:id endpoint is available
    return {'success': false, 'message': 'Not implemented'};
  }

  Future<Map<String, dynamic>> deleteClinician(String id) async {
    // TODO: wire once DELETE /api/clinicians/:id endpoint is available
    return {'success': false, 'message': 'Not implemented'};
  }

  Future<List<ClinicianModel>> searchClinicians(String query) async {
    // TODO: wire once search endpoint is available
    return [];
  }

}