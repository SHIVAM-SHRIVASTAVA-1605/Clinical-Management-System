import 'package:flutter/material.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:frontend/features/appointments/presentations/screens/appointment_details_screen.dart';
import 'package:frontend/features/appointments/presentations/screens/appointments_list_screen.dart';
import 'package:frontend/features/appointments/presentations/screens/book_appointment_screen.dart';
import 'package:frontend/features/auth/presentations/screens/login_screen.dart';
import 'package:frontend/features/auth/presentations/screens/register_screen.dart';
import 'package:frontend/features/clinicians/presentation/screens/clinician_details_screen.dart';
import 'package:frontend/features/clinicians/presentation/screens/clinicians_list_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/clinician_dashboard_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:frontend/features/treatment_plans/presentations/screens/create_treatment_plan_screen.dart';
import 'package:frontend/features/treatment_plans/presentations/screens/treatment_plan_details_screen.dart';
import 'package:frontend/features/treatment_plans/presentations/screens/treatment_plans_list_screen.dart';
import 'app_routes.dart';

/// Centralized route management
class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // Dashboard routes
      case AppRoutes.clinicianDashboard:
        return MaterialPageRoute(
            builder: (_) => const ClinicianDashboardScreen());

      case AppRoutes.clinicians:
        return MaterialPageRoute(builder: (_) => const CliniciansListScreen());

      case AppRoutes.clinicianDetails:
        final clinicianId = settings.arguments as String?;
        if (clinicianId == null) {
          return MaterialPageRoute(builder: (_) => const _NotFoundScreen());
        }
        return MaterialPageRoute(
          builder: (_) => ClinicianDetailsScreen(clinicianId: clinicianId),
        );

      case AppRoutes.appointments:
        return MaterialPageRoute(
            builder: (_) => const AppointmentsListScreen());

      case AppRoutes.appointmentDetails:
        final appointmentId = settings.arguments as String?;
        if (appointmentId == null) {
          return MaterialPageRoute(builder: (_) => const _NotFoundScreen());
        }
        return MaterialPageRoute(
          builder: (_) =>
              AppointmentDetailsScreen(appointmentId: appointmentId),
        );

      case AppRoutes.bookAppointment:
        return MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(),
        );

      case AppRoutes.treatmentPlans:
        return MaterialPageRoute(
            builder: (_) => const TreatmentPlansListScreen());

      case AppRoutes.treatmentPlanDetails:
        final planId = settings.arguments as String?;
        if (planId == null) {
          return MaterialPageRoute(builder: (_) => const _NotFoundScreen());
        }
        return MaterialPageRoute(
          builder: (_) => TreatmentPlanDetailsScreen(planId: planId),
        );

      case AppRoutes.createTreatmentPlan:
        return MaterialPageRoute(
          builder: (_) => const CreateTreatmentPlanScreen(),
        );

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardScreen(),
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _NotFoundScreen(),
        );
    }
  }
}

/// Placeholder screen for routes under development
class _ComingSoonScreen extends StatelessWidget {
  final String routeName;

  const _ComingSoonScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle(routeName)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is under development',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle(String route) {
    switch (route) {
      case AppRoutes.clinicians:
        return 'Clinicians';
      case AppRoutes.appointments:
        return 'Appointments';
      case AppRoutes.treatmentPlans:
        return 'Treatment Plans';
      case AppRoutes.analytics:
        return 'Analytics';
      case AppRoutes.profile:
        return 'Profile';
      default:
        return 'Unknown';
    }
  }
}

/// 404 Not Found screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
