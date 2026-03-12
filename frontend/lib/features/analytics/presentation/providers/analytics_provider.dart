import 'package:flutter/material.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/analytics/data/services/analytics_service.dart';

// Analytics provider for state management
class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  AnalyticsData? _analyticsData;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  AnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Quick access getters
  AnalyticsOverview? get overview => _analyticsData?.overview;
  AppointmentStatistics? get appointmentStats => _analyticsData?.appointmentStats;
  TreatmentPlanStatistics? get treatmentPlanStats => _analyticsData?.treatmentPlanStats;
  PatientDemographics? get demographics => _analyticsData?.demographics;
  List<TopDiagnosis> get topDiagnoses => _analyticsData?.topDiagnoses ?? [];
  List<MonthlyRevenue> get monthlyRevenue => _analyticsData?.monthlyRevenue ?? [];
  List<AppointmentTrend> get appointmentTrends => _analyticsData?.appointmentTrends ?? [];

  // Fetch all analytics data
  Future<void> fetchAnalytics() async {
    _setLoading(true);
    _clearError();

    try {
      _analyticsData = await _analyticsService.getAnalyticsData();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load analytics: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch analytics by date range
  Future<void> fetchAnalyticsByDateRange(DateTime start, DateTime end) async {
    _setLoading(true);
    _clearError();

    try {
      _startDate = start;
      _endDate = end;
      _analyticsData = await _analyticsService.getAnalyticsByDateRange(start, end);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load analytics: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch analytics by department
  Future<void> fetchAnalyticsByDepartment(String department) async {
    _setLoading(true);
    _clearError();

    try {
      _analyticsData = await _analyticsService.getAnalyticsByDepartment(department);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load analytics: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Clear date filter
  void clearDateFilter() {
    _startDate = null;
    _endDate = null;
    fetchAnalytics();
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