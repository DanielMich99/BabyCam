import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_state.dart';
import '../models/baby_profile.dart';
import '../config/app_config.dart';

class CameraService {
  static const String baseUrl = AppConfig.baseUrl;

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

  // New method to handle camera connection/disconnection
  static Future<BabyProfile> handleCameraConnection(
      BabyProfile baby, String cameraType) async {
    final isHeadCamera = cameraType == 'head_camera';
    if ((isHeadCamera && baby.camera2On) || (!isHeadCamera && baby.camera1On)) {
      await disconnectCamera(baby.id, cameraType);
      return baby.copyWith(
        camera1On: isHeadCamera ? baby.camera1On : false,
        camera2On: isHeadCamera ? false : baby.camera2On,
      );
    } else {
      await connectCamera(baby.id, cameraType);
      return baby.copyWith(
        camera1On: !isHeadCamera,
        camera2On: isHeadCamera,
        isConnectingCamera1: false,
        isConnectingCamera2: false,
      );
    }
  }

  // New method to reset all cameras for a user
  static Future<int> resetAllCameras(int userId) async {
    return resetUserCameras(userId);
  }
}
