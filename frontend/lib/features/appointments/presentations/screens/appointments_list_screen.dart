import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

/// Appointments list screen
class AppointmentsListScreen extends StatefulWidget {
  const AppointmentsListScreen({super.key});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch appointments on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          
          // Appointments List
          Expanded(
            child: Consumer2<AppointmentProvider, AuthProvider>(
              builder: (context, appointmentProvider, authProvider, child) {
                if (appointmentProvider.isLoading && appointmentProvider.appointments.isEmpty) {
                  return const LoadingWidget(message: 'Loading appointments...');
                }

                if (appointmentProvider.errorMessage != null) {
                  return custom.CustomErrorWidget(
                    message: appointmentProvider.errorMessage!,
                    onRetry: () => appointmentProvider.fetchAppointments(),
                  );
                }

                // Filter appointments based on user role
                final user = authProvider.user;
                final allAppointments = appointmentProvider.filteredAppointments;
                final filteredAppointments = user?.isClinician == true
                    ? allAppointments.where((appointment) => 
                        appointment.clinicianId == user!.id).toList()
                    : allAppointments;

                if (filteredAppointments.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.calendar_today,
                    message: appointmentProvider.filterStatus == 'All'
                        ? 'No appointments found'
                        : 'No ${appointmentProvider.filterStatus.toLowerCase()} appointments',
                    actionLabel: 'Book Appointment',
                    onAction: () {
                      Navigator.pushNamed(context, AppRoutes.bookAppointment);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => appointmentProvider.fetchAppointments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = filteredAppointments[index];
                      return _buildAppointmentCard(context, appointment);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.bookAppointment);
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Appointment'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final filters = ['All', ...AppointmentStatus.all];
        
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = provider.filterStatus == filter;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.setFilterStatus(filter);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.appointmentDetails,
            arguments: appointment.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Date Badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          appointment.scheduledAt.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(appointment.status),
                          ),
                        ),
                        Text(
                          _getMonthShort(appointment.scheduledAt.month),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(appointment.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Appointment Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.appointmentType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusBadge(appointment.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.formattedTime,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.timelapse,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${appointment.duration} min',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Patient & Clinician Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      appointment.patientName ?? 'Patient',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.medical_services,
                      appointment.clinicianName ?? 'Clinician',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Location
              _buildInfoChip(
                Icons.location_on,
                appointment.location,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.info;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.noShow:
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  String _getMonthShort(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Today\'s Appointments'),
              leading: const Icon(Icons.today),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AppointmentProvider>().fetchTodaysAppointments();
              },
            ),
            ListTile(
              title: const Text('Upcoming Appointments'),
              leading: const Icon(Icons.upcoming),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AppointmentProvider>().fetchUpcomingAppointments();
              },
            ),
            ListTile(
              title: const Text('All Appointments'),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AppointmentProvider>().fetchAppointments();
              },
            ),
          ],
        ),
      ),
    );
  }
}