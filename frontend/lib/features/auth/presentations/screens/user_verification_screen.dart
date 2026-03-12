import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/core/utils/toast_helper.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Admin screen for verifying clinician registrations
class UserVerificationScreen extends StatelessWidget {
  const UserVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Clinician Verifications'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final pendingClinicians = authProvider.getPendingClinicians();

          if (pendingClinicians.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending verifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingClinicians.length,
            itemBuilder: (context, index) {
              final clinician = pendingClinicians[index];
              return _ClinicianVerificationCard(
                clinician: clinician,
                onApprove: () async {
                  final success =
                      await authProvider.verifyClinician(clinician.id);
                  if (context.mounted) {
                    if (success) {
                      ToastHelper.showSuccess(
                        context,
                        'Clinician approved successfully',
                      );
                    } else {
                      ToastHelper.showError(
                        context,
                        'Failed to approve clinician',
                      );
                    }
                  }
                },
                onReject: () async {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reject Clinician'),
                      content: Text(
                        'Are you sure you want to reject ${clinician.name}? This will permanently delete their account.',
                      ),
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
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    final success =
                        await authProvider.rejectClinician(clinician.id);
                    if (context.mounted) {
                      if (success) {
                        ToastHelper.showSuccess(
                          context,
                          'Clinician rejected',
                        );
                      } else {
                        ToastHelper.showError(
                          context,
                          'Failed to reject clinician',
                        );
                      }
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ClinicianVerificationCard extends StatelessWidget {
  final dynamic clinician;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ClinicianVerificationCard({
    required this.clinician,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    clinician.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinician.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pending Verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Details
            _DetailRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: clinician.email,
            ),
            const SizedBox(height: 8),
            if (clinician.phone != null)
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: clinician.phone!,
              ),
            if (clinician.phone != null) const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Registered',
              value: DateFormat('MMM dd, yyyy').format(clinician.createdAt!),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
