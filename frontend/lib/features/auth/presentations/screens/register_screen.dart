import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_strings.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/utils/toast_helper.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/core/widgets/custom_button.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/auth/presentations/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Register Screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'patient'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final result = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      if (result['success']) {
        // Check if clinician needs verification
        if (result['requiresVerification'] == true) {
          ToastHelper.showSuccess(
            context,
            'Registration successful! Your account is pending admin verification.',
          );
          // Navigate back to login
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          // Patient registered successfully
          ToastHelper.showSuccess(context, 'Registration Successful!');

          // Navigate to appropriate dashboard
          final user = authProvider.user;
          String route = AppRoutes.patientDashboard;

          if (user?.isAdmin == true) {
            route = AppRoutes.adminDashboard;
          } else if (user?.isClinician == true) {
            route = AppRoutes.clinicianDashboard;
          }

          Navigator.pushReplacementNamed(context, route);
        }
      } else {
        ToastHelper.showError(
          context,
          result['message'] ?? 'Registration failed',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Sign up to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Role Selection
                const Text(
                  'I am a:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Patient'),
                          ],
                        ),
                        subtitle: const Text('Book appointments and manage health'),
                        value: 'patient',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.medical_services, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Clinician'),
                          ],
                        ),
                        subtitle: const Text(
                          'Requires admin verification',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        value: 'clinician',
                        groupValue: _selectedRole,
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Name Field
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  validator: (value) => Validators.required(value, fieldName: 'Name'),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),
                
                // email field
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // phone field
                CustomTextField(
                  label: 'Phone (Optional)',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 16),

                // password field
                CustomTextField(
                  label: AppStrings.password,
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // confirm password field
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Information banner for clinicians
                if (_selectedRole == 'clinician')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your account will be reviewed by an admin before you can sign in.',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedRole == 'clinician') const SizedBox(height: 16),

                // Register button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: AppStrings.register,
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}