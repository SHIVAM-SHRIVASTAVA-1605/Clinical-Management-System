// Appointment model following 1.2 backend schema
class AppointmentModel {
  final String id;
  final String patientId;
  final String clinicianId;
  final String appointmentType;
  final String status;
  final DateTime scheduledAt;
  final int duration;
  final String location;
  final String notes;
  final BillingInfo billing;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields (not persisted in backend schema)
  String? patientName;
  String? clinicianName;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.appointmentType,
    required this.status,
    required this.scheduledAt,
    required this.duration,
    required this.location,
    required this.notes,
    required this.billing,
    required this.createdAt,
    required this.updatedAt,
    this.patientName,
    this.clinicianName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final rawPatient = json['patientId'] ?? json['patient'];
    final rawClinician = json['clinicianId'] ?? json['clinician'];

    String parseId(dynamic value) {
      if (value is Map<String, dynamic>) {
        return (value['id'] ?? value['_id'] ?? '').toString();
      }
      return (value ?? '').toString();
    }

    return AppointmentModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: parseId(rawPatient),
      clinicianId: parseId(rawClinician),
      appointmentType: json['appointmentType'] ?? AppointmentType.consultation,
      status: json['status'] ?? AppointmentStatus.scheduled,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : DateTime.now(),
      duration: json['duration'] ?? 30,
      location: json['location'] ?? AppointmentLocation.mainClinic,
      notes: json['notes']?.toString() ?? '',
      billing: json['billing'] != null
          ? BillingInfo.fromJson(json['billing'])
          : BillingInfo.defaultPending(),
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
      'appointmentType': appointmentType,
      'status': status,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration,
      'location': location,
      'notes': notes,
      'billing': billing.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

  String get formattedTime {
    final hour =
        scheduledAt.hour > 12 ? scheduledAt.hour - 12 : scheduledAt.hour;
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final period = scheduledAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}, ${scheduledAt.year}';
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());

  bool get isPast => scheduledAt.isBefore(DateTime.now());

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? clinicianId,
    String? appointmentType,
    String? status,
    DateTime? scheduledAt,
    int? duration,
    String? location,
    String? notes,
    BillingInfo? billing,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? clinicianName,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      clinicianId: clinicianId ?? this.clinicianId,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      billing: billing ?? this.billing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientName: patientName ?? this.patientName,
      clinicianName: clinicianName ?? this.clinicianName,
    );
  }
}

class BillingInfo {
  final double amount;
  final String status;
  final InsuranceDetails insuranceDetails;

  const BillingInfo({
    required this.amount,
    required this.status,
    required this.insuranceDetails,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final parsedAmount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse('$rawAmount') ?? 0;

    return BillingInfo(
      amount: parsedAmount,
      status: json['status'] ?? BillingStatus.pending,
      insuranceDetails: json['insuranceDetails'] != null
          ? InsuranceDetails.fromJson(json['insuranceDetails'])
          : const InsuranceDetails(provider: null, policyNumber: null),
    );
  }

  factory BillingInfo.defaultPending() {
    return const BillingInfo(
      amount: 0,
      status: BillingStatus.pending,
      insuranceDetails: InsuranceDetails(provider: null, policyNumber: null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status,
      'insuranceDetails': insuranceDetails.toJson(),
    };
  }
}

class InsuranceDetails {
  final String? provider;
  final String? policyNumber;

  const InsuranceDetails({
    required this.provider,
    required this.policyNumber,
  });

  factory InsuranceDetails.fromJson(Map<String, dynamic> json) {
    return InsuranceDetails(
      provider: json['provider'],
      policyNumber: json['policyNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'policyNumber': policyNumber,
    };
  }
}

class AppointmentType {
  static const String consultation = 'Consultation';
  static const String followUp = 'Follow-up';
  static const String procedure = 'Procedure';
  static const String checkup = 'Check-up';
  static const String emergency = 'Emergency';

  static List<String> get all => [
        consultation,
        followUp,
        procedure,
        checkup,
        emergency,
      ];
}

class AppointmentStatus {
  static const String scheduled = 'Scheduled';
  static const String confirmed = 'Confirmed';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String noShow = 'No-Show';

  static List<String> get all => [
        scheduled,
        confirmed,
        completed,
        cancelled,
        noShow,
      ];
}

class BillingStatus {
  static const String pending = 'Pending';
  static const String paid = 'Paid';
  static const String insured = 'Insured';

  static List<String> get all => [pending, paid, insured];
}

class AppointmentLocation {
  static const String mainClinic = 'Main Clinic';
  static const String branchClinic = 'Branch Clinic';
  static const String telehealth = 'Telehealth';

  static List<String> get all => [
        mainClinic,
        branchClinic,
        telehealth,
      ];
}
