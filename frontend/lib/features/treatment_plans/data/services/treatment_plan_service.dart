import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';

// Treatment Plan service for API calls
// TODO: Replace mock flow with real API integration.
class TreatmentPlanService {
  static final TreatmentPlanService _instance =
      TreatmentPlanService._internal();
  factory TreatmentPlanService() => _instance;
  TreatmentPlanService._internal();

  final List<TreatmentPlanModel> _mockTreatmentPlans = [];

  void _initMockData() {
    if (_mockTreatmentPlans.isNotEmpty) {
      return;
    }

    // Intentionally empty: no hardcoded treatment plan data.
  }

  Future<List<TreatmentPlanModel>> getAllTreatmentPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initMockData();
    return List<TreatmentPlanModel>.from(_mockTreatmentPlans);
  }

  Future<TreatmentPlanModel?> getTreatmentPlanById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initMockData();

    try {
      return _mockTreatmentPlans.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<TreatmentPlanModel>> getTreatmentPlansByPatientId(
    String patientId,
  ) async {
    final endpoint = ApiConstants.treatmentPlansByPatient(patientId);
    await Future.delayed(const Duration(milliseconds: 400));
    _initMockData();

    if (endpoint.isEmpty) {
      return <TreatmentPlanModel>[];
    }

    return _mockTreatmentPlans.where((t) => t.patientId == patientId).toList();
  }

  Future<List<TreatmentPlanModel>> getTreatmentPlansByClinicianId(
    String clinicianId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initMockData();
    return _mockTreatmentPlans
        .where((t) => t.clinicianId == clinicianId)
        .toList();
  }

  Future<List<TreatmentPlanModel>> getActiveTreatmentPlans() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initMockData();
    return _mockTreatmentPlans
        .where((t) => t.hasFollowUpStatus(FollowUpStatus.pending))
        .toList();
  }

  Future<List<TreatmentPlanModel>> getTreatmentPlansByStatus(
      String status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initMockData();
    return _mockTreatmentPlans
        .where((t) => t.hasFollowUpStatus(status))
        .toList();
  }

  Future<Map<String, dynamic>> addTreatmentPlan(
    TreatmentPlanModel treatmentPlan,
  ) async {
    final endpoint = ApiConstants.treatmentPlans;
    await Future.delayed(const Duration(milliseconds: 800));

    _mockTreatmentPlans.add(treatmentPlan);

    return {
      'success': true,
      'message': 'Treatment plan created successfully',
      'endpoint': endpoint,
      'data': treatmentPlan.toJson(),
    };
  }

  Future<Map<String, dynamic>> updateTreatmentPlan(
    String id,
    TreatmentPlanModel treatmentPlan,
  ) async {
    final endpoint = ApiConstants.treatmentPlanById(id);
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _mockTreatmentPlans.indexWhere((t) => t.id == id);

    if (index == -1) {
      return {
        'success': false,
        'message': 'Treatment plan not found',
      };
    }

    _mockTreatmentPlans[index] = treatmentPlan;
    return {
      'success': true,
      'message': 'Treatment plan updated successfully',
      'endpoint': endpoint,
      'data': treatmentPlan.toJson(),
    };
  }

  Future<Map<String, dynamic>> deleteTreatmentPlan(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final initialLength = _mockTreatmentPlans.length;
    _mockTreatmentPlans.removeWhere((t) => t.id == id);

    if (initialLength == _mockTreatmentPlans.length) {
      return {
        'success': false,
        'message': 'Treatment plan not found',
      };
    }

    return {
      'success': true,
      'message': 'Treatment plan deleted successfully',
    };
  }

  // Endpoint-aligned alias: POST /treatment-plans
  Future<Map<String, dynamic>> createTreatmentPlan(
    TreatmentPlanModel treatmentPlan,
  ) {
    return addTreatmentPlan(treatmentPlan);
  }

  // Endpoint-aligned alias: GET /treatment-plans/patient/:id
  Future<List<TreatmentPlanModel>> getTreatmentPlansForPatient(
      String patientId) {
    return getTreatmentPlansByPatientId(patientId);
  }

  TreatmentPlanModel _createMockTreatmentPlan({
    required String id,
    required String patientId,
    required String patientName,
    required String clinicianId,
    required String clinicianName,
    required Diagnosis diagnosis,
    required List<Prescription> prescriptions,
    required List<FollowUp> followUps,
    required Recommendations recommendations,
  }) {
    return TreatmentPlanModel(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      diagnosis: diagnosis,
      prescriptions: prescriptions,
      followUps: followUps,
      recommendations: recommendations,
      createdAt: diagnosis.diagnosedAt,
      updatedAt: DateTime.now(),
      patientName: patientName,
      clinicianName: clinicianName,
    );
  }
}
