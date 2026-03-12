// Application routes
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Dashboard routes
  static const String adminDashboard = '/admin-dashboard';
  static const String clinicianDashboard = '/clinician-dashboard';
  static const String patientDashboard = '/patient-dashboard';

  // Clinician routes
  static const String clinicians = '/clinicians';
  static const String clinicianDetails = '/clinician-details';
  static const String addClinician = '/add-Clinician';

  // Patient routes
  static const String patients = '/patients';
  static const String patientDetails = '/patient-details';
  static const String addPatient = '/add-patient';

  // Appointments routes
  static const String appointments = '/appointments';
  static const String appointmentDetails = '/appointment-details';
  static const String bookAppointment = '/book-appointment';

  // Treatment routes
  static const String treatmentPlans = '/treatment-plans';
  static const String treatmentPlanDetails = '/treatment-plan-details';
  static const String createTreatmentPlan = '/create-treatment-plan';

  // Analytics routes
  static const String analytics = '/analytics';

  // Profile routes
  static const String profile = '/profile';
  static const String settings = '/settings';
}