import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/clinicians/data/models/clinician_model.dart';
import 'package:frontend/features/clinicians/presentation/providers/clinician_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// User profile screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'CLINICIAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Profile Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  if (user.phone != null)
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phone!,
                      iconColor: AppColors.success,
                    ),
                  if (user.phone != null) const SizedBox(height: 12),

                  // Role
                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: 'Healthcare Provider',
                    iconColor: AppColors.info,
                  ),
                  const SizedBox(height: 12),

                  // Account Created
                  if (user.createdAt != null)
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Member Since',
                      value:
                          DateFormat('MMMM dd, yyyy').format(user.createdAt!),
                      iconColor: AppColors.warning,
                    ),
                  if (user.createdAt != null) const SizedBox(height: 12),

                  const SizedBox(height: 32),

                  // Account Actions
                  const Text(
                    'Account Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // View clinician details from backend
                  _buildActionButton(
                    context,
                    icon: Icons.badge_outlined,
                    label: 'View Clinician Details',
                    subtitle: 'View your details',
                    color: AppColors.primary,
                    onTap: () async {
                      final clinicianProvider = context.read<ClinicianProvider>();
                      await clinicianProvider.fetchClinicianById(user.id);

                      if (!context.mounted) return;

                      final clinician = clinicianProvider.selectedClinician;
                      if (clinician == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              clinicianProvider.errorMessage ??
                                  'Unable to load clinician details',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      _showClinicianDetailsDialog(context, clinician);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Update availability schedule
                  _buildActionButton(
                    context,
                    icon: Icons.schedule,
                    label: 'Update Availability',
                    subtitle: 'Update you availability slots',
                    color: AppColors.warning,
                    onTap: () async {
                      final clinicianProvider = context.read<ClinicianProvider>();
                      final currentlyLoaded = clinicianProvider.selectedClinician;
                      if (currentlyLoaded == null || currentlyLoaded.id != user.id) {
                        await clinicianProvider.fetchClinicianById(user.id);
                      }

                      if (!context.mounted) return;

                      final clinician = clinicianProvider.selectedClinician;
                      if (clinician == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              clinicianProvider.errorMessage ??
                                  'Unable to load clinician details',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      await _showUpdateAvailabilityDialog(context, clinician);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  void _showClinicianDetailsDialog(
    BuildContext context,
    ClinicianModel clinician,
  ) {
    final specialty = clinician.credentials.specialty.trim().isEmpty
        ? 'Not set'
        : clinician.credentials.specialty;
    final license = clinician.credentials.licenseNumber.trim().isEmpty
        ? 'Not set'
        : clinician.credentials.licenseNumber;
    final email = clinician.contact.email.trim().isEmpty
        ? 'Not set'
        : clinician.contact.email;
    final phone = clinician.contact.phone.trim().isEmpty
        ? 'Not set'
        : clinician.contact.phone;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clinician Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${clinician.fullName}'),
              const SizedBox(height: 8),
              Text('Email: $email'),
              const SizedBox(height: 8),
              Text('Phone: $phone'),
              const SizedBox(height: 8),
              Text('Specialty: $specialty'),
              const SizedBox(height: 8),
              Text('License: $license'),
              const SizedBox(height: 12),
              Text(
                'Availability (${clinician.availability.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (clinician.availability.isEmpty)
                const Text('No availability slots configured')
              else
                ...clinician.availability.map(
                  (slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${slot.dayOfWeek}: ${slot.startTime} - ${slot.endTime} (${slot.location})',
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateAvailabilityDialog(
    BuildContext context,
    ClinicianModel clinician,
  ) async {
    final availabilityDraft = clinician.availability
        .map(
          (slot) => ClinicianAvailability(
            dayOfWeek: slot.dayOfWeek,
            startTime: slot.startTime,
            endTime: slot.endTime,
            location: slot.location,
          ),
        )
        .toList();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Availability'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (availabilityDraft.isEmpty)
                    const Text('No availability slots yet. Add one below.')
                  else
                    ...availabilityDraft.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final slot = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              '${slot.dayOfWeek}: ${slot.startTime} - ${slot.endTime}',
                            ),
                            subtitle: Text(slot.location),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit slot',
                                  onPressed: () async {
                                    final edited = await _showAvailabilitySlotEditor(
                                      context,
                                      initial: slot,
                                    );
                                    if (edited == null) return;
                                    setDialogState(() {
                                      availabilityDraft[index] = edited;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Delete slot',
                                  onPressed: () {
                                    setDialogState(() {
                                      availabilityDraft.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final created = await _showAvailabilitySlotEditor(
                        context,
                      );
                      if (created == null) return;
                      setDialogState(() {
                        availabilityDraft.add(created);
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Availability Slot'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final result = await context
        .read<ClinicianProvider>()
        .updateClinicianAvailability(clinician.id, availabilityDraft);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ?? 'Availability updated',
        ),
        backgroundColor:
            result['success'] == true ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<ClinicianAvailability?> _showAvailabilitySlotEditor(
    BuildContext context, {
    ClinicianAvailability? initial,
  }) async {
    final dayController = TextEditingController(
      text: initial?.dayOfWeek ?? 'Monday',
    );
    final startController = TextEditingController(
      text: initial?.startTime ?? '09:00',
    );
    final endController = TextEditingController(
      text: initial?.endTime ?? '17:00',
    );
    final locationController = TextEditingController(
      text: initial?.location ?? 'Main Clinic',
    );

    final result = await showDialog<ClinicianAvailability>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(initial == null ? 'Add Availability Slot' : 'Edit Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                decoration: const InputDecoration(
                  labelText: 'Day of week',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: startController,
                decoration: const InputDecoration(
                  labelText: 'Start time (HH:mm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: endController,
                decoration: const InputDecoration(
                  labelText: 'End time (HH:mm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
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
              final day = dayController.text.trim();
              final start = startController.text.trim();
              final end = endController.text.trim();
              final location = locationController.text.trim();

              if (day.isEmpty || start.isEmpty || end.isEmpty || location.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All availability fields are required'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(
                dialogContext,
                ClinicianAvailability(
                  dayOfWeek: day,
                  startTime: start,
                  endTime: end,
                  location: location,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return result;
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
