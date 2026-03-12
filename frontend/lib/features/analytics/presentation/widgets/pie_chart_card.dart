import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';

class PieChartCard extends StatelessWidget {
  final AppointmentStatistics? appointmentStats;
  final TreatmentPlanStatistics? treatmentPlanStats;

  const PieChartCard({super.key, this.appointmentStats, this.treatmentPlanStats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: appointmentStats != null ? _buildAppointmentPieChart() : _buildTreatmentPlanPieChart(),
            ),
            const SizedBox(height: 16),
            appointmentStats != null ? _buildAppointmentLegend() : _buildTreatmentPlanLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentPieChart() {
    final stats = appointmentStats!;
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: stats.scheduled.toDouble(), title: '${stats.scheduled}', color: Colors.blue, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.confirmed.toDouble(), title: '${stats.confirmed}', color: Colors.green, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.completed.toDouble(), title: '${stats.completed}', color: Colors.teal, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.cancelled.toDouble(), title: '${stats.cancelled}', color: Colors.red, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          if (stats.noShow > 0) PieChartSectionData(value: stats.noShow.toDouble(), title: '${stats.noShow}', color: Colors.orange, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanPieChart() {
    final stats = treatmentPlanStats!;
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: stats.active.toDouble(), title: '${stats.active}', color: AppColors.success, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.completed.toDouble(), title: '${stats.completed}', color: AppColors.primary, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.onHold.toDouble(), title: '${stats.onHold}', color: AppColors.warning, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
          PieChartSectionData(value: stats.cancelled.toDouble(), title: '${stats.cancelled}', color: AppColors.error, radius: 50, titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildAppointmentLegend() {
    final stats = appointmentStats!;
    return Column(
      children: [
        _buildLegendItem('Scheduled', stats.scheduled, Colors.blue),
        _buildLegendItem('Confirmed', stats.confirmed, Colors.green),
        _buildLegendItem('Completed', stats.completed, Colors.teal),
        _buildLegendItem('Cancelled', stats.cancelled, Colors.red),
        if (stats.noShow > 0) _buildLegendItem('No Show', stats.noShow, Colors.orange),
      ],
    );
  }

  Widget _buildTreatmentPlanLegend() {
    final stats = treatmentPlanStats!;
    return Column(
      children: [
        _buildLegendItem('Active', stats.active, AppColors.success),
        _buildLegendItem('Completed', stats.completed, AppColors.primary),
        _buildLegendItem('On Hold', stats.onHold, AppColors.warning),
        _buildLegendItem('Cancelled', stats.cancelled, AppColors.error),
      ],
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(value.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}