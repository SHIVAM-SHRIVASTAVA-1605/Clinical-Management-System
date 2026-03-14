class ClinicalAnalyticsQuery {
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? clinicianId;
  final String? patientId;
  final String? appointmentType;
  final String? location;
  final String? billingStatus;

  const ClinicalAnalyticsQuery({
    this.startDate,
    this.endDate,
    this.status,
    this.clinicianId,
    this.patientId,
    this.appointmentType,
    this.location,
    this.billingStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null && startDate!.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate!.isNotEmpty) 'endDate': endDate,
      if (status != null && status!.isNotEmpty) 'status': status,
      if (clinicianId != null && clinicianId!.isNotEmpty)
        'clinicianId': clinicianId,
      if (patientId != null && patientId!.isNotEmpty) 'patientId': patientId,
      if (appointmentType != null && appointmentType!.isNotEmpty)
        'appointmentType': appointmentType,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (billingStatus != null && billingStatus!.isNotEmpty)
        'billingStatus': billingStatus,
    };
  }

  factory ClinicalAnalyticsQuery.fromJson(Map<String, dynamic> json) {
    return ClinicalAnalyticsQuery(
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      status: json['status']?.toString(),
      clinicianId: json['clinicianId']?.toString(),
      patientId: json['patientId']?.toString(),
      appointmentType: json['appointmentType']?.toString(),
      location: json['location']?.toString(),
      billingStatus: json['billingStatus']?.toString(),
    );
  }
}

class ClinicalAnalyticsSummary {
  final int totalAppointments;
  final int totalDurationMinutes;
  final double averageDurationMinutes;
  final double totalBillingAmount;
  final double averageBillingAmount;
  final int scheduledAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int paidAppointments;
  final int pendingAppointments;
  final int insuredAppointments;

  const ClinicalAnalyticsSummary({
    required this.totalAppointments,
    required this.totalDurationMinutes,
    required this.averageDurationMinutes,
    required this.totalBillingAmount,
    required this.averageBillingAmount,
    required this.scheduledAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.paidAppointments,
    required this.pendingAppointments,
    required this.insuredAppointments,
  });

  factory ClinicalAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
    double asDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return ClinicalAnalyticsSummary(
      totalAppointments: asInt(json['totalAppointments']),
      totalDurationMinutes: asInt(json['totalDurationMinutes']),
      averageDurationMinutes: asDouble(json['averageDurationMinutes']),
      totalBillingAmount: asDouble(json['totalBillingAmount']),
      averageBillingAmount: asDouble(json['averageBillingAmount']),
      scheduledAppointments: asInt(json['scheduledAppointments']),
      completedAppointments: asInt(json['completedAppointments']),
      cancelledAppointments: asInt(json['cancelledAppointments']),
      paidAppointments: asInt(json['paidAppointments']),
      pendingAppointments: asInt(json['pendingAppointments']),
      insuredAppointments: asInt(json['insuredAppointments']),
    );
  }
}

class AnalyticsBreakdownItem {
  final String label;
  final int count;

  const AnalyticsBreakdownItem({
    required this.label,
    required this.count,
  });

  factory AnalyticsBreakdownItem.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final count = rawCount is int ? rawCount : int.tryParse('$rawCount') ?? 0;

    return AnalyticsBreakdownItem(
      label: json['label']?.toString() ?? '',
      count: count,
    );
  }
}

class ClinicalAnalyticsBreakdowns {
  final List<AnalyticsBreakdownItem> byStatus;
  final List<AnalyticsBreakdownItem> byAppointmentType;
  final List<AnalyticsBreakdownItem> byLocation;
  final List<AnalyticsBreakdownItem> byBillingStatus;

  const ClinicalAnalyticsBreakdowns({
    required this.byStatus,
    required this.byAppointmentType,
    required this.byLocation,
    required this.byBillingStatus,
  });

  List<AnalyticsBreakdownItem> _asItems(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => AnalyticsBreakdownItem.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }
    return <AnalyticsBreakdownItem>[];
  }

  factory ClinicalAnalyticsBreakdowns.fromJson(Map<String, dynamic> json) {
    final helper = const ClinicalAnalyticsBreakdowns(
      byStatus: <AnalyticsBreakdownItem>[],
      byAppointmentType: <AnalyticsBreakdownItem>[],
      byLocation: <AnalyticsBreakdownItem>[],
      byBillingStatus: <AnalyticsBreakdownItem>[],
    );

    return ClinicalAnalyticsBreakdowns(
      byStatus: helper._asItems(json['byStatus']),
      byAppointmentType: helper._asItems(json['byAppointmentType']),
      byLocation: helper._asItems(json['byLocation']),
      byBillingStatus: helper._asItems(json['byBillingStatus']),
    );
  }
}

class AnalyticsAppointmentRow {
  final String id;
  final String patientName;
  final String clinicianName;
  final String appointmentType;
  final String status;
  final String scheduledAt;
  final int durationMinutes;
  final String location;
  final String notes;
  final double billingAmount;
  final String billingStatus;

  const AnalyticsAppointmentRow({
    required this.id,
    required this.patientName,
    required this.clinicianName,
    required this.appointmentType,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.location,
    required this.notes,
    required this.billingAmount,
    required this.billingStatus,
  });

  factory AnalyticsAppointmentRow.fromJson(Map<String, dynamic> json) {
    final patient = json['patientId'];
    final clinician = json['clinicianId'];
    final billing = json['billing'];

    String extractName(dynamic value) {
      if (value is Map<String, dynamic>) {
        final fullName = value['fullName']?.toString();
        if (fullName != null && fullName.trim().isNotEmpty) return fullName;
        final first = value['firstName']?.toString() ?? '';
        final last = value['lastName']?.toString() ?? '';
        final merged = '$first $last'.trim();
        if (merged.isNotEmpty) return merged;
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value?.toString() ?? '';
    }

    final durationRaw = json['duration'];
    final duration =
        durationRaw is int ? durationRaw : int.tryParse('$durationRaw') ?? 0;

    double asDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return AnalyticsAppointmentRow(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      patientName: extractName(patient),
      clinicianName: extractName(clinician),
      appointmentType: json['appointmentType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      durationMinutes: duration,
      location: json['location']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      billingAmount: billing is Map<String, dynamic>
          ? asDouble(billing['amount'])
          : 0,
      billingStatus: billing is Map<String, dynamic>
          ? billing['status']?.toString() ?? ''
          : '',
    );
  }
}

class ClinicalAnalyticsSnapshot {
  final String id;
  final String signature;
  final ClinicalAnalyticsQuery filters;
  final List<String> appointmentIds;
  final ClinicalAnalyticsSummary summary;
  final ClinicalAnalyticsBreakdowns breakdowns;
  final String generatedAt;
  final String createdAt;
  final String updatedAt;

  const ClinicalAnalyticsSnapshot({
    required this.id,
    required this.signature,
    required this.filters,
    required this.appointmentIds,
    required this.summary,
    required this.breakdowns,
    required this.generatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicalAnalyticsSnapshot.fromJson(Map<String, dynamic> json) {
    final ids = (json['appointmentIds'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return ClinicalAnalyticsSnapshot(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      signature: json['signature']?.toString() ?? '',
      filters: ClinicalAnalyticsQuery.fromJson(
        Map<String, dynamic>.from(json['filters'] ?? <String, dynamic>{}),
      ),
      appointmentIds: ids,
      summary: ClinicalAnalyticsSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] ?? <String, dynamic>{}),
      ),
      breakdowns: ClinicalAnalyticsBreakdowns.fromJson(
        Map<String, dynamic>.from(json['breakdowns'] ?? <String, dynamic>{}),
      ),
      generatedAt: json['generatedAt']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

class ClinicalAnalyticsModel {
  final ClinicalAnalyticsQuery filters;
  final ClinicalAnalyticsSummary summary;
  final ClinicalAnalyticsBreakdowns breakdowns;
  final List<AnalyticsAppointmentRow> appointments;
  final ClinicalAnalyticsSnapshot? snapshot;

  const ClinicalAnalyticsModel({
    required this.filters,
    required this.summary,
    required this.breakdowns,
    required this.appointments,
    required this.snapshot,
  });

  factory ClinicalAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final appointments = (json['appointments'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => AnalyticsAppointmentRow.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    final snapshotRaw = json['snapshot'];
    final snapshot = snapshotRaw is Map<String, dynamic>
        ? ClinicalAnalyticsSnapshot.fromJson(snapshotRaw)
        : null;

    return ClinicalAnalyticsModel(
      filters: ClinicalAnalyticsQuery.fromJson(
        Map<String, dynamic>.from(json['filters'] ?? <String, dynamic>{}),
      ),
      summary: ClinicalAnalyticsSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] ?? <String, dynamic>{}),
      ),
      breakdowns: ClinicalAnalyticsBreakdowns.fromJson(
        Map<String, dynamic>.from(json['breakdowns'] ?? <String, dynamic>{}),
      ),
      appointments: appointments,
      snapshot: snapshot,
    );
  }
}

class AnalyticsEnum {
  static const List<String> status = <String>[
    'Scheduled',
    'Completed',
    'Cancelled',
  ];

  static const List<String> appointmentType = <String>[
    'Consultation',
    'Follow-up',
    'Procedure',
  ];

  static const List<String> location = <String>[
    'Main Clinic',
    'Telehealth',
    'Branch Clinic',
  ];

  static const List<String> billingStatus = <String>[
    'Pending',
    'Paid',
    'Insured',
  ];
}
