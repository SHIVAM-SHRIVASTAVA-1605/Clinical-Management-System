import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';

// Treatment Plan service for API calls
// TODO: Implement actual API calls when backend is ready

class TreatmentPlanService {
  
  static final TreatmentPlanService _instance = TreatmentPlanService._internal();
  factory TreatmentPlanService() => _instance;
  TreatmentPlanService._internal();

  // Mock data storage
  final List<TreatmentPlanModel> _mockTreatmentPlans = [];

  // Initialize with mock data
  void _initMockData() {
    final now = DateTime.now();
    
    _mockTreatmentPlans.addAll([
      // Active treatment plan for John Smith
      _createMockTreatmentPlan(
        id: '1',
        patientId: '1',
        patientName: 'John Smith',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        diagnosis: 'Hypertension',
        status: TreatmentPlanStatus.active,
        startDate: now.subtract(const Duration(days: 7)),
        prescriptions: [
          Prescription(
            medicationName: 'Lisinopril',
            dosage: '10mg',
            frequency: PrescriptionFrequency.onceDailyl,
            duration: '30 days',
            instructions: 'Take in the morning with food',
          ),
          Prescription(
            medicationName: 'Aspirin',
            dosage: '81mg',
            frequency: PrescriptionFrequency.onceDailyl,
            duration: '30 days',
            instructions: 'Take with water',
          ),
        ],
        careInstructions: [
          CareInstruction(
            instruction: 'Low sodium diet (less than 2000mg per day)',
            category: CareCategory.diet,
            frequency: 'Daily',
          ),
          CareInstruction(
            instruction: 'Monitor blood pressure twice daily',
            category: CareCategory.monitoring,
            frequency: 'Twice daily',
          ),
          CareInstruction(
            instruction: '30 minutes of moderate exercise',
            category: CareCategory.exercise,
            frequency: '5 days per week',
          ),
        ],
        notes: 'Patient showing good response to treatment. Continue monitoring BP.',
      ),

      // Active treatment plan for Sarah Johnson
      _createMockTreatmentPlan(
        id: '2',
        patientId: '2',
        patientName: 'Sarah Johnson',
        clinicianId: '1',
        clinicianName: 'Dr. Emily Brown',
        diagnosis: 'Type 2 Diabetes',
        status: TreatmentPlanStatus.active,
        startDate: now.subtract(const Duration(days: 14)),
        prescriptions: [
          Prescription(
            medicationName: 'Metformin',
            dosage: '500mg',
            frequency: PrescriptionFrequency.twiceDaily,
            duration: '90 days',
            instructions: 'Take with meals',
          ),
        ],
        careInstructions: [
          CareInstruction(
            instruction: 'Carbohydrate counting - 45-60g per meal',
            category: CareCategory.diet,
            frequency: 'Daily',
          ),
          CareInstruction(
            instruction: 'Check blood sugar levels',
            category: CareCategory.monitoring,
            frequency: 'Twice daily (fasting & post-meal)',
          ),
          CareInstruction(
            instruction: 'Aerobic exercise for 30 minutes',
            category: CareCategory.exercise,
            frequency: 'Daily',
          ),
        ],
        notes: 'Patient adapting well to lifestyle changes. Blood sugar levels improving.',
      ),

      // Active treatment plan for Mike Wilson
      _createMockTreatmentPlan(
        id: '3',
        patientId: '3',
        patientName: 'Mike Wilson',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        diagnosis: 'Chronic Back Pain',
        status: TreatmentPlanStatus.active,
        startDate: now.subtract(const Duration(days: 21)),
        prescriptions: [
          Prescription(
            medicationName: 'Ibuprofen',
            dosage: '400mg',
            frequency: PrescriptionFrequency.threeTimes,
            duration: '14 days',
            instructions: 'Take with food',
          ),
          Prescription(
            medicationName: 'Cyclobenzaprine',
            dosage: '5mg',
            frequency: 'Once daily at bedtime',
            duration: '14 days',
            instructions: 'May cause drowsiness',
          ),
        ],
        careInstructions: [
          CareInstruction(
            instruction: 'Physical therapy exercises for lower back',
            category: CareCategory.exercise,
            frequency: 'Twice daily (morning & evening)',
          ),
          CareInstruction(
            instruction: 'Apply heat/ice therapy',
            category: CareCategory.lifestyle,
            frequency: 'As needed for pain relief',
          ),
          CareInstruction(
            instruction: 'Maintain proper posture while sitting',
            category: CareCategory.lifestyle,
            frequency: 'Continuously',
          ),
        ],
        notes: 'Patient scheduled for physical therapy sessions. Avoid heavy lifting.',
      ),

      // Completed treatment plan
      _createMockTreatmentPlan(
        id: '4',
        patientId: '4',
        patientName: 'Emma Davis',
        clinicianId: '3',
        clinicianName: 'Nurse Sarah Davis',
        diagnosis: 'Upper Respiratory Infection',
        status: TreatmentPlanStatus.completed,
        startDate: now.subtract(const Duration(days: 21)),
        endDate: now.subtract(const Duration(days: 7)),
        prescriptions: [
          Prescription(
            medicationName: 'Amoxicillin',
            dosage: '500mg',
            frequency: PrescriptionFrequency.threeTimes,
            duration: '10 days',
            instructions: 'Complete full course',
          ),
        ],
        careInstructions: [
          CareInstruction(
            instruction: 'Get plenty of rest',
            category: CareCategory.lifestyle,
            frequency: 'Daily',
          ),
          CareInstruction(
            instruction: 'Stay hydrated - drink 8 glasses of water',
            category: CareCategory.diet,
            frequency: 'Daily',
          ),
        ],
        notes: 'Treatment completed successfully. Patient fully recovered.',
      ),

      // On-Hold treatment plan
      _createMockTreatmentPlan(
        id: '5',
        patientId: '1',
        patientName: 'John Smith',
        clinicianId: '2',
        clinicianName: 'Dr. Michael Johnson',
        diagnosis: 'Anxiety Disorder',
        status: TreatmentPlanStatus.onHold,
        startDate: now.subtract(const Duration(days: 60)),
        prescriptions: [
          Prescription(
            medicationName: 'Sertraline',
            dosage: '50mg',
            frequency: PrescriptionFrequency.onceDailyl,
            duration: 'Ongoing',
            instructions: 'Take in the morning',
          ),
        ],
        careInstructions: [
          CareInstruction(
            instruction: 'Cognitive Behavioral Therapy sessions',
            category: CareCategory.followUp,
            frequency: 'Weekly',
          ),
          CareInstruction(
            instruction: 'Practice relaxation techniques',
            category: CareCategory.lifestyle,
            frequency: 'Daily',
          ),
        ],
        notes: 'Treatment on hold pending psychiatric evaluation.',
      ),
    ]);
  }

  // Get all treatment plans
  Future<List<TreatmentPlanModel>> getAllTreatmentPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    return _mockTreatmentPlans;
  }

  // Get treatment plan by ID
  Future<TreatmentPlanModel?> getTreatmentPlanById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    try {
      return _mockTreatmentPlans.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get treatment plans by patient ID
  Future<List<TreatmentPlanModel>> getTreatmentPlansByPatientId(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    return _mockTreatmentPlans.where((t) => t.patientId == patientId).toList();
  }

  // Get treatment plans by clinician ID
  Future<List<TreatmentPlanModel>> getTreatmentPlansByClinicianId(String clinicianId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    return _mockTreatmentPlans.where((t) => t.clinicianId == clinicianId).toList();
  }

  // Get active treatment plans
  Future<List<TreatmentPlanModel>> getActiveTreatmentPlans() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    return _mockTreatmentPlans.where((t) => t.isActive).toList();
  }

  // Get treatment plans by status
  Future<List<TreatmentPlanModel>> getTreatmentPlansByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_mockTreatmentPlans.isEmpty) {
      _initMockData();
    }
    
    return _mockTreatmentPlans.where((t) => t.status == status).toList();
  }

  // Add new treatment plan
  Future<Map<String, dynamic>> addTreatmentPlan(TreatmentPlanModel treatmentPlan) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    _mockTreatmentPlans.add(treatmentPlan);
    
    return {
      'success': true,
      'message': 'Treatment plan created successfully',
      'data': treatmentPlan.toJson(),
    };
  }

  // Update treatment plan
  Future<Map<String, dynamic>> updateTreatmentPlan(String id, TreatmentPlanModel treatmentPlan) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final index = _mockTreatmentPlans.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      _mockTreatmentPlans[index] = treatmentPlan;
      return {
        'success': true,
        'message': 'Treatment plan updated successfully',
        'data': treatmentPlan.toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Treatment plan not found',
    };
  }

  // Update treatment plan status
  Future<Map<String, dynamic>> updateTreatmentPlanStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockTreatmentPlans.indexWhere((t) => t.id == id);
    
    if (index != -1) {
      _mockTreatmentPlans[index] = _mockTreatmentPlans[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
        endDate: status == TreatmentPlanStatus.completed ? DateTime.now() : null,
      );
      return {
        'success': true,
        'message': 'Treatment plan status updated',
        'data': _mockTreatmentPlans[index].toJson(),
      };
    }
    
    return {
      'success': false,
      'message': 'Treatment plan not found',
    };
  }

  // Delete treatment plan
  Future<Map<String, dynamic>> deleteTreatmentPlan(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final initialLength = _mockTreatmentPlans.length;
    _mockTreatmentPlans.removeWhere((t) => t.id == id);
    final removed = initialLength != _mockTreatmentPlans.length;
    
    if (removed) {
      return {
        'success': true,
        'message': 'Treatment plan deleted successfully',
      };
    }
    
    return {
      'success': false,
      'message': 'Treatment plan not found',
    };
  }

  // Helper to create mock treatment plan
  TreatmentPlanModel _createMockTreatmentPlan({
    required String id,
    required String patientId,
    required String patientName,
    required String clinicianId,
    required String clinicianName,
    required String diagnosis,
    required String status,
    required DateTime startDate,
    DateTime? endDate,
    required List<Prescription> prescriptions,
    required List<CareInstruction> careInstructions,
    required String notes,
  }) {
    return TreatmentPlanModel(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      diagnosis: diagnosis,
      status: status,
      startDate: startDate,
      endDate: endDate,
      prescriptions: prescriptions,
      careInstructions: careInstructions,
      notes: notes,
      createdAt: startDate,
      updatedAt: DateTime.now(),
      patientName: patientName,
      clinicianName: clinicianName,
    );
  }
}