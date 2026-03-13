import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

// Appointment details screen
class AppointmentDetailsScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch appointment details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AppointmentProvider>()
          .fetchAppointmentById(widget.appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final appointment =
                  context.read<AppointmentProvider>().selectedAppointment;
              if (appointment != null) {
                _showEditAppointmentDialog(appointment);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'confirm',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Confirm'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Mark Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Cancel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading details...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () =>
                  provider.fetchAppointmentById(widget.appointmentId),
            );
          }

          final appointment = provider.selectedAppointment;

          if (appointment == null) {
            return const Center(child: Text('Appointment not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(appointment),
                const SizedBox(height: 16),
                _buildInfoSection(appointment),
                const SizedBox(height: 16),
                _buildParticipantsSection(appointment),
                const SizedBox(height: 16),
                _buildBillingSection(appointment),
                if (appointment.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesSection(appointment),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppointmentModel appointment) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(appointment.status).withOpacity(0.8),
            _getStatusColor(appointment.status),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAppointmentIcon(appointment.appointmentType),
              size: 48,
              color: _getStatusColor(appointment.status),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appointment.appointmentType,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              appointment.status,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppointmentModel appointment) {
    return _buildCard(
      title: 'Appointment Information',
      icon: Icons.info,
      children: [
        _buildInfoRow(Icons.calendar_today, 'Date', appointment.formattedDate),
        _buildInfoRow(Icons.schedule, 'Time', appointment.formattedTime),
        _buildInfoRow(
            Icons.timelapse, 'Duration', '${appointment.duration} minutes'),
        _buildInfoRow(Icons.location_on, 'Location', appointment.location),
      ],
    );
  }

  Widget _buildParticipantsSection(AppointmentModel appointment) {
    return _buildCard(
      title: 'Participants',
      icon: Icons.people,
      children: [
        _buildParticipantCard(
          name: appointment.patientName ?? 'Unknown Patient',
          role: 'Patient',
          icon: Icons.person,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildParticipantCard(
          name: appointment.clinicianName ?? 'Unknown Clinician',
          role: 'Healthcare Provider',
          icon: Icons.medical_services,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildParticipantCard({
    required String name,
    required String role,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSection(AppointmentModel appointment) {
    final billing = appointment.billing;

    return _buildCard(
      title: 'Billing Information',
      icon: Icons.payment,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBillingStatusColor(billing.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBillingStatusColor(billing.status).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '\$${billing.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getBillingStatusColor(billing.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Status',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBillingStatusColor(billing.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      billing.status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (billing.insuranceDetails.provider != null ||
                  billing.insuranceDetails.policyNumber != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.shield,
                  'Insurance Provider',
                  billing.insuranceDetails.provider ?? 'N/A',
                ),
                _buildInfoRow(
                  Icons.confirmation_number,
                  'Policy Number',
                  billing.insuranceDetails.policyNumber ?? 'N/A',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(AppointmentModel appointment) {
    return _buildCard(
      title: 'Notes',
      icon: Icons.note,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            appointment.notes,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
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
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

  Color _getBillingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'insured':
        return AppColors.info;
      default:
        return AppColors.grey;
    }
  }

  IconData _getAppointmentIcon(String type) {
    switch (type) {
      case AppointmentType.consultation:
        return Icons.medical_services;
      case AppointmentType.followUp:
        return Icons.assignment;
      case AppointmentType.procedure:
        return Icons.healing;
      case AppointmentType.checkup:
        return Icons.health_and_safety;
      case AppointmentType.emergency:
        return Icons.emergency;
      default:
        return Icons.event;
    }
  }

  Future<void> _showEditAppointmentDialog(AppointmentModel appointment) async {
    final patientIdController =
        TextEditingController(text: appointment.patientId);
    final notesController = TextEditingController(text: appointment.notes);
    final amountController = TextEditingController(
        text: appointment.billing.amount.toStringAsFixed(2));

    String selectedType = appointment.appointmentType;
    String selectedLocation = appointment.location;
    DateTime selectedDate = DateTime(
      appointment.scheduledAt.year,
      appointment.scheduledAt.month,
      appointment.scheduledAt.day,
    );
    TimeOfDay selectedTime = TimeOfDay(
      hour: appointment.scheduledAt.hour,
      minute: appointment.scheduledAt.minute,
    );
    int selectedDuration = appointment.duration;

    final updated = await showDialog<AppointmentModel>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit Appointment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: patientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Patient ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Appointment Type',
                        border: OutlineInputBorder(),
                      ),
                      items: AppointmentType.all
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      items: AppointmentLocation.all
                          .map(
                            (location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            selectedLocation = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 1)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setLocalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text('Time'),
                      subtitle: Text(selectedTime.format(context)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setLocalState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedDuration,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      items: [15, 30, 45, 60, 90, 120]
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text('$d minutes'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            selectedDuration = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Billing Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final patientId = patientIdController.text.trim();
                    final amount =
                        double.tryParse(amountController.text.trim());

                    if (patientId.isEmpty || amount == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter valid patient ID and amount'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final scheduledAt = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    Navigator.pop(
                      dialogContext,
                      appointment.copyWith(
                        patientId: patientId,
                        appointmentType: selectedType,
                        location: selectedLocation,
                        scheduledAt: scheduledAt,
                        duration: selectedDuration,
                        notes: notesController.text.trim(),
                        updatedAt: DateTime.now(),
                        patientName: 'Patient ID: $patientId',
                        billing: BillingInfo(
                          amount: amount,
                          status: appointment.billing.status,
                          insuranceDetails:
                              appointment.billing.insuranceDetails,
                        ),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated != null && mounted) {
      final provider = context.read<AppointmentProvider>();
      final success =
          await provider.updateAppointment(widget.appointmentId, updated);
      if (!mounted) return;

      await provider.fetchAppointmentById(widget.appointmentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Appointment updated successfully'
              : provider.errorMessage ?? 'Failed to update appointment'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }

    patientIdController.dispose();
    notesController.dispose();
    amountController.dispose();
  }

  void _handleMenuAction(String action) async {
    final provider = context.read<AppointmentProvider>();
    bool success = false;
    String message = '';

    switch (action) {
      case 'confirm':
        success = await provider.confirmAppointment(widget.appointmentId);
        message = success ? 'Appointment confirmed' : 'Failed to confirm';
        break;
      case 'complete':
        success = await provider.completeAppointment(widget.appointmentId);
        message = success ? 'Appointment completed' : 'Failed to complete';
        break;
      case 'cancel':
        success = await _showCancelConfirmation();
        return;
      case 'delete':
        _showDeleteConfirmation();
        return;
    }

    if (mounted) {
      // Refresh details
      provider.fetchAppointmentById(widget.appointmentId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content:
                const Text('Are you sure you want to cancel this appointment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext, true);
                  final provider = context.read<AppointmentProvider>();
                  final success =
                      await provider.cancelAppointment(widget.appointmentId);

                  if (mounted) {
                    provider.fetchAppointmentById(widget.appointmentId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Appointment cancelled'
                            : 'Failed to cancel'),
                        backgroundColor:
                            success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text(
            'Are you sure you want to delete this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final provider = context.read<AppointmentProvider>();
              final success =
                  await provider.deleteAppointment(widget.appointmentId);

              if (mounted) {
                Navigator.pop(context); // Close loading
                Navigator.pop(context); // Go back to list

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Appointment deleted successfully'
                        : provider.errorMessage ?? 'Failed to delete'),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
