import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../providers/clinician_provider.dart';
import '../../data/models/clinician_model.dart';

// Clinician details screen
class ClinicianDetailsScreen extends StatefulWidget {
  final String clinicianId;

  const ClinicianDetailsScreen({
    super.key,
    required this.clinicianId,
  });

  @override
  State<ClinicianDetailsScreen> createState() => _ClinicianDetailsScreenState();
}

class _ClinicianDetailsScreenState extends State<ClinicianDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch clinician details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicianProvider>().fetchClinicianById(widget.clinicianId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinician Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: Consumer<ClinicianProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading details...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchClinicianById(widget.clinicianId),
            );
          }

          final clinician = provider.selectedClinician;

          if (clinician == null) {
            return const Center(child: Text('Clinician not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(clinician),
                const SizedBox(height: 16),
                _buildInfoSection(clinician),
                const SizedBox(height: 16),
                _buildCredentialsSection(clinician),
                const SizedBox(height: 16),
                _buildContactSection(clinician),
                const SizedBox(height: 16),
                _buildAvailabilitySection(clinician),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ClinicianModel clinician) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.white,
            child: Text(
              clinician.name.firstName[0] + clinician.name.lastName[0],
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            clinician.fullName,
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
              clinician.credentials.specialty,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ClinicianModel clinician) {
    return _buildCard(
      title: 'Basic Information',
      children: [
        _buildInfoRow(Icons.badge, 'License Number', clinician.credentials.licenseNumber),
        _buildInfoRow(
          Icons.calendar_today,
          'Joined',
          clinician.createdAt != null
              ? '${clinician.createdAt!.day}/${clinician.createdAt!.month}/${clinician.createdAt!.year}'
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildCredentialsSection(ClinicianModel clinician) {
    return _buildCard(
      title: 'Certifications',
      children: clinician.credentials.certifications.isEmpty
          ? [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No certifications available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            ]
          : clinician.credentials.certifications
              .map((cert) => _buildCertificationCard(cert))
              .toList(),
    );
  }

  Widget _buildCertificationCard(Certification cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cert.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Issued by: ${cert.issuedBy}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'Date: ${cert.issueDate.day}/${cert.issueDate.month}/${cert.issueDate.year}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(ClinicianModel clinician) {
    return _buildCard(
      title: 'Contact Information',
      children: [
        _buildInfoRow(Icons.email, 'Email', clinician.contact.email),
        _buildInfoRow(Icons.phone, 'Phone', clinician.contact.phone),
        _buildInfoRow(Icons.location_on, 'Address', clinician.contact.officeAddress.fullAddress),
      ],
    );
  }

  Widget _buildAvailabilitySection(ClinicianModel clinician) {
    return _buildCard(
      title: 'Availability Schedule',
      children: clinician.availability.isEmpty
          ? [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No availability schedule set',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            ]
          : clinician.availability
              .map((schedule) => _buildScheduleCard(schedule))
              .toList(),
    );
  }

  Widget _buildScheduleCard(ClinicianAvailability schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.dayOfWeek,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${schedule.startTime} - ${schedule.endTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  schedule.location,
                  style: const TextStyle(
                    fontSize: 12,
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

  Widget _buildCard({required String title, required List<Widget> children}) {
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Clinician'),
        content: const Text('Are you sure you want to delete this clinician? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
            
              // Show loading
              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
            
              // Delete clinician
              final provider = context.read<ClinicianProvider>();
              final success = await provider.deleteClinician(widget.clinicianId);
            
              // Close loading dialog
              if (mounted) {
                Navigator.pop(context);
              
                // Go back to list
                Navigator.pop(context);
              
                // Show result message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Clinician deleted successfully' 
                        : provider.errorMessage ?? 'Failed to delete clinician'
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
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