import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_state.dart';
import 'notification_service.dart';
import '../models/baby_profile.dart';

class AuthService {
  static final String baseUrl = '${AppConfig.baseUrl}/auth';

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['detail'] ??
              'Registration failed. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. Please check if the backend is running.',
        );
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Login failed');
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. Please check if the backend is running.',
        );
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> logout({
    required List<int> babyProfileIds,
    required String fcmToken,
  }) async {
    try {
      final token = await AuthState.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'baby_profile_ids': babyProfileIds,
          'fcm_token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Logout failed');
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. Please check if the backend is running.',
        );
      }
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<List<BabyProfile>> getBabyProfiles() async {
    try {
      final token = await AuthState.getAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BabyProfile.fromJson(json)).toList();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to load baby profiles');
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception(
          'Cannot connect to server. Please check if the backend is running.',
        );
      }
      throw Exception('Failed to load baby profiles: ${e.toString()}');
    }
  }
}
