import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/clinicians/presentation/providers/clinician_provider.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:provider/provider.dart';

// Book appointment screen
class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? _selectedPatientId;
  String? _selectedClinicianId;
  String _appointmentType = AppointmentType.consultation;
  String _location = AppointmentLocation.mainClinic;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 30;
  String _notes = '';
  double _amount = 150.0;

  @override
  void initState() {
    super.initState();
    // Fetch patients and clinicians
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
      context.read<ClinicianProvider>().fetchClinicians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Participants'),
            const SizedBox(height: 12),
            _buildPatientDropdown(),
            const SizedBox(height: 16),
            _buildClinicianDropdown(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Appointment Details'),
            const SizedBox(height: 12),
            _buildAppointmentTypeDropdown(),
            const SizedBox(height: 16),
            _buildLocationDropdown(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Schedule'),
            const SizedBox(height: 12),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTimePicker(),
            const SizedBox(height: 16),
            _buildDurationDropdown(),
            
            const SizedBox(height: 24),
            _buildSectionTitle('Additional Information'),
            const SizedBox(height: 12),
            _buildNotesField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            
            const SizedBox(height: 32),
            _buildBookButton(),
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
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LinearProgressIndicator();
        }

        final patients = provider.patients;

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Patient',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          value: _selectedPatientId,
          items: patients.map((patient) {
            return DropdownMenuItem(
              value: patient.id,
              child: Text(patient.fullName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPatientId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a patient';
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

  Widget _buildAppointmentTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Appointment Type',
        prefixIcon: Icon(Icons.event),
        border: OutlineInputBorder(),
      ),
      value: _appointmentType,
      items: AppointmentType.all.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _appointmentType = value!;
          // Adjust duration and amount based on type
          if (value == AppointmentType.procedure) {
            _duration = 60;
            _amount = 500.0;
          } else {
            _duration = 30;
            _amount = 150.0;
          }
        });
      },
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Location',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
      value: _location,
      items: AppointmentLocation.all.map((location) {
        return DropdownMenuItem(
          value: location,
          child: Text(location),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _location = value!;
        });
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time',
          prefixIcon: Icon(Icons.access_time),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedTime.format(context),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Duration (minutes)',
        prefixIcon: Icon(Icons.timelapse),
        border: OutlineInputBorder(),
      ),
      value: _duration,
      items: [15, 30, 45, 60, 90, 120].map((duration) {
        return DropdownMenuItem(
          value: duration,
          child: Text('$duration minutes'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _duration = value!;
        });
      },
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
      maxLines: 3,
      onChanged: (value) {
        _notes = value;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Amount (\$)',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      initialValue: _amount.toString(),
      onChanged: (value) {
        _amount = double.tryParse(value) ?? 150.0;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildBookButton() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ElevatedButton(
          onPressed: _bookAppointment,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get patient and clinician names
    final patientProvider = context.read<PatientProvider>();
    final clinicianProvider = context.read<ClinicianProvider>();
    
    final patient = patientProvider.patients.firstWhere(
      (p) => p.id == _selectedPatientId,
    );
    final clinician = clinicianProvider.clinicians.firstWhere(
      (c) => c.id == _selectedClinicianId,
    );

    // Combine date and time
    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Create appointment
    final appointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatientId!,
      clinicianId: _selectedClinicianId!,
      appointmentType: _appointmentType,
      status: AppointmentStatus.scheduled,
      scheduledAt: scheduledAt,
      duration: _duration,
      location: _location,
      notes: _notes.isEmpty ? null : _notes,
      billing: BillingInfo(
        amount: _amount,
        status: 'Pending',
        insuranceDetails: patient.insurance != null
            ? InsuranceDetails(
                provider: patient.insurance!.provider,
                policyNumber: patient.insurance!.policyNumber,
              )
            : null,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientName: patient.fullName,
      clinicianName: '${clinician.name.title} ${clinician.name.firstName} ${clinician.name.lastName}',
    );

    // Book appointment
    final provider = context.read<AppointmentProvider>();
    final success = await provider.addAppointment(appointment);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to book appointment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}