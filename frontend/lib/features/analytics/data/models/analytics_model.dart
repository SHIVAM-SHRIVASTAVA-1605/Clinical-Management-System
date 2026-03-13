// ClinicalAnalytics Model - Main analytics record model
class ClinicalAnalyticsModel {
  final String id;
  final String metricType;
  final AnalyticsDataRecord data;
  final DateTime generatedAt;
  final DateTime updatedAt;

  ClinicalAnalyticsModel({
    required this.id,
    required this.metricType,
    required this.data,
    required this.generatedAt,
    required this.updatedAt,
  });

  factory ClinicalAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return ClinicalAnalyticsModel(
      id: json['id'] ?? json['_id'] ?? '',
      metricType: json['metricType'] ?? '',
      data: AnalyticsDataRecord.fromJson(json['data'] ?? {}),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricType': metricType,
      'data': data.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Analytics Data Record
class AnalyticsDataRecord {
  final TimeRange timeRange;
  final dynamic value; // Can be number, object, or structured data
  final AnalyticsFilters filters;

  AnalyticsDataRecord({
    required this.timeRange,
    required this.value,
    required this.filters,
  });

  factory AnalyticsDataRecord.fromJson(Map<String, dynamic> json) {
    return AnalyticsDataRecord(
      timeRange: TimeRange.fromJson(json['timeRange'] ?? {}),
      value: json['value'], // Dynamic - can be anything
      filters: AnalyticsFilters.fromJson(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeRange': timeRange.toJson(),
      'value': value,
      'filters': filters.toJson(),
    };
  }
}

// Time Range
class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({
    required this.start,
    required this.end,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: json['start'] != null
          ? DateTime.parse(json['start'])
          : DateTime.now(),
      end: json['end'] != null
          ? DateTime.parse(json['end'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  int get durationInDays => end.difference(start).inDays;
}

// Analytics Filters
class AnalyticsFilters {
  final String? clinicianId;
  final String? location;
  final String? patientAgeGroup;

  AnalyticsFilters({
    this.clinicianId,
    this.location,
    this.patientAgeGroup,
  });

  factory AnalyticsFilters.fromJson(Map<String, dynamic> json) {
    return AnalyticsFilters(
      clinicianId: json['clinicianId'],
      location: json['location'],
      patientAgeGroup: json['patientAgeGroup'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinicianId': clinicianId,
      'location': location,
      'patientAgeGroup': patientAgeGroup,
    };
  }

  bool get hasFilters =>
      clinicianId != null || location != null || patientAgeGroup != null;
}

// Metric Type Constants
class MetricType {
  static const String appointmentVolume = 'Appointment Volume';
  static const String treatmentOutcomes = 'Treatment Outcomes';
  static const String patientSatisfaction = 'Patient Satisfaction';
  static const String revenueAnalysis = 'Revenue Analysis';
  static const String clinicianPerformance = 'Clinician Performance';
  static const String patientDemographics = 'Patient Demographics';

  static List<String> get all => [
        appointmentVolume,
        treatmentOutcomes,
        patientSatisfaction,
        revenueAnalysis,
        clinicianPerformance,
        patientDemographics,
      ];
}

// Patient Age Group Constants
class PatientAgeGroup {
  static const String infant = '0-2';
  static const String child = '3-12';
  static const String teen = '13-18';
  static const String youngAdult = '19-30';
  static const String adult = '31-50';
  static const String middleAge = '51-65';
  static const String senior = '65+';

  static List<String> get all => [
        infant,
        child,
        teen,
        youngAdult,
        adult,
        middleAge,
        senior,
      ];
}

