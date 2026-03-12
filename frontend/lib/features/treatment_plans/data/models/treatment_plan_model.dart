// Treatment Plan model following backend schema
class TreatmentPlanModel {
  final String id;
  final String patientId;
  final String clinicianId;
  final String diagnosis;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final List<Prescription> prescriptions;
  final List<CareInstruction> careInstructions;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated fields (not in DB, fetched separately)
  String? patientName;
  String? clinicianName;

  TreatmentPlanModel({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.diagnosis,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.prescriptions,
    required this.careInstructions,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.patientName,
    this.clinicianName,
  });

  // From JSON
  factory TreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    return TreatmentPlanModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      clinicianId: json['clinicianId'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      status: json['status'] ?? 'Active',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      prescriptions: json['prescriptions'] != null
          ? (json['prescriptions'] as List)
              .map((p) => Prescription.fromJson(p))
              .toList()
          : [],
      careInstructions: json['careInstructions'] != null
          ? (json['careInstructions'] as List)
              .map((c) => CareInstruction.fromJson(c))
              .toList()
          : [],
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      patientName: json['patientName'],
      clinicianName: json['clinicianName'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'diagnosis': diagnosis,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
      'careInstructions': careInstructions.map((c) => c.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper getters
  bool get isActive => status == TreatmentPlanStatus.active;
  bool get isCompleted => status == TreatmentPlanStatus.completed;
  bool get isOnHold => status == TreatmentPlanStatus.onHold;

  int get durationInDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return 'Ongoing';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  // Copy with method
  TreatmentPlanModel copyWith({
    String? id,
    String? patientId,
    String? clinicianId,
    String? diagnosis,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    List<Prescription>? prescriptions,
    List<CareInstruction>? careInstructions,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? clinicianName,
  }) {
    return TreatmentPlanModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicianId: clinicianId ?? this.clinicianId,
      diagnosis: diagnosis ?? this.diagnosis,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescriptions: prescriptions ?? this.prescriptions,
      careInstructions: careInstructions ?? this.careInstructions,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientName: patientName ?? this.patientName,
      clinicianName: clinicianName ?? this.clinicianName,
    );
  }
}

// Prescription model
class Prescription {
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  Prescription({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}

// Care Instruction model
class CareInstruction {
  final String instruction;
  final String category;
  final String? frequency;

  CareInstruction({
    required this.instruction,
    required this.category,
    this.frequency,
  });

  factory CareInstruction.fromJson(Map<String, dynamic> json) {
    return CareInstruction(
      instruction: json['instruction'] ?? '',
      category: json['category'] ?? 'General',
      frequency: json['frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'category': category,
      'frequency': frequency,
    };
  }
}

// Treatment Plan Status Constants
class TreatmentPlanStatus {
  static const String active = 'Active';
  static const String completed = 'Completed';
  static const String onHold = 'On-Hold';
  static const String cancelled = 'Cancelled';

  static List<String> get all => [
        active,
        completed,
        onHold,
        cancelled,
      ];
}

// Prescription Frequency Constants
class PrescriptionFrequency {
  static const String onceDailyl = 'Once daily';
  static const String twiceDaily = 'Twice daily';
  static const String threeTimes = 'Three times daily';
  static const String fourTimes = 'Four times daily';
  static const String asNeeded = 'As needed';
  static const String weekly = 'Weekly';

  static List<String> get all => [
        onceDailyl,
        twiceDaily,
        threeTimes,
        fourTimes,
        asNeeded,
        weekly,
      ];
}

// Care Instruction Category Constants
class CareCategory {
  static const String diet = 'Diet';
  static const String exercise = 'Exercise';
  static const String lifestyle = 'Lifestyle';
  static const String monitoring = 'Monitoring';
  static const String medication = 'Medication';
  static const String followUp = 'Follow-up';

  static List<String> get all => [
        diet,
        exercise,
        lifestyle,
        monitoring,
        medication,
        followUp,
      ];
}