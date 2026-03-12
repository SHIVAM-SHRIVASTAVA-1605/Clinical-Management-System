import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

// Treatment Plan details screen
class TreatmentPlanDetailsScreen extends StatefulWidget {
  final String planId;

  const TreatmentPlanDetailsScreen({
    super.key,
    required this.planId,
  });

  @override
  State<TreatmentPlanDetailsScreen> createState() => _TreatmentPlanDetailsScreenState();
}

class _TreatmentPlanDetailsScreenState extends State<TreatmentPlanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch treatment plan details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreatmentPlanProvider>().fetchTreatmentPlanById(widget.planId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    SizedBox(width: 8),
                    Text('Mark Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'hold',
                child: Row(
                  children: [
                    Icon(Icons.pause_circle, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('Put On Hold'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reactivate',
                child: Row(
                  children: [
                    Icon(Icons.play_circle, color: AppColors.info),
                    SizedBox(width: 8),
                    Text('Reactivate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Cancel Plan'),
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
                _buildCareInstructionsSection(plan),
                if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesSection(plan),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TreatmentPlanModel plan) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(plan.status).withOpacity(0.8),
            _getStatusColor(plan.status),
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
              Icons.medical_services,
              size: 48,
              color: _getStatusColor(plan.status),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan.diagnosis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              plan.status,
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

  Widget _buildOverviewSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Overview',
      icon: Icons.info,
      children: [
        _buildInfoRow(Icons.calendar_today, 'Start Date', plan.formattedStartDate),
        _buildInfoRow(Icons.event_available, 'End Date', plan.formattedEndDate),
        _buildInfoRow(Icons.timelapse, 'Duration', '${plan.durationInDays} days'),
      ],
    );
  }

  Widget _buildParticipantsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Participants',
      icon: Icons.people,
      children: [
        _buildParticipantCard(
          name: plan.patientName ?? 'Unknown Patient',
          role: 'Patient',
          icon: Icons.person,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildParticipantCard(
          name: plan.clinicianName ?? 'Unknown Clinician',
          role: 'Healthcare Provider',
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No prescriptions',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.medication, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  prescription.medicationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPrescriptionDetail('Dosage', prescription.dosage),
          const SizedBox(height: 6),
          _buildPrescriptionDetail('Frequency', prescription.frequency),
          const SizedBox(height: 6),
          _buildPrescriptionDetail('Duration', prescription.duration),
          if (prescription.instructions != null && prescription.instructions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prescription.instructions!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetail(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildCareInstructionsSection(TreatmentPlanModel plan) {
    return _buildCard(
      title: 'Care Instructions (${plan.careInstructions.length})',
      icon: Icons.assignment,
      children: plan.careInstructions.isEmpty
          ? [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No care instructions',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ]
          : plan.careInstructions
              .asMap()
              .entries
              .map((entry) => Column(
                    children: [
                      if (entry.key > 0) const SizedBox(height: 12),
                      _buildCareInstructionCard(entry.value),
                    ],
                  ))
              .toList(),
    );
  }

  Widget _buildCareInstructionCard(CareInstruction instruction) {
    final color = _getCategoryColor(instruction.category);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_getCategoryIcon(instruction.category), color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    instruction.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  instruction.instruction,
                  style: const TextStyle(fontSize: 14),
                ),
                if (instruction.frequency != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Frequency: ${instruction.frequency}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(TreatmentPlanModel plan) {
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
            plan.notes!,
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
      case TreatmentPlanStatus.active:
        return AppColors.success;
      case TreatmentPlanStatus.completed:
        return AppColors.primary;
      case TreatmentPlanStatus.onHold:
        return AppColors.warning;
      case TreatmentPlanStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case CareCategory.diet:
        return Colors.orange;
      case CareCategory.exercise:
        return Colors.green;
      case CareCategory.lifestyle:
        return Colors.blue;
      case CareCategory.monitoring:
        return Colors.purple;
      case CareCategory.medication:
        return Colors.red;
      case CareCategory.followUp:
        return Colors.teal;
      default:
        return AppColors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case CareCategory.diet:
        return Icons.restaurant;
      case CareCategory.exercise:
        return Icons.fitness_center;
      case CareCategory.lifestyle:
        return Icons.self_improvement;
      case CareCategory.monitoring:
        return Icons.monitor_heart;
      case CareCategory.medication:
        return Icons.medication;
      case CareCategory.followUp:
        return Icons.event_repeat;
      default:
        return Icons.assignment;
    }
  }

  void _handleMenuAction(String action) async {
    final provider = context.read<TreatmentPlanProvider>();
    bool success = false;
    String message = '';

    switch (action) {
      case 'complete':
        success = await provider.completeTreatmentPlan(widget.planId);
        message = success ? 'Treatment plan completed' : 'Failed to complete';
        break;
      case 'hold':
        success = await provider.holdTreatmentPlan(widget.planId);
        message = success ? 'Treatment plan on hold' : 'Failed to update';
        break;
      case 'reactivate':
        success = await provider.reactivateTreatmentPlan(widget.planId);
        message = success ? 'Treatment plan reactivated' : 'Failed to reactivate';
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
      provider.fetchTreatmentPlanById(widget.planId);
      
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
        title: const Text('Cancel Treatment Plan'),
        content: const Text('Are you sure you want to cancel this treatment plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext, true);
              final provider = context.read<TreatmentPlanProvider>();
              final success = await provider.cancelTreatmentPlan(widget.planId);
              
              if (mounted) {
                provider.fetchTreatmentPlanById(widget.planId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Treatment plan cancelled' : 'Failed to cancel'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Treatment Plan'),
        content: const Text('Are you sure you want to delete this treatment plan? This action cannot be undone.'),
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
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              
              final provider = context.read<TreatmentPlanProvider>();
              final success = await provider.deleteTreatmentPlan(widget.planId);
              
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Treatment plan deleted successfully' 
                        : provider.errorMessage ?? 'Failed to delete'
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