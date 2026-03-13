import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';

class CreateTreatmentPlanScreen extends StatefulWidget {
  const CreateTreatmentPlanScreen({super.key});

  @override
  State<CreateTreatmentPlanScreen> createState() =>
      _CreateTreatmentPlanScreenState();
}

class _CreateTreatmentPlanScreenState extends State<CreateTreatmentPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPatientId;
  String? _selectedClinicianId;
  String _selectedClinicianName = '';

  String _condition = '';
  String _icd10Code = '';
  DateTime _diagnosedAt = DateTime.now();

  final List<Prescription> _prescriptions = [];
  final List<FollowUp> _followUps = [];
  final List<String> _lifestyleChanges = [];
  final List<Referral> _referrals = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _selectedClinicianId = user?.id;
    _selectedClinicianName = user?.name ?? 'Current Clinician';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Treatment Plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildPatientDropdown(),
            const SizedBox(height: 16),
            _buildAssignedClinicianField(),
            const SizedBox(height: 16),
            _buildConditionField(),
            const SizedBox(height: 16),
            _buildIcd10Field(),
            const SizedBox(height: 16),
            _buildDiagnosedAtPicker(),
            const SizedBox(height: 24),
            _buildSectionTitle('Prescriptions'),
            const SizedBox(height: 12),
            _buildPrescriptionsList(),
            const SizedBox(height: 12),
            _buildAddPrescriptionButton(),
            const SizedBox(height: 24),
            _buildSectionTitle('Follow-Ups'),
            const SizedBox(height: 12),
            _buildFollowUpsList(),
            const SizedBox(height: 12),
            _buildAddFollowUpButton(),
            const SizedBox(height: 24),
            _buildSectionTitle('Recommendations'),
            const SizedBox(height: 12),
            _buildLifestyleChangesList(),
            const SizedBox(height: 12),
            _buildAddLifestyleChangeButton(),
            const SizedBox(height: 16),
            _buildReferralsList(),
            const SizedBox(height: 12),
            _buildAddReferralButton(),
            const SizedBox(height: 32),
            _buildCreateButton(),
            const SizedBox(height: 16),
          ],
        ),
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

  Widget _buildPatientDropdown() {
    return Consumer2<AppointmentProvider, AuthProvider>(
      builder: (context, provider, authProvider, child) {
        if (provider.isLoading) {
          return const LinearProgressIndicator();
        }

        final currentUser = authProvider.user;
        final myAppointments = currentUser == null
            ? provider.appointments
            : provider.appointments
                .where(
                    (appointment) => appointment.clinicianId == currentUser.id)
                .toList();

        final patientIds = myAppointments
            .map((appointment) => appointment.patientId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Patient ID',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          value: _selectedPatientId,
          items: patientIds
              .map((patientId) => DropdownMenuItem(
                    value: patientId,
                    child: Text(patientId),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedPatientId = value),
          validator: (value) => value == null || value.isEmpty
              ? 'Please select a patient ID'
              : null,
        );
      },
    );
  }

  Widget _buildAssignedClinicianField() {
    return TextFormField(
      readOnly: true,
      initialValue: _selectedClinicianName,
      decoration: const InputDecoration(
        labelText: 'Clinician (Assigned)',
        prefixIcon: Icon(Icons.medical_services),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildConditionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Condition',
        hintText: 'e.g., Hypertension',
        prefixIcon: Icon(Icons.medical_information),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => _condition = value.trim(),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Please enter condition'
          : null,
    );
  }

  Widget _buildIcd10Field() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'ICD-10 Code',
        hintText: 'e.g., I10, E11.9',
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => _icd10Code = value.trim(),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Please enter ICD-10 code'
          : null,
    );
  }

  Widget _buildDiagnosedAtPicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _diagnosedAt,
          firstDate: DateTime.now().subtract(const Duration(days: 3650)),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _diagnosedAt = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Diagnosed At',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_diagnosedAt.day}/${_diagnosedAt.month}/${_diagnosedAt.year}',
        ),
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    if (_prescriptions.isEmpty) {
      return _buildEmptyBox('No prescriptions added yet');
    }

    return Column(
      children: _prescriptions.asMap().entries.map((entry) {
        final index = entry.key;
        final p = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.medication, color: Colors.indigo),
            title: Text(p.medication),
            subtitle: Text('${p.dosage} • ${p.frequency}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => setState(() => _prescriptions.removeAt(index)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddPrescriptionButton() {
    return OutlinedButton.icon(
      onPressed: _showAddPrescriptionDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Prescription'),
    );
  }

  Widget _buildFollowUpsList() {
    if (_followUps.isEmpty) {
      return _buildEmptyBox('No follow-ups added yet');
    }

    return Column(
      children: _followUps.asMap().entries.map((entry) {
        final index = entry.key;
        final f = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.event_repeat, color: Colors.teal),
            title: Text(f.purpose),
            subtitle: Text(
              '${f.scheduledDate.day}/${f.scheduledDate.month}/${f.scheduledDate.year} • ${f.status}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => setState(() => _followUps.removeAt(index)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddFollowUpButton() {
    return OutlinedButton.icon(
      onPressed: _showAddFollowUpDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Follow-Up'),
    );
  }

  Widget _buildLifestyleChangesList() {
    if (_lifestyleChanges.isEmpty) {
      return _buildEmptyBox('No lifestyle changes added yet');
    }

    return Column(
      children: _lifestyleChanges.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.self_improvement, color: Colors.blue),
            title: Text(text),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () =>
                  setState(() => _lifestyleChanges.removeAt(index)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddLifestyleChangeButton() {
    return OutlinedButton.icon(
      onPressed: _showAddLifestyleChangeDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Lifestyle Change'),
    );
  }

  Widget _buildReferralsList() {
    if (_referrals.isEmpty) {
      return _buildEmptyBox('No referrals added yet');
    }

    return Column(
      children: _referrals.asMap().entries.map((entry) {
        final index = entry.key;
        final referral = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.outbound, color: Colors.deepPurple),
            title: Text(referral.specialist),
            subtitle: Text(referral.reason),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => setState(() => _referrals.removeAt(index)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddReferralButton() {
    return OutlinedButton.icon(
      onPressed: _showAddReferralDialog,
      icon: const Icon(Icons.add),
      label: const Text('Add Referral'),
    );
  }

  Widget _buildCreateButton() {
    return Consumer<TreatmentPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ElevatedButton(
          onPressed: _createTreatmentPlan,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Create Treatment Plan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  void _showAddPrescriptionDialog() {
    String medication = '';
    String dosage = '';
    String frequency = PrescriptionFrequency.onceDaily;
    DateTime startDate = DateTime.now();
    DateTime? endDate;
    String instructions = '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Prescription'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Medication',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => medication = value.trim(),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => dosage = value.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  value: frequency,
                  items: PrescriptionFrequency.all
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      frequency = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Start Date'),
                  subtitle: Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: startDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 3650)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available),
                  title: const Text('End Date (Optional)'),
                  subtitle: Text(
                    endDate == null
                        ? 'Ongoing'
                        : '${endDate!.day}/${endDate!.month}/${endDate!.year}',
                  ),
                  trailing: endDate == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setDialogState(() => endDate = null),
                        ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: endDate ?? startDate,
                      firstDate: startDate,
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => instructions = value.trim(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (medication.isEmpty ||
                    dosage.isEmpty ||
                    instructions.isEmpty) {
                  return;
                }
                setState(() {
                  _prescriptions.add(
                    Prescription(
                      medication: medication,
                      dosage: dosage,
                      frequency: frequency,
                      startDate: startDate,
                      endDate: endDate,
                      instructions: instructions,
                    ),
                  );
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFollowUpDialog() {
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 7));
    String purpose = '';
    String status = FollowUpStatus.pending;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Follow-Up'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Scheduled Date'),
                  subtitle: Text(
                    '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: scheduledDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setDialogState(() => scheduledDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Purpose',
                    hintText: 'e.g., Monitor Medication',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => purpose = value.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: status,
                  items: FollowUpStatus.all
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      status = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (purpose.isEmpty) {
                  return;
                }
                setState(() {
                  _followUps.add(
                    FollowUp(
                      scheduledDate: scheduledDate,
                      purpose: purpose,
                      status: status,
                    ),
                  );
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLifestyleChangeDialog() {
    String change = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Lifestyle Change'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Lifestyle Change',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) => change = value.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (change.isEmpty) {
                return;
              }
              setState(() => _lifestyleChanges.add(change));
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddReferralDialog() {
    String specialist = '';
    String reason = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Referral'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Specialist',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => specialist = value.trim(),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => reason = value.trim(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (specialist.isEmpty || reason.isEmpty) {
                return;
              }
              setState(() {
                _referrals
                    .add(Referral(specialist: specialist, reason: reason));
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTreatmentPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentUser = context.read<AuthProvider>().user;
    _selectedClinicianId = currentUser?.id;
    _selectedClinicianName = currentUser?.name ?? _selectedClinicianName;

    if (_prescriptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one prescription'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_selectedClinicianId == null || _selectedClinicianId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Unable to identify current clinician. Please login again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final treatmentPlan = TreatmentPlanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatientId!,
      clinicianId: _selectedClinicianId!,
      diagnosis: Diagnosis(
        condition: _condition,
        diagnosedAt: _diagnosedAt,
        icd10Code: _icd10Code,
      ),
      prescriptions: _prescriptions,
      followUps: _followUps,
      recommendations: Recommendations(
        lifestyleChanges: _lifestyleChanges,
        referrals: _referrals,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientName: 'Patient ID: $_selectedPatientId',
      clinicianName: _selectedClinicianName,
    );

    final provider = context.read<TreatmentPlanProvider>();
    final success = await provider.addTreatmentPlan(treatmentPlan);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treatment plan created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(provider.errorMessage ?? 'Failed to create treatment plan'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
