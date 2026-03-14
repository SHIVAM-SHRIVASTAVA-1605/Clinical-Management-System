import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/appointments/data/models/appointment_model.dart';
import 'package:frontend/features/appointments/presentations/provider/appointment_provider.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/clinicians/data/models/clinician_model.dart';
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
  String _selectedClinicianName = '';
  String _appointmentType = AppointmentType.consultation;
  String? _location;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duration = 30;
  String _notes = '';
  double _amount = 150.0;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _selectedClinicianId = user?.id;
    _selectedClinicianName = user?.name ?? 'Current Clinician';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
      if (_selectedClinicianId != null && _selectedClinicianId!.isNotEmpty) {
        context
            .read<AppointmentProvider>()
            .fetchAppointmentsByClinicianId(_selectedClinicianId!);
        context
            .read<ClinicianProvider>()
            .fetchClinicianById(_selectedClinicianId!);
      }
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
            _buildPatientIdField(),
            const SizedBox(height: 16),
            _buildAssignedClinicianField(),
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

  Widget _buildPatientIdField() {
    return Consumer2<PatientProvider, AuthProvider>(
      builder: (context, patientProvider, authProvider, child) {
        if (patientProvider.isLoading) {
          return const LinearProgressIndicator();
        }

        final clinicianId = authProvider.user?.id ?? '';
        final myPatients =
            patientProvider.getPatientsByClinicianId(clinicianId);

        if (myPatients.isEmpty) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Patient',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            child: Text(
              'No patients found. Add a patient first.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Patient',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          value: _selectedPatientId,
          hint: const Text('Select a patient'),
          items: myPatients
              .map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name}  (${p.id})'),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedPatientId = value),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please select a patient' : null,
        );
      },
    );
  }

  Widget _buildAssignedClinicianField() {
    return TextFormField(
      readOnly: true,
      initialValue: _selectedClinicianName,
      decoration: const InputDecoration(
        labelText: 'Healthcare Provider (Assigned)',
        prefixIcon: Icon(Icons.medical_services),
        border: OutlineInputBorder(),
      ),
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
    return Consumer<ClinicianProvider>(
      builder: (context, clinicianProvider, child) {
        final clinician = clinicianProvider.selectedClinician;
        final availableLocations = _availableLocationsFromClinician(clinician);

        if (availableLocations.isEmpty) {
          return InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            child: Text(
              'No available location configured for this clinician.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          );
        }

        if (_location == null || !availableLocations.contains(_location)) {
          _location = availableLocations.first;
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          value: _location,
          items: availableLocations.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _location = value;
            });
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
        );
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

    final currentUser = context.read<AuthProvider>().user;
    _selectedClinicianId = currentUser?.id;
    _selectedClinicianName = currentUser?.name ?? _selectedClinicianName;

    // Validate patient and clinician selection
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedClinicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Unable to identify current clinician. Please login again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_location == null || _location!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location from clinician availability.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Combine date and time
    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (!scheduledAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a future date/time for the appointment.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final clinicianProvider = context.read<ClinicianProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();

    await clinicianProvider.fetchClinicianById(_selectedClinicianId!);
    if (!mounted) return;

    final clinician = clinicianProvider.selectedClinician;
    if (clinician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            clinicianProvider.errorMessage ??
                'Unable to fetch clinician details for availability check.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isWithinAvailability(
      scheduledAt: scheduledAt,
      durationMinutes: _duration,
      availability: clinician.availability,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Clinician is not available for this date/time slot. Please choose another slot.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await appointmentProvider.fetchAppointmentsByClinicianId(
      _selectedClinicianId!,
    );
    if (!mounted) return;

    if (_hasOverlappingBooking(
      scheduledAt: scheduledAt,
      durationMinutes: _duration,
      clinicianId: _selectedClinicianId!,
      existingAppointments: appointmentProvider.appointments,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already have one booking at this time.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create appointment
    final appointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: _selectedPatientId!,
      clinicianId: _selectedClinicianId!,
      appointmentType: _appointmentType,
      status: AppointmentStatus.scheduled,
      scheduledAt: scheduledAt,
      duration: _duration,
      location: _location!,
      notes: _notes,
      billing: BillingInfo(
        amount: _amount,
        status: BillingStatus.pending,
        insuranceDetails:
            const InsuranceDetails(provider: null, policyNumber: null),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      patientName: 'Patient ID: $_selectedPatientId',
      clinicianName: _selectedClinicianName,
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
            content:
                Text(provider.errorMessage ?? 'Failed to book appointment'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _isWithinAvailability({
    required DateTime scheduledAt,
    required int durationMinutes,
    required List<ClinicianAvailability> availability,
  }) {
    if (availability.isEmpty) return false;

    final targetDay = _weekdayName(scheduledAt.weekday).toLowerCase();
    final appointmentStart = scheduledAt.hour * 60 + scheduledAt.minute;
    final appointmentEnd = appointmentStart + durationMinutes;

    for (final slot in availability) {
      if (slot.dayOfWeek.trim().toLowerCase() != targetDay) continue;

      final slotStart = _parseTimeToMinutes(slot.startTime);
      final slotEnd = _parseTimeToMinutes(slot.endTime);
      if (slotStart == null || slotEnd == null) continue;

      if (appointmentStart >= slotStart && appointmentEnd <= slotEnd) {
        return true;
      }
    }

    return false;
  }

  bool _hasOverlappingBooking({
    required DateTime scheduledAt,
    required int durationMinutes,
    required String clinicianId,
    required List<AppointmentModel> existingAppointments,
  }) {
    final newStart = scheduledAt;
    final newEnd = scheduledAt.add(Duration(minutes: durationMinutes));

    for (final appointment in existingAppointments) {
      if (appointment.clinicianId != clinicianId) continue;
      if (appointment.status.trim().toLowerCase() == 'cancelled') continue;

      final sameDay = appointment.scheduledAt.year == newStart.year &&
          appointment.scheduledAt.month == newStart.month &&
          appointment.scheduledAt.day == newStart.day;
      if (!sameDay) continue;

      final existingStart = appointment.scheduledAt;
      final existingEnd = appointment.scheduledAt
          .add(Duration(minutes: appointment.duration));

      final overlaps = newStart.isBefore(existingEnd) &&
          newEnd.isAfter(existingStart);
      if (overlaps) return true;
    }

    return false;
  }

  int? _parseTimeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  String _weekdayName(int weekday) {
    const names = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  List<String> _availableLocationsFromClinician(ClinicianModel? clinician) {
    if (clinician == null) return const <String>[];

    final unique = <String>[];
    for (final slot in clinician.availability) {
      final location = slot.location.trim();
      if (location.isEmpty) continue;
      if (!unique.contains(location)) {
        unique.add(location);
      }
    }
    return unique;
  }
}
