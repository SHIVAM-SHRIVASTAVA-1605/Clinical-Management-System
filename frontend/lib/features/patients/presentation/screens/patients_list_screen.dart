import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../../../auth/presentations/providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../../data/models/patient_model.dart';

// Patients list screen
class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch patients on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<PatientProvider>().searchPatients(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _handleSearch,
            ),
          ),

          // Patients List
          Expanded(
            child: Consumer2<PatientProvider, AuthProvider>(
              builder: (context, patientProvider, authProvider, child) {
                if (patientProvider.isLoading && patientProvider.patients.isEmpty) {
                  return const LoadingWidget(message: 'Loading patients...');
                }

                if (patientProvider.errorMessage != null) {
                  return custom.CustomErrorWidget(
                    message: patientProvider.errorMessage!,
                    onRetry: () => patientProvider.fetchPatients(),
                  );
                }

                // Filter patients based on user role
                final user = authProvider.user;
                final allPatients = patientProvider.patients;
                final filteredPatients = user?.isClinician == true
                    ? allPatients.where((patient) => 
                        patient.assignedClinicianIds.contains(user!.id)).toList()
                    : allPatients;

                if (filteredPatients.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.person_outline,
                    message: _searchController.text.isEmpty
                        ? 'No patients found'
                        : 'No results for "${_searchController.text}"',
                    actionLabel: 'Add Patient',
                    onAction: () {
                      Navigator.pushNamed(context, AppRoutes.addPatient);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => patientProvider.fetchPatients(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return _buildPatientCard(context, patient);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addPatient);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, PatientModel patient) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.patientDetails,
            arguments: patient.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: _getGenderColor(patient.demographics.gender).withOpacity(0.1),
                child: Text(
                  patient.name.firstName[0] + patient.name.lastName[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getGenderColor(patient.demographics.gender),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBloodGroupColor(patient.demographics.bloodGroup).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            patient.demographics.bloodGroup,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getBloodGroupColor(patient.demographics.bloodGroup),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          patient.demographics.gender == 'Male' ? Icons.male : Icons.female,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${patient.age} years • ${patient.demographics.gender}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            patient.contact.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
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

  Color _getBloodGroupColor(String bloodGroup) {
    if (bloodGroup.contains('+')) {
      return AppColors.error;
    } else if (bloodGroup.contains('-')) {
      return AppColors.warning;
    }
    return AppColors.info;
  }
}