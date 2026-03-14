import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  ClinicalAnalyticsQuery _query = const ClinicalAnalyticsQuery();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchClinicalAnalytics(query: _query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_download_outlined),
            onSelected: (value) {
              if (value == 'csv') {
                _exportAnalytics(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'csv',
                child: Text('Export CSV'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnalyticsProvider>().fetchClinicalAnalytics(
                    query: _query,
                  );
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.analytics == null) {
            return const LoadingWidget(message: 'Loading analytics...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchClinicalAnalytics(query: _query),
            );
          }

          final analytics = provider.analytics;
          if (analytics == null) {
            return const Center(
              child: Text('No analytics data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchClinicalAnalytics(query: _query),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCards(analytics.summary),
                const SizedBox(height: 16),
                _buildBreakdownCard('By Status', analytics.breakdowns.byStatus),
                const SizedBox(height: 12),
                _buildBreakdownCard(
                  'By Appointment Type',
                  analytics.breakdowns.byAppointmentType,
                ),
                const SizedBox(height: 12),
                _buildBreakdownCard('By Location', analytics.breakdowns.byLocation),
                const SizedBox(height: 12),
                _buildBreakdownCard(
                  'By Billing Status',
                  analytics.breakdowns.byBillingStatus,
                ),
                const SizedBox(height: 16),
                _buildAppointmentsPreview(analytics.appointments),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(ClinicalAnalyticsSummary summary) {
    Widget tile(String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            tile('Total Appointments', '${summary.totalAppointments}', Colors.blue),
            tile('Total Duration (mins)', '${summary.totalDurationMinutes}', Colors.teal),
            tile('Avg Duration (mins)', summary.averageDurationMinutes.toStringAsFixed(1), Colors.indigo),
            tile('Total Billing', summary.totalBillingAmount.toStringAsFixed(2), Colors.green),
            tile('Avg Billing', summary.averageBillingAmount.toStringAsFixed(2), Colors.orange),
            tile('Scheduled', '${summary.scheduledAppointments}', Colors.purple),
            tile('Completed', '${summary.completedAppointments}', AppColors.success),
            tile('Cancelled', '${summary.cancelledAppointments}', AppColors.error),
            tile('Paid', '${summary.paidAppointments}', Colors.green.shade800),
            tile('Pending', '${summary.pendingAppointments}', AppColors.warning),
            tile('Insured', '${summary.insuredAppointments}', Colors.brown),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(String title, List<AnalyticsBreakdownItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No data')
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.label)),
                      Text(
                        '${item.count}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsPreview(List<AnalyticsAppointmentRow> rows) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments (${rows.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              const Text('No appointments for selected filters')
            else
              ...rows.take(8).map(
                (row) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${row.patientName} • ${row.appointmentType}'),
                  subtitle: Text(
                    '${row.status} • ${row.location} • ${_formatDate(row.scheduledAt, dateFormat)}',
                  ),
                  trailing: Text(row.billingAmount.toStringAsFixed(2)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final startController = TextEditingController(text: _query.startDate ?? '');
    final endController = TextEditingController(text: _query.endDate ?? '');
    final clinicianController = TextEditingController(text: _query.clinicianId ?? '');
    final patientController = TextEditingController(text: _query.patientId ?? '');

    String? status = _query.status;
    String? appointmentType = _query.appointmentType;
    String? location = _query.location;
    String? billingStatus = _query.billingStatus;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Analytics'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: 'End Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any')),
                    ...AnalyticsEnum.status.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() => status = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: appointmentType,
                  decoration: const InputDecoration(
                    labelText: 'Appointment Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any')),
                    ...AnalyticsEnum.appointmentType.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => appointmentType = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any')),
                    ...AnalyticsEnum.location.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (value) => setDialogState(() => location = value),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: billingStatus,
                  decoration: const InputDecoration(
                    labelText: 'Billing Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any')),
                    ...AnalyticsEnum.billingStatus.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => billingStatus = value),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: clinicianController,
                  decoration: const InputDecoration(
                    labelText: 'Clinician ID (ObjectId)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID (ObjectId)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _query = const ClinicalAnalyticsQuery();
                });
                context.read<AnalyticsProvider>().clearAllFilters();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                final q = ClinicalAnalyticsQuery(
                  startDate: startController.text.trim().isEmpty
                      ? null
                      : startController.text.trim(),
                  endDate: endController.text.trim().isEmpty
                      ? null
                      : endController.text.trim(),
                  status: status,
                  clinicianId: clinicianController.text.trim().isEmpty
                      ? null
                      : clinicianController.text.trim(),
                  patientId: patientController.text.trim().isEmpty
                      ? null
                      : patientController.text.trim(),
                  appointmentType: appointmentType,
                  location: location,
                  billingStatus: billingStatus,
                );

                Navigator.pop(dialogContext);
                setState(() {
                  _query = q;
                });
                context.read<AnalyticsProvider>().applyQuery(q);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String value, DateFormat format) {
    if (value.trim().isEmpty) return '-';
    try {
      return format.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  Future<void> _exportAnalytics(BuildContext context) async {
    final provider = context.read<AnalyticsProvider>();

    final bytes = await provider.exportAnalyticsAsCSVBytes(query: _query);

    if (!context.mounted) return;

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Export failed. Please try again.'),
        ),
      );
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      const ext = 'csv';
      const mime = MimeType.csv;
      const customMime = 'text/csv';
      final fileName = 'analytics_$timestamp';

      String savedPath;
      try {
        savedPath = await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: ext,
          mimeType: mime,
          customMimeType: customMime,
        );
      } on MissingPluginException {
        savedPath = await _saveFileFallback(bytes, '$fileName.$ext');
      }

      if (!context.mounted) return;

      final message = (savedPath.toString().isNotEmpty)
          ? 'CSV saved: $savedPath'
          : 'CSV export created. Check your Downloads or Files app.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: ${e.toString()}')),
      );
    }
  }

  Future<String> _saveFileFallback(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      throw Exception('Web fallback is not supported in this build.');
    }

    final home = Platform.environment['HOME'];
    final candidates = <String>[
      if (home != null && home.isNotEmpty) '$home/Downloads/$fileName',
      if (home != null && home.isNotEmpty) '$home/$fileName',
      './$fileName',
      '${Directory.systemTemp.path}/$fileName',
    ];

    final errors = <String>[];

    for (final path in candidates) {
      try {
        final file = File(path);
        await file.parent.create(recursive: true);
        if (!await file.exists()) {
          await file.create();
        }
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      } catch (e) {
        errors.add('$path -> $e');
      }
    }

    throw Exception('Unable to save file on this device. Tried: ${errors.join(' | ')}');
  }
}
