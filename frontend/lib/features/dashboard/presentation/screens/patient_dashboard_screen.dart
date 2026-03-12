import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

/// Patient dashboard screen
class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Dashboard'),
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
                'Welcome, ${user?.name ?? 'Patient'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Here\'s your health overview',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Appointments',
                      value: '3',
                      label: 'Upcoming',
                      icon: Icons.calendar_today,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.appointments);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Treatment Plans',
                      value: '2',
                      label: 'Active',
                      icon: Icons.medical_services,
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.treatmentPlans);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Appointments Section
              _buildSectionHeader(
                context,
                'Upcoming Appointments',
                Icons.calendar_month,
                onViewAll: () {
                  Navigator.pushNamed(context, AppRoutes.appointments);
                },
              ),
              const SizedBox(height: 12),
              _buildAppointmentCard(
                context,
                'Dr. Sarah Johnson',
                'General Checkup',
                DateTime.now().add(const Duration(days: 2)),
                '10:00 AM',
              ),
              const SizedBox(height: 8),
              _buildAppointmentCard(
                context,
                'Dr. Michael Chen',
                'Follow-up Consultation',
                DateTime.now().add(const Duration(days: 5)),
                '02:30 PM',
              ),
              const SizedBox(height: 24),

              // Health Vitals Section
              _buildSectionHeader(
                context,
                'Health Vitals',
                Icons.favorite,
              ),
              const SizedBox(height: 12),
              _buildVitalsCard(context),
              const SizedBox(height: 24),

              // Active Treatment Plans
              _buildSectionHeader(
                context,
                'Active Treatment Plans',
                Icons.assignment,
                onViewAll: () {
                  Navigator.pushNamed(context, AppRoutes.treatmentPlans);
                },
              ),
              const SizedBox(height: 12),
              _buildTreatmentPlanCard(
                context,
                'Hypertension Management',
                'Dr. Sarah Johnson',
                'Ongoing',
              ),
              const SizedBox(height: 8),
              _buildTreatmentPlanCard(
                context,
                'Physical Therapy',
                'Dr. Michael Chen',
                'Week 3 of 8',
              ),
              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionHeader(
                context,
                'Quick Actions',
                Icons.flash_on,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.bookAppointment);
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    String doctorName,
    String type,
    DateTime date,
    String time,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to appointment details
        },
      ),
    );
  }

  Widget _buildVitalsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVitalItem('Blood Pressure', '120/80', Icons.favorite, Colors.red),
                _buildVitalItem('Heart Rate', '72 bpm', Icons.monitor_heart, Colors.pink),
                _buildVitalItem('Weight', '70 kg', Icons.monitor_weight, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to full health records
              },
              icon: const Icon(Icons.assessment),
              label: const Text('View Full Health Records'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTreatmentPlanCard(
    BuildContext context,
    String title,
    String doctor,
    String status,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.medical_services, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By $doctor'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to treatment plan details
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            context,
            'Book Appointment',
            Icons.calendar_today,
            AppColors.primary,
            () {
              Navigator.pushNamed(context, AppRoutes.bookAppointment);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            context,
            'My Records',
            Icons.folder_outlined,
            Colors.orange,
            () {
              // TODO: Navigate to medical records
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}