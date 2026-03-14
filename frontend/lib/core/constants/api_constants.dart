class ApiConstants {
  static const String baseUrl = 'http://localhost:5000';
  static const String authBaseUrl = 'http://localhost:5000';

  // Auth endpoints
  static const String login = '/auth/clinician/login';
  static const String register = '/auth/clinician/signup';

  // Clinician endpoints
  static const String clinicians = '/api/clinicians';
  static String clinicianById(String id) => '/api/clinicians/$id';
  static String clinicianAvailability(String id) =>
      '/api/clinicians/$id/availability';

  // Appointment endpoints
  static const String appointments = '/api/appointments';
  static String appointmentById(String id) => '/api/appointments/$id';
  static String appointmentStatus(String id) => '/api/appointments/$id/status';

  // Treatment plan endpoints
  static const String treatmentPlans = '/treatment-plans';
  static String treatmentPlansByPatient(String id) => '/treatment-plans/patient/$id';
  static String treatmentPlanById(String id) => '/treatment-plans/$id';

  // Patient endpoints
  static const String patients = '/patients';
  static String patientById(String id) => '/patients/$id';

  // Analytics endpoints
  static const String analytics = '/api/analytics';
  static const String analyticsExport = '/api/analytics/export';
}