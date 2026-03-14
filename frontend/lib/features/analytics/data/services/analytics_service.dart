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

  List<ClinicalAnalyticsModel> _parseAnalyticsList(dynamic payload) {
    if (payload is List) {
      return payload
          .map((e) => ClinicalAnalyticsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (payload is Map<String, dynamic>) {
      final direct = payload['analytics'] ?? payload['data'] ?? payload['items'];
      if (direct is List) {
        return direct
            .map((e) => ClinicalAnalyticsModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (payload['data'] is Map<String, dynamic>) {
        final nested = (payload['data'] as Map<String, dynamic>)['analytics'] ??
            (payload['data'] as Map<String, dynamic>)['items'];
        if (nested is List) {
          return nested
              .map((e) => ClinicalAnalyticsModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return <ClinicalAnalyticsModel>[];
  }

  // GET /api/analytics — Fetch clinical analytics (filterable)
  Future<List<ClinicalAnalyticsModel>> getAnalytics({
    String? metricType,
    String? clinicianId,
    String? location,
    String? patientAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        if (metricType != null && metricType.isNotEmpty) 'metricType': metricType,
        if (clinicianId != null && clinicianId.isNotEmpty) 'clinicianId': clinicianId,
        if (location != null && location.isNotEmpty) 'location': location,
        if (patientAgeGroup != null && patientAgeGroup.isNotEmpty)
          'patientAgeGroup': patientAgeGroup,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analytics}')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _authHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return _parseAnalyticsList(body);
      }

      return <ClinicalAnalyticsModel>[];
    } catch (_) {
      return <ClinicalAnalyticsModel>[];
    }
  }

  // POST /api/analytics/export — Export analytics data as CSV
  Future<String> exportAnalyticsAsCSV({
    String? metricType,
    AnalyticsFilters? filters,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.analyticsExport}');
      final body = <String, dynamic>{
        'format': 'csv',
        if (metricType != null && metricType.isNotEmpty) 'metricType': metricType,
        if (filters?.clinicianId != null) 'clinicianId': filters!.clinicianId,
        if (filters?.location != null) 'location': filters!.location,
        if (filters?.patientAgeGroup != null)
          'patientAgeGroup': filters!.patientAgeGroup,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await http.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('text/csv')) {
          return response.body;
        }

        final payload = jsonDecode(response.body);
        if (payload is Map<String, dynamic>) {
          final csv = payload['csv'] ?? payload['data'] ?? payload['content'];
          if (csv is String) return csv;
          final url = payload['url'] ?? payload['downloadUrl'];
          if (url is String) return url;
          final message = payload['message'];
          if (message is String) return message;
        }

        return response.body;
      }

      return 'Export failed with status ${response.statusCode}';
    } catch (e) {
      return 'Network error: ${e.toString()}';
    }
  }

  Future<Uint8List> exportAnalyticsAsCSVBytes({
    String? metricType,
    AnalyticsFilters? filters,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final csv = await exportAnalyticsAsCSV(
      metricType: metricType,
      filters: filters,
      startDate: startDate,
      endDate: endDate,
    );
    return Uint8List.fromList(csv.codeUnits);
  }

  // Backward-compatible alias
  Future<List<ClinicalAnalyticsModel>> fetchAnalytics({
    String? metricType,
    String? clinicianId,
    String? location,
    String? patientAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return getAnalytics(
      metricType: metricType,
      clinicianId: clinicianId,
      location: location,
      patientAgeGroup: patientAgeGroup,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Backward-compatible alias
  Future<String> exportAnalytics({
    required String format,
    String? metricType,
    AnalyticsFilters? filters,
  }) {
    return exportAnalyticsAsCSV(
      metricType: metricType,
      filters: filters,
    );
  }

}
