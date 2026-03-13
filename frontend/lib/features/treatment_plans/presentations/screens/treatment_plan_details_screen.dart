import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

class TreatmentPlanDetailsScreen extends StatefulWidget {
  final String planId;

  const TreatmentPlanDetailsScreen({
    super.key,
    required this.planId,
  });

  @override
  State<TreatmentPlanDetailsScreen> createState() =>
      _TreatmentPlanDetailsScreenState();
}

class _TreatmentPlanDetailsScreenState
    extends State<TreatmentPlanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TreatmentPlanProvider>()
          .fetchTreatmentPlanById(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Plan Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
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
      body: Consumer<TreatmentPlanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading details...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchTreatmentPlanById(widget.planId),
            );
          }

          final plan = provider.selectedTreatmentPlan;
          if (plan == null) {
            return const Center(child: Text('Treatment plan not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(plan),
                const SizedBox(height: 16),
                _buildOverviewSection(plan),
                const SizedBox(height: 16),
                _buildParticipantsSection(plan),
                const SizedBox(height: 16),
                _buildPrescriptionsSection(plan),
                const SizedBox(height: 16),
                _buildFollowUpsSection(plan),
                const SizedBox(height: 16),
                _buildRecommendationsSection(plan),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TreatmentPlanModel plan) {
    final nextFollowUp = plan.nextPendingFollowUp;
    final badgeText = nextFollowUp?.status ?? 'No Pending Follow-Up';
    final badgeColor = _statusColor(nextFollowUp?.status);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D6FA3), Color(0xFF2450A4)],
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
            child: const Icon(
              Icons.health_and_safety,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan.diagnosis.condition,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ICD-10: ${plan.diagnosis.icd10Code}',
            style: const TextStyle(fontSize: 14, color: AppColors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withOpacity(0.45)),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Overview',
      icon: Icons.info,
      children: [
        _buildInfoRow(
            Icons.calendar_today, 'Diagnosed At', plan.formattedDiagnosedAt),
        _buildInfoRow(Icons.history, 'Created', _formatDate(plan.createdAt)),
        _buildInfoRow(Icons.update, 'Updated', _formatDate(plan.updatedAt)),
      ],
    );
  }

  Widget _buildParticipantsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Participants',
      icon: Icons.people,
      children: [
        _buildParticipantCard(
          name: plan.patientName ?? 'Patient ID: ${plan.patientId}',
          role: 'Patient',
          icon: Icons.person,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildParticipantCard(
          name: plan.clinicianName ?? 'Clinician ID: ${plan.clinicianId}',
          role: 'Clinician',
          icon: Icons.medical_information,
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

  Widget _buildPrescriptionsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Prescriptions (${plan.prescriptions.length})',
      icon: Icons.medication,
      children: plan.prescriptions.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No prescriptions',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ]
          : plan.prescriptions
              .asMap()
              .entries
              .map((entry) => Column(
                    children: [
                      if (entry.key > 0) const Divider(height: 24),
                      _buildPrescriptionCard(entry.value),
                    ],
                  ))
              .toList(),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prescription.medication,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.straighten, 'Dosage', prescription.dosage),
          _buildInfoRow(Icons.repeat, 'Frequency', prescription.frequency),
          _buildInfoRow(
            Icons.play_arrow,
            'Start Date',
            _formatDate(prescription.startDate),
          ),
          _buildInfoRow(
            Icons.stop,
            'End Date',
            prescription.endDate == null
                ? 'Ongoing'
                : _formatDate(prescription.endDate!),
          ),
          _buildInfoRow(Icons.notes, 'Instructions', prescription.instructions),
        ],
      ),
    );
  }

  Widget _buildFollowUpsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Follow-Ups (${plan.followUps.length})',
      icon: Icons.event_repeat,
      children: plan.followUps.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No follow-ups',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ]
          : plan.followUps
              .map(
                (followUp) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusColor(followUp.status).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusColor(followUp.status).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              followUp.purpose,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            _buildStatusChip(followUp.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Scheduled: ${_formatDate(followUp.scheduledDate)}'),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildRecommendationsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Recommendations',
      icon: Icons.recommend,
      children: [
        const Text(
          'Lifestyle Changes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (plan.recommendations.lifestyleChanges.isEmpty)
          const Text(
            'No lifestyle changes provided',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...plan.recommendations.lifestyleChanges
              .map((item) => _bulletItem(item)),
        const SizedBox(height: 16),
        const Text(
          'Referrals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (plan.recommendations.referrals.isEmpty)
          const Text(
            'No referrals provided',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...plan.recommendations.referrals.map(
            (referral) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      referral.specialist,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(referral.reason),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case FollowUpStatus.pending:
        return AppColors.warning;
      case FollowUpStatus.completed:
        return AppColors.success;
      case FollowUpStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Treatment Plan'),
        content: const Text(
          'Are you sure you want to delete this treatment plan? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              if (!mounted) {
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final provider = context.read<TreatmentPlanProvider>();
              final success = await provider.deleteTreatmentPlan(widget.planId);

              if (!mounted) {
                return;
              }

              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Treatment plan deleted successfully'
                        : provider.errorMessage ?? 'Failed to delete',
                  ),
                  backgroundColor:
                      success ? AppColors.success : AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
