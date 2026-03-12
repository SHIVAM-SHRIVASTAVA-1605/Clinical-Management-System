import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/clinicians/presentation/providers/clinician_provider.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:frontend/features/dashboard/presentation/widgets/stats_card.dart';

// Admin dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicianProvider>().fetchClinicians();
      context.read<PatientProvider>().fetchPatients();
      context.read<AppointmentProvider>().fetchAppointments();
      context.read<TreatmentPlanProvider>().fetchTreatmentPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final clinicianProvider = context.watch<ClinicianProvider>();
    final patientProvider = context.watch<PatientProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final treatmentPlanProvider = context.watch<TreatmentPlanProvider>();
    final user = authProvider.user;

    // Calculate real-time counts
    final totalClinicians = clinicianProvider.clinicians.length;
    final totalPatients = patientProvider.patients.length;
    final todayAppointments = appointmentProvider.appointments.where((apt) {
      final today = DateTime.now();
      return apt.scheduledAt.year == today.year &&
             apt.scheduledAt.month == today.month &&
             apt.scheduledAt.day == today.day;
    }).length;
    final activeTreatments = treatmentPlanProvider.treatmentPlans
        .where((plan) => plan.status.toString().contains('active'))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all data
          await Future.wait([
            context.read<ClinicianProvider>().fetchClinicians(),
            context.read<PatientProvider>().fetchPatients(),
            context.read<AppointmentProvider>().fetchAppointments(),
            context.read<TreatmentPlanProvider>().fetchTreatmentPlans(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome back, ${user?.name ?? 'Admin'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Here\'s your system overview',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  StatsCard(
                    title: 'Total Clinicians',
                    value: totalClinicians.toString(),
                    icon: Icons.medical_services,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.clinicians);
                    },
                  ),
                  StatsCard(
                    title: 'Total Patients',
                    value: totalPatients.toString(),
                    icon: Icons.people,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.patients);
                    },
                  ),
                  StatsCard(
                    title: 'Appointments Today',
                    value: todayAppointments.toString(),
                    icon: Icons.calendar_today,
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.appointments);
                    },
                  ),
                  StatsCard(
                    title: 'Active Treatments',
                    value: activeTreatments.toString(),
                    icon: Icons.description,
                    color: AppColors.info,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.treatmentPlans);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions Section
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action Cards - Only View Analytics
              _buildQuickActionCard(
                context,
                icon: Icons.analytics,
                title: 'View Analytics',
                subtitle: 'System reports and insights',
                color: AppColors.success,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.analytics);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}