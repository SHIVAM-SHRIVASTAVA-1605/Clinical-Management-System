import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:frontend/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:provider/provider.dart';

/// Clinician dashboard screen
class ClinicianDashboardScreen extends StatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  State<ClinicianDashboardScreen> createState() =>
      _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState extends State<ClinicianDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      // Load appointments for this clinician
      context.read<AppointmentProvider>().fetchAppointments();
      // Load patients for this clinician
      context.read<PatientProvider>().fetchPatients();
      // Load treatment plans for this clinician
      context.read<TreatmentPlanProvider>().fetchTreatmentPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final patientProvider = context.watch<PatientProvider>();
    final treatmentPlanProvider = context.watch<TreatmentPlanProvider>();
    final user = authProvider.user;

    // Filter data by clinician ID
    final clinicianId = user?.id ?? '';

    // Get today's date for filtering
    final today = DateTime.now();

    // Filter appointments for this clinician and today
    final allAppointments = appointmentProvider.appointments
        .where((apt) => apt.clinicianId == clinicianId)
        .toList();

    final todayAppointments = allAppointments.where((apt) {
      return apt.scheduledAt.year == today.year &&
          apt.scheduledAt.month == today.month &&
          apt.scheduledAt.day == today.day;
    }).toList();

    final myPatients = patientProvider.getPatientsByClinicianId(clinicianId);
    final uniquePatientCount = myPatients.length;

    // Filter treatment plans created by this clinician
    final myTreatmentPlans = treatmentPlanProvider.treatmentPlans
        .where((plan) => plan.clinicianId == clinicianId)
        .toList();

    final activeTreatments = myTreatmentPlans
        .where((plan) => plan.hasFollowUpStatus(FollowUpStatus.pending))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Dashboard'),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all data
          _loadData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, Dr. ${user?.name ?? 'Clinician'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your schedule for today',
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
                    title: 'My Patients',
                    value: uniquePatientCount.toString(),
                    icon: Icons.people,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.patients);
                    },
                  ),
                  StatsCard(
                    title: 'Today\'s Appointments',
                    value: todayAppointments.length.toString(),
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
                  StatsCard(
                    title: 'Total Appointments',
                    value: allAppointments.length.toString(),
                    icon: Icons.event_note,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.appointments);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Schedule Section
              const Text(
                'Today\'s Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Show real appointments or empty state
              if (todayAppointments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments scheduled for today',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...todayAppointments.take(3).map((appointment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAppointmentCard(
                      context,
                      appointmentId: appointment.id,
                      patientName: appointment.patientName ??
                          'Patient ID: ${appointment.patientId}',
                      time:
                          '${appointment.scheduledAt.hour.toString().padLeft(2, '0')}:${appointment.scheduledAt.minute.toString().padLeft(2, '0')}',
                      type: appointment.appointmentType,
                      status: appointment.status,
                    ),
                  );
                }).toList(),
              const SizedBox(height: 16),

              // View All Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.appointments);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('View All Appointments'),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.event_available,
                      label: 'Book Appointment',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.bookAppointment);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.person_add,
                      label: 'Add Patient',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addPatient);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createTreatmentPlan);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Treatment Plan'),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context, {
    required String appointmentId,
    required String patientName,
    required String time,
    required String type,
    required String status,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            patientName[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$time • $type'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.appointmentDetails,
            arguments: appointmentId,
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
