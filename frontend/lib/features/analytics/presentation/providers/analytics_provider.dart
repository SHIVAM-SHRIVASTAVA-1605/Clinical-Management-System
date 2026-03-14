import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/analytics/data/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = false;
  String? _errorMessage;
  ClinicalAnalyticsModel? _analytics;
  ClinicalAnalyticsQuery _activeQuery = const ClinicalAnalyticsQuery();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClinicalAnalyticsModel? get analytics => _analytics;
  ClinicalAnalyticsQuery get activeQuery => _activeQuery;

  Future<void> fetchClinicalAnalytics({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final mergedQuery = query ?? _activeQuery;
      _analytics = await _analyticsService.getAnalytics(
        query: mergedQuery,
        startDate: startDate,
        endDate: endDate,
      );
      _activeQuery = mergedQuery;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load analytics: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<String?> exportAnalyticsAsCSV({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final csvData = await _analyticsService.exportAnalyticsAsCSV(
        query: query ?? _activeQuery,
        startDate: startDate,
        endDate: endDate,
      );
      _setLoading(false);
      return csvData;
    } catch (e) {
      _setError('Failed to export analytics as CSV: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  Future<Uint8List?> exportAnalyticsAsCSVBytes({
    ClinicalAnalyticsQuery? query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final bytes = await _analyticsService.exportAnalyticsAsCSVBytes(
        query: query ?? _activeQuery,
        startDate: startDate,
        endDate: endDate,
      );
      _setLoading(false);
      return bytes;
    } catch (e) {
      _setError('Failed to export analytics as CSV: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  Future<void> applyQuery(ClinicalAnalyticsQuery query) async {
    await fetchClinicalAnalytics(query: query);
  }

  Future<void> clearAllFilters() async {
    _activeQuery = const ClinicalAnalyticsQuery();
    await fetchClinicalAnalytics(query: _activeQuery);
  }

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
