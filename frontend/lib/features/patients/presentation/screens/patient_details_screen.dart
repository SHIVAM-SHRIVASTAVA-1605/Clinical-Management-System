import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/patients/data/models/patient_model.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

// Patient details screen
class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch patient details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatientById(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
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
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Loading details...');
          }

          if (provider.errorMessage != null) {
            return custom.CustomErrorWidget(
              message: provider.errorMessage!,
              onRetry: () => provider.fetchPatientById(widget.patientId),
            );
          }

          final patient = provider.selectedPatient;

          if (patient == null) {
            return const Center(child: Text('Patient not found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(patient),
                const SizedBox(height: 16),
                _buildDemographicsSection(patient),
                const SizedBox(height: 16),
                _buildContactSection(patient),
                const SizedBox(height: 16),
                _buildMedicalHistorySection(patient),
                const SizedBox(height: 16),
                _buildVitalsSection(patient),
                const SizedBox(height: 16),
                _buildEmergencyContactSection(patient),
                const SizedBox(height: 16),
                _buildInsuranceSection(patient),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PatientModel patient) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getGenderColor(patient.demographics.gender).withOpacity(0.8),
            _getGenderColor(patient.demographics.gender),
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
              patient.name.firstName[0] + patient.name.lastName[0],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _getGenderColor(patient.demographics.gender),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            patient.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderChip(
                '${patient.age} years',
                Icons.cake,
              ),
              const SizedBox(width: 8),
              _buildHeaderChip(
                patient.demographics.gender,
                patient.demographics.gender == 'Male' ? Icons.male : Icons.female,
              ),
              const SizedBox(width: 8),
              _buildHeaderChip(
                patient.demographics.bloodGroup,
                Icons.water_drop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection(PatientModel patient) {
    return _buildCard(
      title: 'Demographics',
      icon: Icons.person,
      children: [
        _buildInfoRow('Date of Birth', _formatDate(patient.demographics.dateOfBirth)),
        _buildInfoRow('Age', '${patient.age} years'),
        _buildInfoRow('Gender', patient.demographics.gender),
        _buildInfoRow('Blood Group', patient.demographics.bloodGroup),
        if (patient.demographics.maritalStatus != null)
          _buildInfoRow('Marital Status', patient.demographics.maritalStatus!),
        if (patient.demographics.occupation != null)
          _buildInfoRow('Occupation', patient.demographics.occupation!),
      ],
    );
  }

  Widget _buildContactSection(PatientModel patient) {
    return _buildCard(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        _buildInfoRow('Email', patient.contact.email),
        _buildInfoRow('Phone', patient.contact.phone),
        if (patient.contact.alternatePhone != null)
          _buildInfoRow('Alternate Phone', patient.contact.alternatePhone!),
        _buildInfoRow('Address', patient.contact.address.fullAddress),
      ],
    );
  }

  Widget _buildMedicalHistorySection(PatientModel patient) {
    final history = patient.medicalHistory;
    
    return _buildCard(
      title: 'Medical History',
      icon: Icons.medical_services,
      children: [
        if (history.allergies.isNotEmpty) ...[
          _buildSubHeading('Allergies'),
          ...history.allergies.map((allergy) => _buildBulletPoint(allergy, AppColors.error)),
          const SizedBox(height: 12),
        ],
        if (history.chronicConditions.isNotEmpty) ...[
          _buildSubHeading('Chronic Conditions'),
          ...history.chronicConditions.map((condition) => _buildBulletPoint(condition, AppColors.warning)),
          const SizedBox(height: 12),
        ],
        if (history.currentMedications.isNotEmpty) ...[
          _buildSubHeading('Current Medications'),
          ...history.currentMedications.map((med) => _buildBulletPoint(med, AppColors.info)),
        ],
        if (history.allergies.isEmpty && 
            history.chronicConditions.isEmpty && 
            history.currentMedications.isEmpty)
          const Center(
            child: Text(
              'No medical history recorded',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildVitalsSection(PatientModel patient) {
    final history = patient.medicalHistory;
    final bmi = history.bmi;
    
    return _buildCard(
      title: 'Vital Signs',
      icon: Icons.favorite,
      children: [
        if (history.bloodPressure != null)
          _buildVitalCard('Blood Pressure', history.bloodPressure!, Icons.water_drop, AppColors.error),
        if (history.height != null && history.weight != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildVitalCard('Height', '${history.height} cm', Icons.height, AppColors.info),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard('Weight', '${history.weight} kg', Icons.monitor_weight, AppColors.warning),
              ),
            ],
          ),
          if (bmi != null) ...[
            const SizedBox(height: 12),
            _buildVitalCard('BMI', bmi.toStringAsFixed(1), Icons.analytics, _getBMIColor(bmi)),
          ],
        ],
      ],
    );
  }

  Widget _buildEmergencyContactSection(PatientModel patient) {
    final emergency = patient.emergencyContact;
    
    if (emergency == null) {
      return _buildCard(
        title: 'Emergency Contact',
        icon: Icons.emergency,
        children: [
          const Center(
            child: Text(
              'No emergency contact added',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }
    
    return _buildCard(
      title: 'Emergency Contact',
      icon: Icons.emergency,
      children: [
        _buildInfoRow('Name', emergency.name),
        _buildInfoRow('Relationship', emergency.relationship),
        _buildInfoRow('Phone', emergency.phone),
      ],
    );
  }

  Widget _buildInsuranceSection(PatientModel patient) {
    final insurance = patient.insurance;
    
    if (insurance == null) {
      return _buildCard(
        title: 'Insurance',
        icon: Icons.shield,
        children: [
          const Center(
            child: Text(
              'No insurance information',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }
    
    return _buildCard(
      title: 'Insurance',
      icon: Icons.shield,
      children: [
        _buildInfoRow('Provider', insurance.provider),
        _buildInfoRow('Policy Number', insurance.policyNumber),
        if (insurance.expiryDate != null)
          _buildInfoRow('Expiry Date', _formatDate(insurance.expiryDate)),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue;
      case 'female':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient? This action cannot be undone.'),
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
              
              final provider = context.read<PatientProvider>();
              final success = await provider.deletePatient(widget.patientId);
              
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Patient deleted successfully' 
                        : provider.errorMessage ?? 'Failed to delete patient'
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