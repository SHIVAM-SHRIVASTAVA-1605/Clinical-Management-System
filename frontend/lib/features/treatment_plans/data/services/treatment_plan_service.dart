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

    final now = DateTime.now();

    _mockTreatmentPlans.addAll([
      _createMockTreatmentPlan(
        id: '1',
        patientId: '1',
        patientName: 'Patient ID: 1',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        diagnosis: Diagnosis(
          condition: 'Hypertension',
          diagnosedAt: now.subtract(const Duration(days: 7)),
          icd10Code: 'I10',
        ),
        prescriptions: [
          Prescription(
            medication: 'Lisinopril',
            dosage: '10mg',
            frequency: PrescriptionFrequency.onceDaily,
            startDate: now.subtract(const Duration(days: 7)),
            endDate: now.add(const Duration(days: 23)),
            instructions: 'Take in the morning with food',
          ),
          Prescription(
            medication: 'Aspirin',
            dosage: '81mg',
            frequency: PrescriptionFrequency.onceDaily,
            startDate: now.subtract(const Duration(days: 7)),
            endDate: null,
            instructions: 'Take with water after breakfast',
          ),
        ],
        followUps: [
          FollowUp(
            scheduledDate: now.add(const Duration(days: 10)),
            purpose: 'Monitor medication response',
            status: FollowUpStatus.pending,
          ),
        ],
        recommendations: Recommendations(
          lifestyleChanges: [
            'Reduce sodium intake below 2000mg/day',
            'Walk for 30 minutes at least 5 days/week',
          ],
          referrals: const [],
        ),
      ),
      _createMockTreatmentPlan(
        id: '2',
        patientId: '2',
        patientName: 'Patient ID: 2',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        diagnosis: Diagnosis(
          condition: 'Type 2 Diabetes',
          diagnosedAt: now.subtract(const Duration(days: 14)),
          icd10Code: 'E11.9',
        ),
        prescriptions: [
          Prescription(
            medication: 'Metformin',
            dosage: '500mg',
            frequency: PrescriptionFrequency.twiceDaily,
            startDate: now.subtract(const Duration(days: 14)),
            endDate: now.add(const Duration(days: 76)),
            instructions: 'Take with breakfast and dinner',
          ),
        ],
        followUps: [
          FollowUp(
            scheduledDate: now.add(const Duration(days: 7)),
            purpose: 'Review fasting and post-meal sugar logs',
            status: FollowUpStatus.pending,
          ),
        ],
        recommendations: Recommendations(
          lifestyleChanges: [
            'Carb count with 45-60g per meal',
            'Check blood sugar twice daily',
          ],
          referrals: [
            Referral(
              specialist: 'Dietitian',
              reason: 'Medical nutrition therapy planning',
            ),
          ],
        ),
      ),
      _createMockTreatmentPlan(
        id: '3',
        patientId: '3',
        patientName: 'Patient ID: 3',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        diagnosis: Diagnosis(
          condition: 'Chronic Back Pain',
          diagnosedAt: now.subtract(const Duration(days: 21)),
          icd10Code: 'M54.50',
        ),
        prescriptions: [
          Prescription(
            medication: 'Ibuprofen',
            dosage: '400mg',
            frequency: PrescriptionFrequency.threeTimesDaily,
            startDate: now.subtract(const Duration(days: 21)),
            endDate: now.subtract(const Duration(days: 7)),
            instructions: 'Take with meals to reduce gastric irritation',
          ),
        ],
        followUps: [
          FollowUp(
            scheduledDate: now.subtract(const Duration(days: 2)),
            purpose: 'Assess pain score and mobility',
            status: FollowUpStatus.completed,
          ),
          FollowUp(
            scheduledDate: now.add(const Duration(days: 14)),
            purpose: 'Evaluate therapy progression',
            status: FollowUpStatus.pending,
          ),
        ],
        recommendations: Recommendations(
          lifestyleChanges: [
            'Practice posture correction exercises daily',
            'Avoid lifting objects above 8kg for 6 weeks',
          ],
          referrals: [
            Referral(
              specialist: 'Physical Therapist',
              reason: 'Structured lower back strengthening program',
            ),
          ],
        ),
      ),
    ]);
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
