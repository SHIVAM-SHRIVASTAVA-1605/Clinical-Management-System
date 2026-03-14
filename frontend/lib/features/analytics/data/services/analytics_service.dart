import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _formatDateForApi(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, String> _queryParamsFromFilter(ClinicalAnalyticsQuery filter) {
    final out = <String, String>{};
    final json = filter.toJson();
    json.forEach((key, value) {
      final text = value?.toString();
      if (text != null && text.isNotEmpty) {
        out[key] = text;
      }
    });
    return out;
  }

  // GET /api/analytics
  Future<ClinicalAnalyticsModel> getAnalytics({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final merged = ClinicalAnalyticsQuery(
      startDate: startDate != null
          ? _formatDateForApi(startDate)
          : query?.startDate,
      endDate: endDate != null ? _formatDateForApi(endDate) : query?.endDate,
      status: query?.status,
      clinicianId: query?.clinicianId,
      patientId: query?.patientId,
      appointmentType: query?.appointmentType,
      location: query?.location,
      billingStatus: query?.billingStatus,
    );

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analytics}')
        .replace(queryParameters: _queryParamsFromFilter(merged));
    final response = await http.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ClinicalAnalyticsModel.fromJson(body);
    }

    final payload = _decodeMap(response.body);
    final message = _errorMessageFromPayload(payload, response.statusCode);
    throw Exception(message);
  }

  // POST /api/analytics/export
  Future<String> exportAnalyticsAsCSV({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final merged = ClinicalAnalyticsQuery(
      startDate: startDate != null
          ? _formatDateForApi(startDate)
          : query?.startDate,
      endDate: endDate != null ? _formatDateForApi(endDate) : query?.endDate,
      status: query?.status,
      clinicianId: query?.clinicianId,
      patientId: query?.patientId,
      appointmentType: query?.appointmentType,
      location: query?.location,
      billingStatus: query?.billingStatus,
    );

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analyticsExport}');
    final response = await http.post(
      uri,
      headers: await _authHeaders(),
      body: jsonEncode(merged.toJson()),
    );

    if (response.statusCode == 200) {
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('text/csv')) {
        return response.body;
      }
      // Fallback: backend should return CSV text, but keep this safe guard.
      return response.body;
    }

    final payload = _decodeMap(response.body);
    final message = _errorMessageFromPayload(payload, response.statusCode);
    throw Exception(message);
  }

  Future<Uint8List> exportAnalyticsAsCSVBytes({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final csv = await exportAnalyticsAsCSV(
      query: query,
      startDate: startDate,
      endDate: endDate,
    );
    return Uint8List.fromList(csv.codeUnits);
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Ignore parse errors and fallback below.
    }
    return <String, dynamic>{'raw': body};
  }

  String _errorMessageFromPayload(Map<String, dynamic> payload, int status) {
    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parts = errors.map((e) => e.toString()).toList();
      return parts.join(', ');
    }

    final message = payload['message']?.toString();
    if (message != null && message.trim().isNotEmpty) return message;

    final error = payload['error']?.toString();
    if (error != null && error.trim().isNotEmpty) return error;

    final raw = payload['raw']?.toString();
    if (raw != null && raw.trim().isNotEmpty) return raw;

    return 'Analytics request failed (status $status)';
  }
}
