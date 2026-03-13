import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/patients/data/models/patient_model.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:provider/provider.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;
    final clinicianId = currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '_id (Out Patient ID)',
                hintText: 'e.g. OP1001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fingerprint),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter patient _id';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter patient name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: (value) {
                final age = int.tryParse(value ?? '');
                if (age == null || age <= 0) {
                  return 'Please enter valid age';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone No.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              initialValue: clinicianId,
              decoration: const InputDecoration(
                labelText: 'Clinician ID (Auto)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      _savePatient(clinicianId);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Patient'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePatient(String clinicianId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (clinicianId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to identify clinician. Please login again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final patient = PatientModel(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      address: _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      clinicianId: clinicianId,
      createdAt: DateTime.now(),
    );

    final response = await context.read<PatientProvider>().addPatient(patient);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    final success = response['success'] == true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message']?.toString() ?? ''),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }
}
