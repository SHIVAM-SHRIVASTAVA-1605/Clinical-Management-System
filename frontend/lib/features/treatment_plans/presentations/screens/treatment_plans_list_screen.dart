import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

/// Treatment Plans list screen
class TreatmentPlansListScreen extends StatefulWidget {
  const TreatmentPlansListScreen({super.key});

  @override
  State<TreatmentPlansListScreen> createState() => _TreatmentPlansListScreenState();
}

class _TreatmentPlansListScreenState extends State<TreatmentPlansListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch treatment plans on screen load
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
          // Filter Chips
          _buildFilterChips(),
          
          // Treatment Plans List
          Expanded(
            child: Consumer<TreatmentPlanProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.treatmentPlans.isEmpty) {
                  return const LoadingWidget(message: 'Loading treatment plans...');
                }

                if (provider.errorMessage != null) {
                  return custom.CustomErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: () => provider.fetchTreatmentPlans(),
                  );
                }

                final treatmentPlans = provider.filteredTreatmentPlans;

                if (treatmentPlans.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.medical_services,
                    message: provider.filterStatus == 'All'
                        ? 'No treatment plans found'
                        : 'No ${provider.filterStatus.toLowerCase()} treatment plans',
                    actionLabel: 'Create Treatment Plan',
                    onAction: () {
                      Navigator.pushNamed(context, AppRoutes.createTreatmentPlan);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchTreatmentPlans(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: treatmentPlans.length,
                    itemBuilder: (context, index) {
                      final treatmentPlan = treatmentPlans[index];
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
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createTreatmentPlan);
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Plan'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TreatmentPlanProvider>(
      builder: (context, provider, child) {
        final filters = ['All', ...TreatmentPlanStatus.all];
        
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

  Widget _buildTreatmentPlanCard(BuildContext context, TreatmentPlanModel plan) {
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
              // Header Row
              Row(
                children: [
                  // Diagnosis Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(plan.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: _getStatusColor(plan.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Plan Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.diagnosis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildStatusBadge(plan.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Started: ${plan.formattedStartDate}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (plan.endDate != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• Ended: ${plan.formattedEndDate}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
                      plan.patientName ?? 'Patient',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      Icons.medical_information,
                      plan.clinicianName ?? 'Clinician',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Prescription & Care Instructions Count
              Row(
                children: [
                  Expanded(
                    child: _buildCountChip(
                      Icons.medication,
                      '${plan.prescriptions.length} Prescriptions',
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCountChip(
                      Icons.assignment,
                      '${plan.careInstructions.length} Instructions',
                      Colors.orange,
                    ),
                  ),
                ],
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

  Widget _buildCountChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
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

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Treatment Plans'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Active Plans'),
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<TreatmentPlanProvider>().fetchActiveTreatmentPlans();
              },
            ),
            ListTile(
              title: const Text('All Plans'),
              leading: const Icon(Icons.list),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<TreatmentPlanProvider>().fetchTreatmentPlans();
              },
            ),
          ],
        ),
      ),
    );
  }
}