import 'dart:convert';

import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final token = data['token'] as String;
        final rawUser = (data['user'] ?? data['clinician'] ?? data) as Map;
        final userData = Map<String, dynamic>.from(rawUser);
        await _saveAuthData(token, userData);
        return {'success': true, 'token': token, 'user': userData};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid email or password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
      final body = <String, dynamic>{
        'name': name,
        'email': email.trim(),
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['token'] as String;
        final rawUser = (data['user'] ?? data['clinician'] ?? data) as Map;
        final userData = Map<String, dynamic>.from(rawUser);
        await _saveAuthData(token, userData);
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful!',
          'token': token,
          'user': userData,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
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

    if (userJson == null || userJson.isEmpty) return null;

    final userData = jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(userData);
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
}
