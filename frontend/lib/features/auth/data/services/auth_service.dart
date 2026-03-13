import 'dart:convert';

import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Authentication Service for API calls.
// TODO: Replace mock flows with backend endpoints when deployed.
class AuthService {
  static const String _resettableEmail = 'shivam@gmail.com';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _initializeMockUsers();
    _restoreUsersFromStorage();
  }

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _usersDbKey = 'mock_users_db';

  // Mock users database
  final List<UserModel> _mockUsers = [];

  // Initialize baseline mock users (only once)
  void _initializeMockUsers() {
    // Keep empty by default; users are expected to register.
  }

  List<UserModel> getAllUsers() {
    return List<UserModel>.from(_mockUsers);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final user = _mockUsers.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      final mockResponse = {
        'success': true,
        'token': 'mock_token_${user.id}',
        'user': user.toJson(),
      };

      await _saveAuthData(
        mockResponse['token'] as String,
        mockResponse['user'] as Map<String, dynamic>,
      );

      return mockResponse;
    } catch (_) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final normalizedEmail = email.trim().toLowerCase();

      if (normalizedEmail == _resettableEmail) {
        final prefs = await SharedPreferences.getInstance();
        final deletedAny = _deleteUsersByEmail(normalizedEmail);
        if (deletedAny) {
          await _clearSavedAuthForEmail(prefs, normalizedEmail);
          await _persistUsers();
        }
      }

      final existingUser = _mockUsers.where(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'Email already registered',
        };
      }

      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );

      _mockUsers.add(newUser);
      await _persistUsers();

      final token = 'mock_token_${newUser.id}';
      await _saveAuthData(token, newUser.toJson());

      return {
        'success': true,
        'message': 'Registration successful!',
        'token': token,
        'user': newUser.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    await _clearAuthData();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null || userJson.isEmpty) {
      return null;
    }

    final userData = jsonDecode(userJson) as Map<String, dynamic>;
    final user = UserModel.fromJson(userData);
    if (user.role != 'clinician') {
      await _clearAuthData();
      return null;
    }
    return user;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _saveAuthData(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersPayload = _mockUsers.map((user) => user.toJson()).toList();
    await prefs.setString(_usersDbKey, jsonEncode(usersPayload));
  }

  Future<void> _restoreUsersFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersDbKey);

    if (usersRaw == null || usersRaw.isEmpty) {
      await _persistUsers();
      return;
    }

    try {
      final decoded = jsonDecode(usersRaw);
      if (decoded is List) {
        _mockUsers
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))),
          );
        _mockUsers.removeWhere((user) => user.role != 'clinician');
        await _persistUsers();
      }
    } catch (_) {
      // Keep defaults if cached data is corrupted.
      await _persistUsers();
    }
  }

  bool _deleteUsersByEmail(String normalizedEmail) {
    final before = _mockUsers.length;
    _mockUsers.removeWhere(
      (u) => u.email.trim().toLowerCase() == normalizedEmail,
    );
    return before != _mockUsers.length;
  }

  Future<void> _clearSavedAuthForEmail(
    SharedPreferences prefs,
    String normalizedEmail,
  ) async {
    final rawUser = prefs.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) {
      return;
    }

    try {
      final json = jsonDecode(rawUser);
      if (json is Map) {
        final email = (json['email'] ?? '').toString().trim().toLowerCase();
        if (email == normalizedEmail) {
          await _clearAuthData();
        }
      }
    } catch (_) {
      await _clearAuthData();
    }
  }
}
