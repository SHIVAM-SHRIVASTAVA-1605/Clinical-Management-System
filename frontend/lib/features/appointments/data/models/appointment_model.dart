// Appointment model following backend schema
class AppointmentModel {
  final String id;
  final String patientId;
  final String clinicianId;
  final String appointmentType;
  final String status;
  final DateTime scheduledAt;
  final int duration;
  final String location;
  final String? notes;
  final BillingInfo? billing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated fields (not in DB, fetched separately)
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
    this.notes,
    this.billing,
    this.createdAt,
    this.updatedAt,
    this.patientName,
    this.clinicianName,
  });

  // From JSON
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      clinicianId: json['clinicianId'] ?? '',
      appointmentType: json['appointmentType'] ?? 'Consultation',
      status: json['status'] ?? 'Scheduled',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : DateTime.now(),
      duration: json['duration'] ?? 30,
      location: json['location'] ?? 'Main Clinic',
      notes: json['notes'],
      billing: json['billing'] != null ? BillingInfo.fromJson(json['billing']) : null,
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
      'appointmentType': appointmentType,
      'status': status,
      'scheduledAt': scheduledAt.toIso8601String(),
      'duration': duration,
      'location': location,
      'notes': notes,
      'billing': billing?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // End time calculation
  DateTime get endTime => scheduledAt.add(Duration(minutes: duration));

  // Format time helper
  String get formattedTime {
    final hour = scheduledAt.hour > 12 ? scheduledAt.hour - 12 : scheduledAt.hour;
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    final period = scheduledAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Format date helper
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}, ${scheduledAt.year}';
  }

  // Is today helper
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  // Is upcoming helper
  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());

  // Is past helper
  bool get isPast => scheduledAt.isBefore(DateTime.now());

  // Copy with method
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

// Billing Information
class BillingInfo {
  final double amount;
  final String status;
  final InsuranceDetails? insuranceDetails;

  BillingInfo({
    required this.amount,
    required this.status,
    this.insuranceDetails,
  });

  factory BillingInfo.fromJson(Map<String, dynamic> json) {
    return BillingInfo(
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      insuranceDetails: json['insuranceDetails'] != null
          ? InsuranceDetails.fromJson(json['insuranceDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status,
      'insuranceDetails': insuranceDetails?.toJson(),
    };
  }
}

// Insurance Details for Billing
class InsuranceDetails {
  final String? provider;
  final String? policyNumber;

  InsuranceDetails({
    this.provider,
    this.policyNumber,
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

// Appointment Type Constants
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

// Appointment Status Constants
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

// Appointment Location Constants
class AppointmentLocation {
  static const String mainClinic = 'Main Clinic';
  static const String downtownBranch = 'Downtown Branch';
  static const String telehealth = 'Telehealth';
  static const String homeVisit = 'Home Visit';

  static List<String> get all => [
        mainClinic,
        downtownBranch,
        telehealth,
        homeVisit,
      ];
}