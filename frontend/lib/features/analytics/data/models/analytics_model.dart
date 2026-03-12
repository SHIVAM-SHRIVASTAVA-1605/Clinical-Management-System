// Analytics Overview Model
class AnalyticsOverview {
  final int totalPatients;
  final int totalClinicians;
  final int totalAppointments;
  final int totalTreatmentPlans;
  final int activeAppointments;
  final int completedAppointments;
  final int activeTreatmentPlans;
  final double totalRevenue;
  final double monthlyRevenue;

  AnalyticsOverview({
    required this.totalPatients,
    required this.totalClinicians,
    required this.totalAppointments,
    required this.totalTreatmentPlans,
    required this.activeAppointments,
    required this.completedAppointments,
    required this.activeTreatmentPlans,
    required this.totalRevenue,
    required this.monthlyRevenue,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverview(
      totalPatients: json['totalPatients'] ?? 0,
      totalClinicians: json['totalClinicians'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      totalTreatmentPlans: json['totalTreatmentPlans'] ?? 0,
      activeAppointments: json['activeAppointments'] ?? 0,
      completedAppointments: json['completedAppointments'] ?? 0,
      activeTreatmentPlans: json['activeTreatmentPlans'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
    );
  }
}

// Appointment Statistics by Status
class AppointmentStatistics {
  final int scheduled;
  final int confirmed;
  final int completed;
  final int cancelled;
  final int noShow;

  AppointmentStatistics({
    required this.scheduled,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.noShow,
  });

  int get total => scheduled + confirmed + completed + cancelled + noShow;

  double getPercentage(int value) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  factory AppointmentStatistics.fromJson(Map<String, dynamic> json) {
    return AppointmentStatistics(
      scheduled: json['scheduled'] ?? 0,
      confirmed: json['confirmed'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      noShow: json['noShow'] ?? 0,
    );
  }
}

// Treatment Plan Statistics by Status
class TreatmentPlanStatistics {
  final int active;
  final int completed;
  final int onHold;
  final int cancelled;

  TreatmentPlanStatistics({
    required this.active,
    required this.completed,
    required this.onHold,
    required this.cancelled,
  });

  int get total => active + completed + onHold + cancelled;

  double getPercentage(int value) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  factory TreatmentPlanStatistics.fromJson(Map<String, dynamic> json) {
    return TreatmentPlanStatistics(
      active: json['active'] ?? 0,
      completed: json['completed'] ?? 0,
      onHold: json['onHold'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

// Patient Demographics
class PatientDemographics {
  final int male;
  final int female;
  final int other;
  final Map<String, int> ageGroups;

  PatientDemographics({
    required this.male,
    required this.female,
    required this.other,
    required this.ageGroups,
  });

  int get total => male + female + other;

  double getGenderPercentage(int value) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  factory PatientDemographics.fromJson(Map<String, dynamic> json) {
    return PatientDemographics(
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      other: json['other'] ?? 0,
      ageGroups: Map<String, int>.from(json['ageGroups'] ?? {}),
    );
  }
}

// Top Diagnosis
class TopDiagnosis {
  final String diagnosis;
  final int count;

  TopDiagnosis({
    required this.diagnosis,
    required this.count,
  });

  factory TopDiagnosis.fromJson(Map<String, dynamic> json) {
    return TopDiagnosis(
      diagnosis: json['diagnosis'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

// Revenue by Month
class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

// Appointments Over Time
class AppointmentTrend {
  final String date;
  final int count;

  AppointmentTrend({
    required this.date,
    required this.count,
  });

  factory AppointmentTrend.fromJson(Map<String, dynamic> json) {
    return AppointmentTrend(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

// Complete Analytics Data
class AnalyticsData {
  final AnalyticsOverview overview;
  final AppointmentStatistics appointmentStats;
  final TreatmentPlanStatistics treatmentPlanStats;
  final PatientDemographics demographics;
  final List<TopDiagnosis> topDiagnoses;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<AppointmentTrend> appointmentTrends;

  AnalyticsData({
    required this.overview,
    required this.appointmentStats,
    required this.treatmentPlanStats,
    required this.demographics,
    required this.topDiagnoses,
    required this.monthlyRevenue,
    required this.appointmentTrends,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      overview: AnalyticsOverview.fromJson(json['overview'] ?? {}),
      appointmentStats: AppointmentStatistics.fromJson(json['appointmentStats'] ?? {}),
      treatmentPlanStats: TreatmentPlanStatistics.fromJson(json['treatmentPlanStats'] ?? {}),
      demographics: PatientDemographics.fromJson(json['demographics'] ?? {}),
      topDiagnoses: (json['topDiagnoses'] as List?)
              ?.map((item) => TopDiagnosis.fromJson(item))
              .toList() ??
          [],
      monthlyRevenue: (json['monthlyRevenue'] as List?)
              ?.map((item) => MonthlyRevenue.fromJson(item))
              .toList() ??
          [],
      appointmentTrends: (json['appointmentTrends'] as List?)
              ?.map((item) => AppointmentTrend.fromJson(item))
              .toList() ??
          [],
    );
  }
}