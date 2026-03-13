import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

class TreatmentPlansListScreen extends StatefulWidget {
  const TreatmentPlansListScreen({super.key});

  @override
  State<TreatmentPlansListScreen> createState() =>
      _TreatmentPlansListScreenState();
}

class _TreatmentPlansListScreenState extends State<TreatmentPlansListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TreatmentPlanProvider>().fetchTreatmentPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer2<TreatmentPlanProvider, AuthProvider>(
              builder: (context, treatmentPlanProvider, authProvider, child) {
                if (treatmentPlanProvider.isLoading &&
                    treatmentPlanProvider.treatmentPlans.isEmpty) {
                  return const LoadingWidget(
                      message: 'Loading treatment plans...');
                }

                if (treatmentPlanProvider.errorMessage != null) {
                  return custom.CustomErrorWidget(
                    message: treatmentPlanProvider.errorMessage!,
                    onRetry: treatmentPlanProvider.fetchTreatmentPlans,
                  );
                }

                final user = authProvider.user;
                final allTreatmentPlans =
                    treatmentPlanProvider.filteredTreatmentPlans;
                final filteredTreatmentPlans = user != null
                    ? allTreatmentPlans
                        .where((plan) => plan.clinicianId == user.id)
                        .toList()
                    : allTreatmentPlans;

                if (filteredTreatmentPlans.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.medical_services,
                    message: treatmentPlanProvider.filterStatus == 'All'
                        ? 'No treatment plans found'
                        : 'No plans with ${treatmentPlanProvider.filterStatus.toLowerCase()} follow-up',
                    actionLabel: 'Create Treatment Plan',
                    onAction: () => Navigator.pushNamed(
                      context,
                      AppRoutes.createTreatmentPlan,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: treatmentPlanProvider.fetchTreatmentPlans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTreatmentPlans.length,
                    itemBuilder: (context, index) {
                      final treatmentPlan = filteredTreatmentPlans[index];
                      return _buildTreatmentPlanCard(context, treatmentPlan);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.createTreatmentPlan),
        icon: const Icon(Icons.add),
        label: const Text('Create Plan'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TreatmentPlanProvider>(
      builder: (context, provider, child) {
        final filters = ['All', ...FollowUpStatus.all];

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
                  onSelected: (_) => provider.setFilterStatus(filter),
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

  Widget _buildTreatmentPlanCard(
      BuildContext context, TreatmentPlanModel plan) {
    final nextFollowUp = plan.nextPendingFollowUp;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.treatmentPlanDetails,
            arguments: plan.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.diagnosis.condition,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ICD-10: ${plan.diagnosis.icd10Code}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFollowUpBadge(nextFollowUp?.status ?? 'None'),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.person,
                      plan.patientName ?? 'Patient ID: ${plan.patientId}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.medical_information,
                      plan.clinicianName ?? 'Clinician ID: ${plan.clinicianId}',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCountChip(
                      Icons.medication,
                      '${plan.prescriptions.length} Prescriptions',
                      Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCountChip(
                      Icons.event_repeat,
                      '${plan.followUps.length} Follow-Ups',
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nextFollowUp == null
                    ? 'No pending follow-up'
                    : 'Next follow-up: ${nextFollowUp.scheduledDate.day}/${nextFollowUp.scheduledDate.month}/${nextFollowUp.scheduledDate.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
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
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Treatment Plans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending Follow-Up'),
              leading:
                  const Icon(Icons.pending_actions, color: AppColors.warning),
              onTap: () {
                Navigator.pop(dialogContext);
                context
                    .read<TreatmentPlanProvider>()
                    .setFilterStatus(FollowUpStatus.pending);
              },
            ),
            ListTile(
              title: const Text('All Plans'),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<TreatmentPlanProvider>().setFilterStatus('All');
                context.read<TreatmentPlanProvider>().fetchTreatmentPlans();
              },
            ),
          ],
        ),
      ),
    );
  }
}
