import 'package:flutter/material.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/data/services/treatment_plan_service.dart';

// Treatment Plan provider for state management
class TreatmentPlanProvider extends ChangeNotifier {
  final TreatmentPlanService _treatmentPlanService = TreatmentPlanService();

  List<TreatmentPlanModel> _treatmentPlans = [];
  TreatmentPlanModel? _selectedTreatmentPlan;
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'All';

  // Getters
  List<TreatmentPlanModel> get treatmentPlans => _treatmentPlans;
  TreatmentPlanModel? get selectedTreatmentPlan => _selectedTreatmentPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;

  // Filtered treatment plans based on status
  List<TreatmentPlanModel> get filteredTreatmentPlans {
    if (_filterStatus == 'All') {
      return _treatmentPlans;
    }
    return _treatmentPlans
        .where((t) => t.hasFollowUpStatus(_filterStatus))
        .toList();
  }

  // Active treatment plans have at least one pending follow-up
  List<TreatmentPlanModel> get activeTreatmentPlans {
    return _treatmentPlans
        .where((t) => t.hasFollowUpStatus(FollowUpStatus.pending))
        .toList();
  }

  // Set filter status
  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Fetch all treatment plans
  Future<void> fetchTreatmentPlans() async {
    _setLoading(true);
    _clearError();

    try {
      _treatmentPlans = await _treatmentPlanService.getAllTreatmentPlans();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plans: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch treatment plan by ID
  Future<void> fetchTreatmentPlanById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedTreatmentPlan =
          await _treatmentPlanService.getTreatmentPlanById(id);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plan: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch treatment plans by patient ID
  Future<void> fetchTreatmentPlansByPatientId(String patientId) async {
    _setLoading(true);
    _clearError();

    try {
      _treatmentPlans =
          await _treatmentPlanService.getTreatmentPlansByPatientId(patientId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plans: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch treatment plans by clinician ID
  Future<void> fetchTreatmentPlansByClinicianId(String clinicianId) async {
    _setLoading(true);
    _clearError();

    try {
      _treatmentPlans = await _treatmentPlanService
          .getTreatmentPlansByClinicianId(clinicianId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plans: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch active treatment plans
  Future<void> fetchActiveTreatmentPlans() async {
    _setLoading(true);
    _clearError();

    try {
      _treatmentPlans = await _treatmentPlanService.getActiveTreatmentPlans();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plans: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Fetch treatment plans by status
  Future<void> fetchTreatmentPlansByStatus(String status) async {
    _setLoading(true);
    _clearError();

    try {
      _treatmentPlans =
          await _treatmentPlanService.getTreatmentPlansByStatus(status);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load treatment plans: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Add new treatment plan
  Future<bool> addTreatmentPlan(TreatmentPlanModel treatmentPlan) async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _treatmentPlanService.addTreatmentPlan(treatmentPlan);

      if (response['success'] == true) {
        await fetchTreatmentPlans(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create treatment plan');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to create treatment plan: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Update treatment plan
  Future<bool> updateTreatmentPlan(
      String id, TreatmentPlanModel treatmentPlan) async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _treatmentPlanService.updateTreatmentPlan(id, treatmentPlan);

      if (response['success'] == true) {
        await fetchTreatmentPlans();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update treatment plan');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update treatment plan: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Delete treatment plan
  Future<bool> deleteTreatmentPlan(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _treatmentPlanService.deleteTreatmentPlan(id);

      if (response['success'] == true) {
        await fetchTreatmentPlans();
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete treatment plan');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete treatment plan: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Clear selected treatment plan
  void clearSelectedTreatmentPlan() {
    _selectedTreatmentPlan = null;
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
