import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/clinicians/presentation/providers/clinician_provider.dart';
import 'package:frontend/features/treatment_plans/data/models/treatment_plan_model.dart';
import 'package:frontend/features/treatment_plans/presentations/providers/treatment_plan_provider.dart';
import 'package:provider/provider.dart';

// Create Treatment Plan screen
class CreateTreatmentPlanScreen extends StatefulWidget {
  const CreateTreatmentPlanScreen({super.key});

  @override
  State<CreateTreatmentPlanScreen> createState() => _CreateTreatmentPlanScreenState();
}

class _CreateTreatmentPlanScreenState extends State<CreateTreatmentPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? _selectedPatientId;
  String? _selectedClinicianId;
  String _diagnosis = '';
  String _status = TreatmentPlanStatus.active;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _notes = '';
  
  // Prescriptions and Care Instructions
  final List<Prescription> _prescriptions = [];
  final List<CareInstruction> _careInstructions = [];

  @override
  void initState() {
    super.initState();
    // Fetch appointments and clinicians
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
      context.read<ClinicianProvider>().fetchClinicians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Treatment Plan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _buildPatientDropdown(),
            const SizedBox(height: 16),
            _buildClinicianDropdown(),
            const SizedBox(height: 16),
            _buildDiagnosisField(),
            const SizedBox(height: 16),
            _buildStatusDropdown(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Treatment Duration'),
            const SizedBox(height: 12),
            _buildStartDatePicker(),
            const SizedBox(height: 16),
            _buildEndDatePicker(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Prescriptions'),
            const SizedBox(height: 12),
            _buildPrescriptionsList(),
            const SizedBox(height: 12),
            _buildAddPrescriptionButton(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Care Instructions'),
            const SizedBox(height: 12),
            _buildCareInstructionsList(),
            const SizedBox(height: 12),
            _buildAddCareInstructionButton(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Notes'),
            const SizedBox(height: 12),
            _buildNotesField(),
            
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
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LinearProgressIndicator();
        }

        final patientIds = provider.appointments
            .map((appointment) => appointment.patientId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Patient ID',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          value: _selectedPatientId,
          items: patientIds.map((patientId) {
            return DropdownMenuItem(
              value: patientId,
              child: Text(patientId),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPatientId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a patient ID';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildClinicianDropdown() {
    return Consumer<ClinicianProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LinearProgressIndicator();
        }

        final clinicians = provider.clinicians;

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Healthcare Provider',
            prefixIcon: Icon(Icons.medical_services),
            border: OutlineInputBorder(),
          ),
          value: _selectedClinicianId,
          items: clinicians.map((clinician) {
            return DropdownMenuItem(
              value: clinician.id,
              child: Text('${clinician.name.title} ${clinician.name.firstName} ${clinician.name.lastName}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedClinicianId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a healthcare provider';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDiagnosisField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Diagnosis',
        prefixIcon: Icon(Icons.medical_information),
        border: OutlineInputBorder(),
        hintText: 'e.g., Hypertension, Type 2 Diabetes',
      ),
      onChanged: (value) {
        _diagnosis = value;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter diagnosis';
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.flag),
        border: OutlineInputBorder(),
      ),
      value: _status,
      items: TreatmentPlanStatus.all.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
    );
  }

  Widget _buildStartDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (date != null) {
          setState(() {
            _startDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Start Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEndDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
          firstDate: _startDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
        );
        
        if (date != null) {
          setState(() {
            _endDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'End Date (Optional)',
          prefixIcon: const Icon(Icons.event_available),
          border: const OutlineInputBorder(),
          suffixIcon: _endDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _endDate = null;
                    });
                  },
                )
              : null,
        ),
        child: Text(
          _endDate != null
              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
              : 'Ongoing',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    if (_prescriptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            'No prescriptions added yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: _prescriptions.asMap().entries.map((entry) {
        final index = entry.key;
        final prescription = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.medication, color: Colors.purple),
            title: Text(prescription.medicationName),
            subtitle: Text('${prescription.dosage} - ${prescription.frequency}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                setState(() {
                  _prescriptions.removeAt(index);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddPrescriptionButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddPrescriptionDialog(),
      icon: const Icon(Icons.add),
      label: const Text('Add Prescription'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildCareInstructionsList() {
    if (_careInstructions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            'No care instructions added yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: _careInstructions.asMap().entries.map((entry) {
        final index = entry.key;
        final instruction = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(_getCategoryIcon(instruction.category), color: Colors.orange),
            title: Text(instruction.instruction),
            subtitle: Text('${instruction.category} ${instruction.frequency != null ? "- ${instruction.frequency}" : ""}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                setState(() {
                  _careInstructions.removeAt(index);
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddCareInstructionButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddCareInstructionDialog(),
      icon: const Icon(Icons.add),
      label: const Text('Add Care Instruction'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      onChanged: (value) {
        _notes = value;
      },
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Create Treatment Plan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  void _showAddPrescriptionDialog() {
    String medicationName = '';
    String dosage = '';
    String frequency = PrescriptionFrequency.onceDailyl;
    String duration = '';
    String instructions = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Prescription'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => medicationName = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Dosage (e.g., 10mg)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => dosage = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                value: frequency,
                items: PrescriptionFrequency.all.map((freq) {
                  return DropdownMenuItem(value: freq, child: Text(freq));
                }).toList(),
                onChanged: (value) => frequency = value!,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 30 days)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => duration = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Instructions (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => instructions = value,
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
              if (medicationName.isNotEmpty && dosage.isNotEmpty && duration.isNotEmpty) {
                setState(() {
                  _prescriptions.add(Prescription(
                    medicationName: medicationName,
                    dosage: dosage,
                    frequency: frequency,
                    duration: duration,
                    instructions: instructions.isEmpty ? null : instructions,
                  ));
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddCareInstructionDialog() {
    String instruction = '';
    String category = CareCategory.diet;
    String frequency = '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Care Instruction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Instruction',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => instruction = value,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: category,
                items: CareCategory.all.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) => category = value!,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Frequency (e.g., Daily)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => frequency = value,
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
              if (instruction.isNotEmpty) {
                setState(() {
                  _careInstructions.add(CareInstruction(
                    instruction: instruction,
                    category: category,
                    frequency: frequency.isEmpty ? null : frequency,
                  ));
                });
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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

  Future<void> _createTreatmentPlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_prescriptions.isEmpty && _careInstructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one prescription or care instruction'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Get clinician name
    final clinicianProvider = context.read<ClinicianProvider>();
    final clinician = clinicianProvider.clinicians.firstWhere((c) => c.id == _selectedClinicianId);

    // Create treatment plan
    final treatmentPlan = TreatmentPlanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatientId!,
      clinicianId: _selectedClinicianId!,
      diagnosis: _diagnosis,
      status: _status,
      startDate: _startDate,
      endDate: _endDate,
      prescriptions: _prescriptions,
      careInstructions: _careInstructions,
      notes: _notes.isEmpty ? null : _notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientName: 'Patient ID: $_selectedPatientId',
      clinicianName: '${clinician.name.title} ${clinician.name.firstName} ${clinician.name.lastName}',
    );

    // Create treatment plan
    final provider = context.read<TreatmentPlanProvider>();
    final success = await provider.addTreatmentPlan(treatmentPlan);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment plan created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create treatment plan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}