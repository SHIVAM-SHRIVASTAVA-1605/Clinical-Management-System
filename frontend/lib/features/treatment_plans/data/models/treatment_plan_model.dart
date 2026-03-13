// Treatment Plan model following 1.3 backend schema
class TreatmentPlanModel {
  final String id;
  final String patientId;
  final String clinicianId;
  final Diagnosis diagnosis;
  final List<Prescription> prescriptions;
  final List<FollowUp> followUps;
  final Recommendations recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields (not persisted in backend schema)
  String? patientName;
  String? clinicianName;

  TreatmentPlanModel({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.diagnosis,
    required this.prescriptions,
    required this.followUps,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
    this.patientName,
    this.clinicianName,
  });

  factory TreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    return TreatmentPlanModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      clinicianId: json['clinicianId'] ?? '',
      diagnosis: Diagnosis.fromJson(json['diagnosis'] ?? {}),
      prescriptions: (json['prescriptions'] as List<dynamic>? ?? [])
          .map((p) => Prescription.fromJson(p as Map<String, dynamic>))
          .toList(),
      followUps: (json['followUps'] as List<dynamic>? ?? [])
          .map((f) => FollowUp.fromJson(f as Map<String, dynamic>))
          .toList(),
      recommendations: Recommendations.fromJson(json['recommendations'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      patientName: json['patientName'],
      clinicianName: json['clinicianName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'diagnosis': diagnosis.toJson(),
      'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
      'followUps': followUps.map((f) => f.toJson()).toList(),
      'recommendations': recommendations.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TreatmentPlanModel copyWith({
    String? id,
    String? patientId,
    String? clinicianId,
    Diagnosis? diagnosis,
    List<Prescription>? prescriptions,
    List<FollowUp>? followUps,
    Recommendations? recommendations,
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
      prescriptions: prescriptions ?? this.prescriptions,
      followUps: followUps ?? this.followUps,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientName: patientName ?? this.patientName,
      clinicianName: clinicianName ?? this.clinicianName,
    );
  }

  bool hasFollowUpStatus(String status) {
    return followUps.any((f) => f.status == status);
  }

  FollowUp? get nextPendingFollowUp {
    final now = DateTime.now();
    final pending = followUps
        .where((f) => f.status == FollowUpStatus.pending)
        .where((f) => !f.scheduledDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return pending.isEmpty ? null : pending.first;
  }

  String get formattedDiagnosedAt {
    final d = diagnosis.diagnosedAt;
    return '${d.day}/${d.month}/${d.year}';
  }
}

class Diagnosis {
  final String condition;
  final DateTime diagnosedAt;
  final String icd10Code;

  Diagnosis({
    required this.condition,
    required this.diagnosedAt,
    required this.icd10Code,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      condition: json['condition'] ?? '',
      diagnosedAt: json['diagnosedAt'] != null
          ? DateTime.parse(json['diagnosedAt'])
          : DateTime.now(),
      icd10Code: json['icd10Code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'diagnosedAt': diagnosedAt.toIso8601String(),
      'icd10Code': icd10Code,
    };
  }
}

class Prescription {
  final String medication;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;

  Prescription({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.instructions,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medication: json['medication'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      instructions: json['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medication': medication,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
    };
  }
}

class FollowUp {
  final DateTime scheduledDate;
  final String purpose;
  final String status;

  FollowUp({
    required this.scheduledDate,
    required this.purpose,
    required this.status,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : DateTime.now(),
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? FollowUpStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduledDate': scheduledDate.toIso8601String(),
      'purpose': purpose,
      'status': status,
    };
  }
}

class Recommendations {
  final List<String> lifestyleChanges;
  final List<Referral> referrals;

  Recommendations({
    required this.lifestyleChanges,
    required this.referrals,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      lifestyleChanges: (json['lifestyleChanges'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      referrals: (json['referrals'] as List<dynamic>? ?? [])
          .map((r) => Referral.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lifestyleChanges': lifestyleChanges,
      'referrals': referrals.map((r) => r.toJson()).toList(),
    };
  }
}

class Referral {
  final String specialist;
  final String reason;

  Referral({
    required this.specialist,
    required this.reason,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      specialist: json['specialist'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialist': specialist,
      'reason': reason,
    };
  }
}

class FollowUpStatus {
  static const String pending = 'Pending';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  static List<String> get all => [pending, completed, cancelled];
}

class PrescriptionFrequency {
  static const String onceDaily = 'Once daily';
  static const String twiceDaily = 'Twice daily';
  static const String threeTimesDaily = 'Three times daily';
  static const String fourTimesDaily = 'Four times daily';
  static const String asNeeded = 'As needed';
  static const String weekly = 'Weekly';

  static List<String> get all => [
        onceDaily,
        twiceDaily,
        threeTimesDaily,
        fourTimesDaily,
        asNeeded,
        weekly,
      ];
}
