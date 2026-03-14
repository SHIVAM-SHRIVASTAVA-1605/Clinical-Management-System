import 'package:flutter/material.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/analytics/data/services/analytics_service.dart';
import 'dart:typed_data';

// Analytics provider for state management with ClinicalAnalytics model
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = false;
  String? _errorMessage;

  // ClinicalAnalytics properties
  List<ClinicalAnalyticsModel> _clinicalAnalyticsRecords = [];
  String? _selectedMetricType;
  AnalyticsFilters? _analyticsFilters;

  // Common getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for clinical analytics
  List<ClinicalAnalyticsModel> get clinicalAnalyticsRecords => _clinicalAnalyticsRecords;
  String? get selectedMetricType => _selectedMetricType;
  AnalyticsFilters? get analyticsFilters => _analyticsFilters;

  // Fetch clinical analytics with filters
  Future<void> fetchClinicalAnalytics({
    String? metricType,
    String? clinicianId,
    String? location,
    String? patientAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _clinicalAnalyticsRecords = await _analyticsService.getAnalytics(
        metricType: metricType,
        clinicianId: clinicianId,
        location: location,
        patientAgeGroup: patientAgeGroup,
        startDate: startDate,
        endDate: endDate,
      );
      _selectedMetricType = metricType;
      _analyticsFilters = AnalyticsFilters(
        clinicianId: clinicianId,
        location: location,
        patientAgeGroup: patientAgeGroup,
      );
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load clinical analytics: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Export analytics as CSV
  Future<String?> exportAnalyticsAsCSV({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final csvData = await _analyticsService.exportAnalyticsAsCSV(
        metricType: metricType,
        filters: filters,
      );
      _setLoading(false);
      return csvData;
    } catch (e) {
      _setError('Failed to export analytics as CSV: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Export analytics as CSV bytes for download
  Future<Uint8List?> exportAnalyticsAsCSVBytes({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final bytes = await _analyticsService.exportAnalyticsAsCSVBytes(
        metricType: metricType,
        filters: filters,
      );
      _setLoading(false);
      return bytes;
    } catch (e) {
      _setError('Failed to export analytics as CSV: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  // Set metric type filter
  void setMetricTypeFilter(String? metricType) {
    _selectedMetricType = metricType;
    fetchClinicalAnalytics(
      metricType: metricType,
      clinicianId: _analyticsFilters?.clinicianId,
      location: _analyticsFilters?.location,
      patientAgeGroup: _analyticsFilters?.patientAgeGroup,
    );
  }

  // Clear all filters
  void clearAllFilters() {
    _selectedMetricType = null;
    _analyticsFilters = null;
    fetchClinicalAnalytics();
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