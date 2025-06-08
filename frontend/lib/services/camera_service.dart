import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_state.dart';

class CameraService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<bool> connectCamera(
      int babyProfileId, String cameraType) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/camera/connect'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'baby_profile_id': babyProfileId,
        'camera_type': cameraType,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 504) {
      throw Exception('Connection timeout - no camera connected');
    } else {
      throw Exception('Failed to connect camera');
    }
  }

  static Future<bool> disconnectCamera(
      int babyProfileId, String cameraType) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/camera/disconnect'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'baby_profile_id': babyProfileId,
        'camera_type': cameraType,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('Profile not found or invalid camera type');
    } else {
      throw Exception('Failed to disconnect camera');
    }
  }

  static Future<int> resetUserCameras(int userId) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/camera/reset_user_cameras'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['profiles_updated'];
    } else if (response.statusCode == 404) {
      throw Exception('No baby profiles found for this user');
    } else {
      throw Exception('Failed to reset cameras');
    }
  }
}
