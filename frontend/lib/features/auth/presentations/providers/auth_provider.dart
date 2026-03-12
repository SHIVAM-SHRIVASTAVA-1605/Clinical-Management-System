import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';

// Authentication provider for state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Get pending clinicians (admin only)
  List<UserModel> getPendingClinicians() {
    return _authService.getPendingClinicians();
  }

  // Verify clinician (admin only)
  Future<bool> verifyClinician(String userId) async {
    final success = await _authService.verifyClinician(userId);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // Reject clinician (admin only)
  Future<bool> rejectClinician(String userId) async {
    final success = await _authService.rejectClinician(userId);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  // login method
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(
        email: email, 
        password: password,
      );

      if(response['success'] == true) {
        _user = UserModel.fromJson(response['user']);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch(e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // register method - returns full response map
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (response['success'] == true) {
        // Only set user if they don't need verification
        if (response['requiresVerification'] != true && response['user'] != null) {
          _user = UserModel.fromJson(response['user']);
        }
        _setLoading(false);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Registration failed');
        _setLoading(false);
      }

      return response;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      _setLoading(false);
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // logout method
  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _user = null;
    _setLoading(false);
    notifyListeners();
  }

  // checking if user is already logged in
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    final isLoggedIn = await _authService.isLoggedIn();

    if(isLoggedIn) {
      final savedUser = await _authService.getSavedUser();
      _user = savedUser;
    }

    _setLoading(false);
    notifyListeners();

  }

  // private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}