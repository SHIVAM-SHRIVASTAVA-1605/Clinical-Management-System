import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:frontend/features/analytics/presentation/widgets/bar_chart_card.dart';
import 'package:frontend/features/analytics/presentation/widgets/line_chart_card.dart';
import 'package:frontend/features/analytics/presentation/widgets/pie_chart_card.dart';
import 'package:frontend/features/analytics/presentation/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

// Analytics Dashboard Screen
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch analytics on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsProvider>().fetchAnalytics();
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.analyticsData == null) {
            return const LoadingWidget(message: 'Loading analytics...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchAnalytics(),
            );
          }

          if (provider.analyticsData == null) {
            return const Center(child: Text('No analytics data available'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAnalytics(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  _buildSectionTitle('Overview'),
                  const SizedBox(height: 12),
                  _buildOverviewCards(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Revenue Cards
                  _buildSectionTitle('Revenue'),
                  const SizedBox(height: 12),
                  _buildRevenueCards(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Monthly Revenue Chart
                  _buildSectionTitle('Monthly Revenue Trend'),
                  const SizedBox(height: 12),
                  BarChartCard(
                    data: provider.monthlyRevenue,
                    title: 'Revenue (Last 6 Months)',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Appointment Trends
                  _buildSectionTitle('Appointment Trends'),
                  const SizedBox(height: 12),
                  LineChartCard(
                    data: provider.appointmentTrends,
                    title: 'Appointments (Last 7 Days)',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Statistics Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Appointments'),
                            const SizedBox(height: 12),
                            PieChartCard(
                              appointmentStats: provider.appointmentStats!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Treatment Plans'),
                            const SizedBox(height: 12),
                            PieChartCard(
                              treatmentPlanStats: provider.treatmentPlanStats!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Demographics
                  _buildSectionTitle('Patient Demographics'),
                  const SizedBox(height: 12),
                  _buildDemographicsCard(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Top Diagnoses
                  _buildSectionTitle('Top Diagnoses'),
                  const SizedBox(height: 12),
                  _buildTopDiagnosesCard(provider),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsProvider provider) {
    final overview = provider.overview!;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Patients',
                value: overview.totalPatients.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Total Clinicians',
                value: overview.totalClinicians.toString(),
                icon: Icons.medical_services,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Appointments',
                value: overview.totalAppointments.toString(),
                subtitle: '${overview.activeAppointments} active',
                icon: Icons.calendar_today,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Treatment Plans',
                value: overview.totalTreatmentPlans.toString(),
                subtitle: '${overview.activeTreatmentPlans} active',
                icon: Icons.assignment,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCards(AnalyticsProvider provider) {
    final overview = provider.overview!;
    
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Revenue',
            value: '\$${overview.totalRevenue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.teal,
            isLarge: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Monthly Revenue',
            value: '\$${overview.monthlyRevenue.toStringAsFixed(2)}',
            subtitle: 'This month',
            icon: Icons.trending_up,
            color: Colors.indigo,
            isLarge: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicsCard(AnalyticsProvider provider) {
    final demographics = provider.demographics!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Gender Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDemographicBar(
              'Male',
              demographics.male,
              demographics.total,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildDemographicBar(
              'Female',
              demographics.female,
              demographics.total,
              Colors.pink,
            ),
            if (demographics.other > 0) ...[
              const SizedBox(height: 12),
              _buildDemographicBar(
                'Other',
                demographics.other,
                demographics.total,
                Colors.grey,
              ),
            ],
            const SizedBox(height: 24),
            const Row(
              children: [
                Icon(Icons.groups, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Age Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...demographics.ageGroups.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDemographicBar(
                  entry.key,
                  entry.value,
                  demographics.total,
                  _getAgeGroupColor(entry.key),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopDiagnosesCard(AnalyticsProvider provider) {
    final topDiagnoses = provider.topDiagnoses;
    
    if (topDiagnoses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No diagnosis data available'),
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: topDiagnoses.asMap().entries.map((entry) {
            final index = entry.key;
            final diagnosis = entry.value;
            
            return Column(
              children: [
                if (index > 0) const Divider(height: 24),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getDiagnosisColor(index).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getDiagnosisColor(index),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis.diagnosis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${diagnosis.count} cases',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDiagnosisColor(index).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        diagnosis.count.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getDiagnosisColor(index),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getAgeGroupColor(String ageGroup) {
    switch (ageGroup) {
      case '0-18':
        return Colors.purple;
      case '19-35':
        return Colors.blue;
      case '36-50':
        return Colors.green;
      case '51-65':
        return Colors.orange;
      case '65+':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getDiagnosisColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.blue,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date Range'),
              subtitle: const Text('Filter by custom date range'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showDateRangePicker(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Filters'),
              subtitle: const Text('Show all data'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AnalyticsProvider>().clearDateFilter();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null && mounted) {
      context.read<AnalyticsProvider>().fetchAnalyticsByDateRange(
            picked.start,
            picked.end,
          );
    }
  }
}