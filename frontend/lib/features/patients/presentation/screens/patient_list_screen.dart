import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:frontend/features/patients/presentation/providers/patient_provider.dart';
import 'package:provider/provider.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final clinicianId = user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addPatient);
          if (context.mounted) {
            context.read<PatientProvider>().fetchPatients();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final myPatients = provider.getPatientsByClinicianId(clinicianId);

          if (myPatients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No patients yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + Add Patient to register a new patient',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myPatients.length,
            itemBuilder: (context, index) {
              final patient = myPatients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      patient.name.isNotEmpty
                          ? patient.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${patient.id}  •  Age: ${patient.age}  •  ${patient.phoneNumber}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete patient',
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Patient'),
                                content: Text(
                                  'Are you sure you want to delete ${patient.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;

                      if (!shouldDelete || !context.mounted) return;

                      final result = await context
                          .read<PatientProvider>()
                          .deletePatient(patient.id);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message']?.toString() ??
                                'Unable to delete patient.',
                          ),
                          backgroundColor: result['success'] == true
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
