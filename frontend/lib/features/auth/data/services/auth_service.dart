import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';

// Authentication Service for Api calls
// TODO: Implement api calls when backend is ready
class AuthService {
  // 
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login User
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Replace with actual api call when backend is ready

      // Simulate response for now
      await Future.delayed(const Duration(seconds: 2));

      // Mocking successful response
      final mockResponse = {
        'success' : true,
        'token' : 'mock_token_12',
        'user' : {
          'id' : '1',
          'email' : email,
          'name' : 'John Doe',
          'role' : 'patient',
          'phone' : '+124567890',
          'createdAt' : DateTime.now().toIso8601String(),
        },
      };

      // saving token and user data
      if(mockResponse['success'] == true) {
        await _saveAuthData(
          mockResponse['token'] as String,
          mockResponse['user'] as Map<String, dynamic>,
        );
      }

      return mockResponse;
    } catch (e) {
      return {
        'success' : false,
        'message' : 'Login failed: ${e.toString()}',
      };
    }
  }

  // Register User
  Future<Map<String, dynamic>> register ({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'patient',
  }) async {
    try {
      // TODO: Replace with actual api call when backend is ready

      // Simulating response for now
      await Future.delayed(const Duration(seconds: 2));

      final mockResponse = {
        'success' : true,
        'token' : 'mock_token_67890',
        'user' : {
          'id' : '2',
          'email' : email,
          'name' : name,
          'role' : role,
          'phone' : phone,
          'createdAt' : DateTime.now().toIso8601String(),
        },
      };

      if(mockResponse['success'] == true) {
        await _saveAuthData(
          mockResponse['token'] as String,
          mockResponse['user'] as Map<String, dynamic>,
        );
      }

      return mockResponse;
    } catch (e) {
      return{
        'success' : false,
        'message' : 'Registration failed: ${e.toString()}',
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