import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/analytics/data/models/analytics_model.dart';
import 'package:frontend/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Clinical Analytics Dashboard Screen
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String? _selectedMetricType;

  @override
  void initState() {
    super.initState();
    // Fetch analytics on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchClinicalAnalytics();
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
                _exportAnalytics(context, format: 'csv');
              } else if (value == 'pdf') {
                _exportAnalytics(context, format: 'pdf');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'csv',
                child: Text('Export CSV'),
              ),
              PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Export PDF'),
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
                metricType: _selectedMetricType,
              );
            },
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.clinicalAnalyticsRecords.isEmpty) {
            return const LoadingWidget(message: 'Loading analytics...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchClinicalAnalytics(),
            );
          }

          if (provider.clinicalAnalyticsRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No analytics data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchClinicalAnalytics(
              metricType: _selectedMetricType,
            ),
            child: Column(
              children: [
                // Metric type filter chips
                if (_selectedMetricType != null)
                  Container(
                    color: AppColors.primary.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtered by: $_selectedMetricType',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedMetricType = null;
                            });
                            provider.clearAllFilters();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                // Analytics records list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.clinicalAnalyticsRecords.length,
                    itemBuilder: (context, index) {
                      final record = provider.clinicalAnalyticsRecords[index];
                      return _buildAnalyticsCard(record);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(ClinicalAnalyticsModel record) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRecordDetails(record),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getMetricColor(record.metricType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getMetricIcon(record.metricType),
                      color: _getMetricColor(record.metricType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.metricType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${_shortId(record.id, 12)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Value display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.data.value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getMetricColor(record.metricType),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Time range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${dateFormat.format(record.data.timeRange.start)} - ${dateFormat.format(record.data.timeRange.end)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Filters (if any)
              if (record.data.filters.clinicianId != null ||
                  record.data.filters.location != null ||
                  record.data.filters.patientAgeGroup != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (record.data.filters.clinicianId != null)
                      _buildFilterChip(
                        'Clinician',
                        _shortId(record.data.filters.clinicianId!, 8),
                        Icons.person,
                      ),
                    if (record.data.filters.location != null)
                      _buildFilterChip(
                        'Location',
                        record.data.filters.location!,
                        Icons.location_on,
                      ),
                    if (record.data.filters.patientAgeGroup != null)
                      _buildFilterChip(
                        'Age Group',
                        record.data.filters.patientAgeGroup!,
                        Icons.groups,
                      ),
                  ],
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Generated time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Generated: ${dateFormat.format(record.generatedAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(String metricType) {
    switch (metricType) {
      case MetricType.appointmentVolume:
        return Colors.blue;
      case MetricType.treatmentOutcomes:
        return Colors.green;
      case MetricType.patientSatisfaction:
        return Colors.orange;
      case MetricType.revenueAnalysis:
        return Colors.purple;
      case MetricType.clinicianPerformance:
        return Colors.teal;
      case MetricType.patientDemographics:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getMetricIcon(String metricType) {
    switch (metricType) {
      case MetricType.appointmentVolume:
        return Icons.calendar_month;
      case MetricType.treatmentOutcomes:
        return Icons.medical_services;
      case MetricType.patientSatisfaction:
        return Icons.sentiment_satisfied;
      case MetricType.revenueAnalysis:
        return Icons.attach_money;
      case MetricType.clinicianPerformance:
        return Icons.people;
      case MetricType.patientDemographics:
        return Icons.groups;
      default:
        return Icons.analytics;
    }
  }

  void _showRecordDetails(ClinicalAnalyticsModel record) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.metricType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', record.id),
              const Divider(),
              _buildDetailRow('Value', record.data.value.toString()),
              const Divider(),
              _buildDetailRow(
                'Time Range',
                '${dateFormat.format(record.data.timeRange.start)}\nto\n${dateFormat.format(record.data.timeRange.end)}',
              ),
              const Divider(),
              _buildDetailRow('Generated At', dateFormat.format(record.generatedAt)),
              _buildDetailRow('Updated At', dateFormat.format(record.updatedAt)),
              if (record.data.filters.clinicianId != null ||
                  record.data.filters.location != null ||
                  record.data.filters.patientAgeGroup != null) ...[
                const Divider(),
                const Text(
                  'Filters:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (record.data.filters.clinicianId != null)
                  _buildDetailRow('Clinician ID', record.data.filters.clinicianId!),
                if (record.data.filters.location != null)
                  _buildDetailRow('Location', record.data.filters.location!),
                if (record.data.filters.patientAgeGroup != null)
                  _buildDetailRow('Age Group', record.data.filters.patientAgeGroup!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
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
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter Analytics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter by Metric Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[
                MetricType.appointmentVolume,
                MetricType.treatmentOutcomes,
                MetricType.patientSatisfaction,
                MetricType.revenueAnalysis,
                MetricType.clinicianPerformance,
                MetricType.patientDemographics,
              ].map((type) => ListTile(
                    leading: Icon(
                      _getMetricIcon(type),
                      color: _getMetricColor(type),
                    ),
                    title: Text(type),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      setState(() {
                        _selectedMetricType = type;
                      });
                      context.read<AnalyticsProvider>().fetchClinicalAnalytics(
                            metricType: type,
                          );
                    },
                  )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear All Filters'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _selectedMetricType = null;
                  });
                  context.read<AnalyticsProvider>().clearAllFilters();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortId(String value, int length) {
    if (value.isEmpty) return value;
    if (value.length <= length) return value;
    return '${value.substring(0, length)}...';
  }

  Future<void> _exportAnalytics(BuildContext context, {required String format}) async {
    final provider = context.read<AnalyticsProvider>();
    final filters = provider.analyticsFilters;
    final metricType = _selectedMetricType;

    Uint8List? bytes;
    if (format == 'pdf') {
      bytes = await provider.exportAnalyticsAsPDFBytes(
        metricType: metricType,
        filters: filters,
      );
    } else {
      bytes = await provider.exportAnalyticsAsCSVBytes(
        metricType: metricType,
        filters: filters,
      );
    }

    if (!context.mounted) return;

    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed. Please try again.')),
      );
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = format == 'pdf' ? 'pdf' : 'csv';
      final mime = format == 'pdf' ? MimeType.pdf : MimeType.csv;
      final customMime = format == 'pdf' ? 'application/pdf' : 'text/csv';
      final fileName = 'clinical_analytics_$timestamp';

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
          ? '${format.toUpperCase()} saved: $savedPath'
          : '${format.toUpperCase()} export created. Check your Downloads or Files app.';

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
