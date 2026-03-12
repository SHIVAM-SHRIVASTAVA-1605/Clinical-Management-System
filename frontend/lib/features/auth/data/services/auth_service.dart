import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';

// Authentication Service for Api calls
// TODO: Implement api calls when backend is ready
class AuthService {
  // 
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initializeMockUsers();
  }

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Mock users database
  final List<UserModel> _mockUsers = [];

  // Initialize mock users (pre-existing admins and test users)
  void _initializeMockUsers() {
    _mockUsers.addAll([
      // Pre-existing admins
      UserModel(
        id: 'admin1',
        email: 'admin@clinic.com',
        name: 'System Admin',
        role: 'admin',
        phone: '+1234567890',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isVerified: true,
      ),
      UserModel(
        id: 'admin2',
        email: 'superadmin@clinic.com',
        name: 'Super Admin',
        role: 'admin',
        phone: '+1234567891',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isVerified: true,
      ),
      // Test verified clinician
      UserModel(
        id: 'clinician1',
        email: 'dr.smith@clinic.com',
        name: 'Dr. John Smith',
        role: 'clinician',
        phone: '+1234567892',
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
        isVerified: true,
      ),
      // Test patient
      UserModel(
        id: 'patient1',
        email: 'patient@test.com',
        name: 'Test Patient',
        role: 'patient',
        phone: '+1234567893',
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        isVerified: true,
      ),
    ]);
  }

  // Get all users (for admin panel)
  List<UserModel> getAllUsers() {
    return List.from(_mockUsers);
  }

  // Get pending clinicians (for admin verification)
  List<UserModel> getPendingClinicians() {
    return _mockUsers.where((user) => user.isPending).toList();
  }

  // Verify a clinician
  Future<bool> verifyClinician(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _mockUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _mockUsers[index] = _mockUsers[index].copyWith(isVerified: true);
      return true;
    }
    return false;
  }

  // Reject a clinician (delete their account)
  Future<bool> rejectClinician(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockUsers.removeWhere((user) => user.id == userId);
    return true;
  }

  // Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual api call when backend is ready

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Find user in mock database
      final user = _mockUsers.firstWhere(
        (u) => u.email == email,
        orElse: () => throw Exception('User not found'),
      );

      // Check if clinician is verified
      if (user.isClinician && !user.isVerified) {
        return {
          'success': false,
          'message': 'Your account is pending admin verification. Please wait for approval.',
        };
      }

      // Mock successful login
      final mockResponse = {
        'success': true,
        'token': 'mock_token_${user.id}',
        'user': user.toJson(),
      };

      // saving token and user data
      if (mockResponse['success'] == true) {
        await _saveAuthData(
          mockResponse['token'] as String,
          mockResponse['user'] as Map<String, dynamic>,
        );
      }

      return mockResponse;
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }
  }

  // Register User
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role, // Made required for role selection
  }) async {
    try {
      // TODO: Replace with actual api call when backend is ready

      // Simulating response for now
      await Future.delayed(const Duration(seconds: 1));

      // Check if email already exists
      final existingUser = _mockUsers.where((u) => u.email == email).firstOrNull;
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      // Prevent regular users from registering as admin
      if (role == 'admin') {
        return {
          'success': false,
          'message': 'Cannot register as admin. Contact system administrator.',
        };
      }

      // Create new user
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        role: role,
        phone: phone,
        createdAt: DateTime.now(),
        isVerified: role != 'clinician', // Clinicians need verification
      );

      // Add to mock database
      _mockUsers.add(newUser);

      // For clinicians, don't log them in (pending verification)
      if (role == 'clinician') {
        return {
          'success': true,
          'message': 'Registration successful! Your account is pending admin verification.',
          'requiresVerification': true,
        };
      }

      // For patients, log them in immediately
      final mockResponse = {
        'success': true,
        'token': 'mock_token_${newUser.id}',
        'user': newUser.toJson(),
      };

      await _saveAuthData(
        mockResponse['token'] as String,
        mockResponse['user'] as Map<String, dynamic>,
      );

      return mockResponse;
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }


  // Logout user
  Future<void> logout() async{
    // TODO: call logout api endpoint when backend is ready
    await _clearAuthData();
  }

  // get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // get saved user
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if(userJson != null) {
      final Map<String, dynamic> userData = 
        Map<String, dynamic>.from(
          {} // TODO: Parse userJson properly
        );
      return UserModel.fromJson(userData);
    }

    return null;
  }

  // Checking if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Private: saving auth to local storage
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, userData.toString());
  }

  // private: clear auth data from local storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}