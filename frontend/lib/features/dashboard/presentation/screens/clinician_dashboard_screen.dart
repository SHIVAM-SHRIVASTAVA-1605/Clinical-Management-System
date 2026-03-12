import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:frontend/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:provider/provider.dart';

/// Clinician dashboard screen
class ClinicianDashboardScreen extends StatelessWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh dashboard data
          await Future.delayed(const Duration(seconds: 1));
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
                    value: '15',
                    icon: Icons.people,
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.patients);
                    },
                  ),
                  StatsCard(
                    title: 'Today\'s Appointments',
                    value: '6',
                    icon: Icons.calendar_today,
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.appointments);
                    },
                  ),
                  StatsCard(
                    title: 'Active Treatments',
                    value: '12',
                    icon: Icons.description,
                    color: AppColors.info,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.treatmentPlans);
                    },
                  ),
                  StatsCard(
                    title: 'Pending Reviews',
                    value: '3',
                    icon: Icons.rate_review,
                    color: AppColors.primary,
                    onTap: () {
                      // TODO: Navigate to pending reviews
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

              // Appointment List Preview
              _buildAppointmentCard(
                context,
                patientName: 'John Smith',
                time: '09:00 AM',
                type: 'Consultation',
                status: 'Upcoming',
              ),
              const SizedBox(height: 12),
              _buildAppointmentCard(
                context,
                patientName: 'Sarah Johnson',
                time: '11:00 AM',
                type: 'Follow-up',
                status: 'Upcoming',
              ),
              const SizedBox(height: 12),
              _buildAppointmentCard(
                context,
                patientName: 'Mike Wilson',
                time: '02:00 PM',
                type: 'Treatment',
                status: 'Scheduled',
              ),
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
                      icon: Icons.add_circle_outline,
                      label: 'New Patient',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addPatient);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
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
          Navigator.pushNamed(context, AppRoutes.appointmentDetails);
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