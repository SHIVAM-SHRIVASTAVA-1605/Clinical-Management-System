import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

// Analytics service for ClinicalAnalytics records and data aggregation
class AnalyticsService {
  
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Mock storage for clinical analytics records
  final List<ClinicalAnalyticsModel> _mockAnalyticsRecords = [];

  // Get analytics with customizable filters
  Future<List<ClinicalAnalyticsModel>> getAnalytics({
    String? metricType,
    String? clinicianId,
    String? location,
    String? patientAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final endpoint = ApiConstants.analytics;
    // TODO: Replace mock flow with GET endpoint call
    await Future.delayed(const Duration(milliseconds: 500));

    // Initialize mock data if empty
    if (_mockAnalyticsRecords.isEmpty) {
      await _initializeMockAnalyticsRecords();
    }

    // Filter records based on criteria
    var filtered = _mockAnalyticsRecords.where((record) {
      // Filter by metric type
      if (metricType != null && record.metricType != metricType) {
        return false;
      }

      // Filter by clinician ID
      if (clinicianId != null && 
          record.data.filters.clinicianId != null &&
          record.data.filters.clinicianId != clinicianId) {
        return false;
      }

      // Filter by location
      if (location != null && 
          record.data.filters.location != null &&
          record.data.filters.location != location) {
        return false;
      }

      // Filter by age group
      if (patientAgeGroup != null && 
          record.data.filters.patientAgeGroup != null &&
          record.data.filters.patientAgeGroup != patientAgeGroup) {
        return false;
      }

      // Filter by date range
      if (startDate != null && record.data.timeRange.start.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && record.data.timeRange.end.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();

    if (endpoint.isEmpty) return <ClinicalAnalyticsModel>[];
    return filtered;
  }

  // Create a new clinical analytics record
  Future<ClinicalAnalyticsModel> createAnalyticsRecord({
    required String metricType,
    required TimeRange timeRange,
    required dynamic value,
    AnalyticsFilters? filters,
  }) async {
    // TODO: Replace with actual API call when backend is ready
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final record = ClinicalAnalyticsModel(
      id: 'analytics_${now.millisecondsSinceEpoch}',
      metricType: metricType,
      data: AnalyticsDataRecord(
        timeRange: timeRange,
        value: value,
        filters: filters ?? AnalyticsFilters(),
      ),
      generatedAt: now,
      updatedAt: now,
    );

    _mockAnalyticsRecords.add(record);
    return record;
  }

  // Update an existing analytics record
  Future<bool> updateAnalyticsRecord(
    String id,
    dynamic newValue,
  ) async {
    // TODO: Replace with actual API call when backend is ready
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockAnalyticsRecords.indexWhere((r) => r.id == id);
    if (index != -1) {
      final oldRecord = _mockAnalyticsRecords[index];
      _mockAnalyticsRecords[index] = ClinicalAnalyticsModel(
        id: oldRecord.id,
        metricType: oldRecord.metricType,
        data: AnalyticsDataRecord(
          timeRange: oldRecord.data.timeRange,
          value: newValue,
          filters: oldRecord.data.filters,
        ),
        generatedAt: oldRecord.generatedAt,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  // Export analytics data as CSV
  Future<String> exportAnalyticsAsCSV({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    final endpoint = ApiConstants.analyticsExport;
    // TODO: Implement POST endpoint call with format=csv
    await Future.delayed(const Duration(milliseconds: 500));

    final records = await getAnalytics(
      metricType: metricType,
      clinicianId: filters?.clinicianId,
      location: filters?.location,
      patientAgeGroup: filters?.patientAgeGroup,
    );

    // Mock CSV generation
    StringBuffer csv = StringBuffer();
    csv.writeln('ID,Metric Type,Start Date,End Date,Value,Clinician ID,Location,Age Group,Generated At');

    for (var record in records) {
      csv.writeln(
        '${record.id},'
        '${record.metricType},'
        '${record.data.timeRange.start.toIso8601String()},'
        '${record.data.timeRange.end.toIso8601String()},'
        '${record.data.value},'
        '${record.data.filters.clinicianId ?? ""},'
        '${record.data.filters.location ?? ""},'
        '${record.data.filters.patientAgeGroup ?? ""},'
        '${record.generatedAt.toIso8601String()}'
      );
    }

    return '${csv.toString()}\n# endpoint: $endpoint';
  }

  // Export analytics as CSV bytes for file download
  Future<Uint8List> exportAnalyticsAsCSVBytes({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    final csv = await exportAnalyticsAsCSV(
      metricType: metricType,
      filters: filters,
    );
    return Uint8List.fromList(csv.codeUnits);
  }

  // Export analytics data as PDF (mock - returns path/URL)
  Future<String> exportAnalyticsAsPDF({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    final endpoint = ApiConstants.analyticsExport;
    // TODO: Implement POST endpoint call with format=pdf
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock PDF generation - return a mock file path
    return '/exports/analytics_${DateTime.now().millisecondsSinceEpoch}.pdf?source=$endpoint';
  }

  // Export analytics as PDF bytes for file download
  Future<Uint8List> exportAnalyticsAsPDFBytes({
    String? metricType,
    AnalyticsFilters? filters,
  }) async {
    final records = await getAnalytics(
      metricType: metricType,
      clinicianId: filters?.clinicianId,
      location: filters?.location,
      patientAgeGroup: filters?.patientAgeGroup,
    );

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Clinical Analytics Export')),
          pw.Paragraph(text: 'Generated at: ${DateTime.now().toIso8601String()}'),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: const [
              'Metric Type',
              'Start',
              'End',
              'Value',
              'Clinician ID',
              'Location',
              'Age Group',
            ],
            data: records.map((record) {
              return [
                record.metricType,
                record.data.timeRange.start.toIso8601String(),
                record.data.timeRange.end.toIso8601String(),
                record.data.value.toString(),
                record.data.filters.clinicianId ?? '',
                record.data.filters.location ?? '',
                record.data.filters.patientAgeGroup ?? '',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // Endpoint-aligned alias: GET /analytics
  Future<List<ClinicalAnalyticsModel>> fetchAnalytics({
    String? metricType,
    String? clinicianId,
    String? location,
    String? patientAgeGroup,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return getAnalytics(
      metricType: metricType,
      clinicianId: clinicianId,
      location: location,
      patientAgeGroup: patientAgeGroup,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Endpoint-aligned alias: POST /analytics/export
  Future<String> exportAnalytics({
    required String format,
    String? metricType,
    AnalyticsFilters? filters,
  }) {
    if (format.toLowerCase() == 'pdf') {
      return exportAnalyticsAsPDF(metricType: metricType, filters: filters);
    }
    return exportAnalyticsAsCSV(metricType: metricType, filters: filters);
  }

  // Initialize mock analytics records
  Future<void> _initializeMockAnalyticsRecords() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);

    _mockAnalyticsRecords.addAll([
      // Appointment Volume
      ClinicalAnalyticsModel(
        id: 'analytics_1',
        metricType: MetricType.appointmentVolume,
        data: AnalyticsDataRecord(
          timeRange: TimeRange(start: lastMonth, end: lastMonthEnd),
          value: 245, // Total appointments
          filters: AnalyticsFilters(),
        ),
        generatedAt: now,
        updatedAt: now,
      ),

      // Treatment Outcomes
      ClinicalAnalyticsModel(
        id: 'analytics_2',
        metricType: MetricType.treatmentOutcomes,
        data: AnalyticsDataRecord(
          timeRange: TimeRange(start: lastMonth, end: lastMonthEnd),
          value: {
            'successful': 180,
            'ongoing': 45,
            'unsuccessful': 12,
          },
          filters: AnalyticsFilters(),
        ),
        generatedAt: now,
        updatedAt: now,
      ),

      // Revenue Analysis by location
      ClinicalAnalyticsModel(
        id: 'analytics_3',
        metricType: MetricType.revenueAnalysis,
        data: AnalyticsDataRecord(
          timeRange: TimeRange(start: lastMonth, end: lastMonthEnd),
          value: 125450.75,
          filters: AnalyticsFilters(location: 'Main Clinic'),
        ),
        generatedAt: now,
        updatedAt: now,
      ),

      // Patient Demographics by age group
      ClinicalAnalyticsModel(
        id: 'analytics_4',
        metricType: MetricType.patientDemographics,
        data: AnalyticsDataRecord(
          timeRange: TimeRange(start: lastMonth, end: lastMonthEnd),
          value: 85, // Patients in age group
          filters: AnalyticsFilters(patientAgeGroup: PatientAgeGroup.adult),
        ),
        generatedAt: now,
        updatedAt: now,
      ),

      // Clinician Performance
      ClinicalAnalyticsModel(
        id: 'analytics_5',
        metricType: MetricType.clinicianPerformance,
        data: AnalyticsDataRecord(
          timeRange: TimeRange(start: lastMonth, end: lastMonthEnd),
          value: {
            'appointments_completed': 65,
            'patient_satisfaction': 4.7,
            'treatment_success_rate': 92.5,
          },
          filters: AnalyticsFilters(clinicianId: '1'),
        ),
        generatedAt: now,
        updatedAt: now,
      ),
    ]);
  }
}