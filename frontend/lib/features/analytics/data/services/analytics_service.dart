import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/data/services/appointment_service.dart';
import 'package:frontend/features/clinicians/data/services/clinician_service.dart';
import 'package:frontend/features/patients/data/services/patient_service.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/data/services/treatment_plan_service.dart';

// Analytics service for aggregating data from other services
class AnalyticsService {
  
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final PatientService _patientService = PatientService();
  final ClinicianService _clinicianService = ClinicianService();
  final AppointmentService _appointmentService = AppointmentService();
  final TreatmentPlanService _treatmentPlanService = TreatmentPlanService();

  // Get complete analytics data
  Future<AnalyticsData> getAnalyticsData() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Fetch all data
    final patients = await _patientService.getAllPatients();
    final clinicians = await _clinicianService.getAllClinicians();
    final appointments = await _appointmentService.getAllAppointments();
    final treatmentPlans = await _treatmentPlanService.getAllTreatmentPlans();

    // Calculate overview
    final overview = _calculateOverview(
      patients.length,
      clinicians.length,
      appointments,
      treatmentPlans,
    );

    // Calculate appointment statistics
    final appointmentStats = _calculateAppointmentStatistics(appointments);

    // Calculate treatment plan statistics
    final treatmentPlanStats = _calculateTreatmentPlanStatistics(treatmentPlans);

    // Calculate demographics
    final demographics = _calculateDemographics(patients);

    // Get top diagnoses
    final topDiagnoses = _getTopDiagnoses(treatmentPlans);

    // Calculate monthly revenue
    final monthlyRevenue = _calculateMonthlyRevenue(appointments);

    // Get appointment trends
    final appointmentTrends = _getAppointmentTrends(appointments);

    return AnalyticsData(
      overview: overview,
      appointmentStats: appointmentStats,
      treatmentPlanStats: treatmentPlanStats,
      demographics: demographics,
      topDiagnoses: topDiagnoses,
      monthlyRevenue: monthlyRevenue,
      appointmentTrends: appointmentTrends,
    );
  }

  // Calculate overview statistics
  AnalyticsOverview _calculateOverview(
    int totalPatients,
    int totalClinicians,
    List<dynamic> appointments,
    List<dynamic> treatmentPlans,
  ) {
    final activeAppointments = appointments
        .where((a) => a.status == AppointmentStatus.scheduled || 
                     a.status == AppointmentStatus.confirmed)
        .length;

    final completedAppointments = appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .length;

    final activeTreatmentPlans = treatmentPlans
        .where((t) => t.status == TreatmentPlanStatus.active)
        .length;

    // Calculate total revenue
    double totalRevenue = 0;
    double monthlyRevenue = 0;
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (var appointment in appointments) {
      if (appointment.status == AppointmentStatus.completed) {
        totalRevenue += appointment.billing.amount;
        
        if (appointment.scheduledAt.month == currentMonth &&
            appointment.scheduledAt.year == currentYear) {
          monthlyRevenue += appointment.billing.amount;
        }
      }
    }

    return AnalyticsOverview(
      totalPatients: totalPatients,
      totalClinicians: totalClinicians,
      totalAppointments: appointments.length,
      totalTreatmentPlans: treatmentPlans.length,
      activeAppointments: activeAppointments,
      completedAppointments: completedAppointments,
      activeTreatmentPlans: activeTreatmentPlans,
      totalRevenue: totalRevenue,
      monthlyRevenue: monthlyRevenue,
    );
  }

  // Calculate appointment statistics by status
  AppointmentStatistics _calculateAppointmentStatistics(List<dynamic> appointments) {
    int scheduled = 0;
    int confirmed = 0;
    int completed = 0;
    int cancelled = 0;
    int noShow = 0;

    for (var appointment in appointments) {
      switch (appointment.status) {
        case AppointmentStatus.scheduled:
          scheduled++;
          break;
        case AppointmentStatus.confirmed:
          confirmed++;
          break;
        case AppointmentStatus.completed:
          completed++;
          break;
        case AppointmentStatus.cancelled:
          cancelled++;
          break;
        case AppointmentStatus.noShow:
          noShow++;
          break;
      }
    }

    return AppointmentStatistics(
      scheduled: scheduled,
      confirmed: confirmed,
      completed: completed,
      cancelled: cancelled,
      noShow: noShow,
    );
  }

  // Calculate treatment plan statistics by status
  TreatmentPlanStatistics _calculateTreatmentPlanStatistics(List<dynamic> treatmentPlans) {
    int active = 0;
    int completed = 0;
    int onHold = 0;
    int cancelled = 0;

    for (var plan in treatmentPlans) {
      switch (plan.status) {
        case TreatmentPlanStatus.active:
          active++;
          break;
        case TreatmentPlanStatus.completed:
          completed++;
          break;
        case TreatmentPlanStatus.onHold:
          onHold++;
          break;
        case TreatmentPlanStatus.cancelled:
          cancelled++;
          break;
      }
    }

    return TreatmentPlanStatistics(
      active: active,
      completed: completed,
      onHold: onHold,
      cancelled: cancelled,
    );
  }

  // Calculate patient demographics
  PatientDemographics _calculateDemographics(List<dynamic> patients) {
    // Mock data since PatientModel structure varies
    int male = 0;
    int female = 0;
    int other = 0;
    
    Map<String, int> ageGroups = {
      '0-18': 0,
      '19-35': 0,
      '36-50': 0,
      '51-65': 0,
      '65+': 0,
    };

    final total = patients.length;

    // Generate mock gender distribution
    male = (total * 0.45).round(); 
    female = (total * 0.50).round();
    other = total - male - female;

    // Generate mock age distribution
    if (total > 0) {
      ageGroups['0-18'] = (total * 0.10).round();
      ageGroups['19-35'] = (total * 0.30).round();
      ageGroups['36-50'] = (total * 0.25).round();
      ageGroups['51-65'] = (total * 0.20).round();
      ageGroups['65+'] = total - (ageGroups['0-18']! + ageGroups['19-35']! + 
                                  ageGroups['36-50']! + ageGroups['51-65']!);
    }

    return PatientDemographics(
      male: male,
      female: female,
      other: other,
      ageGroups: ageGroups,
    );
  }
  // Get top diagnoses from treatment plans
  List<TopDiagnosis> _getTopDiagnoses(List<dynamic> treatmentPlans) {
    Map<String, int> diagnosisCount = {};

    for (var plan in treatmentPlans) {
      final diagnosis = plan.diagnosis;
      diagnosisCount[diagnosis] = (diagnosisCount[diagnosis] ?? 0) + 1;
    }

    // Convert to list and sort by count
    final topDiagnoses = diagnosisCount.entries
        .map((entry) => TopDiagnosis(
              diagnosis: entry.key,
              count: entry.value,
            ))
        .toList();

    topDiagnoses.sort((a, b) => b.count.compareTo(a.count));

    // Return top 5
    return topDiagnoses.take(5).toList();
  }

  // Calculate monthly revenue for last 6 months
  List<MonthlyRevenue> _calculateMonthlyRevenue(List<dynamic> appointments) {
    final now = DateTime.now();
    Map<String, double> monthlyData = {};

    // Initialize last 6 months
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${_getMonthName(date.month)} ${date.year}';
      monthlyData[monthKey] = 0;
    }

    // Calculate revenue for completed appointments
    for (var appointment in appointments) {
      if (appointment.status == AppointmentStatus.completed) {
        final date = appointment.scheduledAt;
        final monthKey = '${_getMonthName(date.month)} ${date.year}';
        
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + appointment.billing.amount;
        }
      }
    }

    return monthlyData.entries
        .map((entry) => MonthlyRevenue(
              month: entry.key,
              revenue: entry.value,
            ))
        .toList();
  }

  // Get appointment trends for last 7 days
  List<AppointmentTrend> _getAppointmentTrends(List<dynamic> appointments) {
    final now = DateTime.now();
    Map<String, int> dailyData = {};

    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';
      dailyData[dateKey] = 0;
    }

    // Count appointments per day
    for (var appointment in appointments) {
      final date = appointment.scheduledAt;
      final dateKey = '${date.day}/${date.month}';
      
      if (dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = (dailyData[dateKey] ?? 0) + 1;
      }
    }

    return dailyData.entries
        .map((entry) => AppointmentTrend(
              date: entry.key,
              count: entry.value,
            ))
        .toList();
  }

  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get analytics by date range
  Future<AnalyticsData> getAnalyticsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // For now, return all data (can be filtered later)
    return await getAnalyticsData();
  }

  // Get department-specific analytics
  Future<AnalyticsData> getAnalyticsByDepartment(String department) async {
    // For now, return all data (can be filtered later)
    return await getAnalyticsData();
  }
}