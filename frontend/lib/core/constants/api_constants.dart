class ApiConstants {
  // this url will be updated after backend is deployed
  static const String baseUrl = 'http://localhost:4000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Clinician endpoints
  static const String clinicians = '/clinicians';
  static String clinicianById(String id) => '/clinicians/$id';
  static String clinicianAvailability(String id) => '/clinicians/$id/availability';

  // Appointment endpoints
  static const String appointments = '/appointments';
  static String appointmentsByPatient(String id) => '/appointments/patient/$id';
  static String appointmentsByClinician(String id) => '/appointments/clinician/$id';
  static String appointmentStatus(String id) => '/appointments/$id/status';

  // Treatment plan endpoints
  static const String treatmentPlans = '/treatment-plans';
  static String treatmentPlansByPatient(String id) => '/treatment-plans/patient/$id';
  static String treatmentPlanById(String id) => '/treatment-plans/$id';

  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String analyticsExport = '/analytics/export';
}