import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/core/widgets/loading_widget.dart';
import 'package:frontend/features/clinicians/data/models/clinician_model.dart';
import 'package:frontend/features/clinicians/presentation/providers/clinician_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/error_widget.dart' as custom;

// Clinicians list screen
class CliniciansListScreen extends StatefulWidget {
  const CliniciansListScreen({super.key});

  @override
  State<CliniciansListScreen> createState() => _CliniciansListScreenState();
}

class _CliniciansListScreenState extends State<CliniciansListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch clinicians on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicianProvider>().fetchClinicians();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    context.read<ClinicianProvider>().searchClinicians(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinicians'),
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
                hintText: 'Search by name or specialty...',
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

          // Clinicians List
          Expanded(
            child: Consumer<ClinicianProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.clinicians.isEmpty) {
                  return const LoadingWidget(message: 'Loading clinicians...');
                }

                if (provider.errorMessage != null) {
                  return custom.CustomErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: () => provider.fetchClinicians(),
                  );
                }

                if (provider.clinicians.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.medical_services,
                    message: _searchController.text.isEmpty
                        ? 'No clinicians found'
                        : 'No results for "${_searchController.text}"',
                    actionLabel: 'Add Clinician',
                    onAction: () {
                      Navigator.pushNamed(context, AppRoutes.addClinician);
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchClinicians(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.clinicians.length,
                    itemBuilder: (context, index) {
                      final clinician = provider.clinicians[index];
                      return _buildClinicianCard(context, clinician);
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
          Navigator.pushNamed(context, AppRoutes.addClinician);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Clinician'),
      ),
    );
  }

  Widget _buildClinicianCard(BuildContext context, ClinicianModel clinician) {
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
            AppRoutes.clinicianDetails,
            arguments: clinician.id,
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
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  clinician.name.firstName[0] + clinician.name.lastName[0],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinician.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clinician.credentials.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clinician.contact.email,
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
}