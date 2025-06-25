import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'auth_state.dart';
import 'detection_system_state.dart';

class MonitoringService {
  final _detectionState = DetectionSystemState();

  Future<String?> _getAuthToken() async {
    return await AuthState.getAuthToken();
  }

  Future<Map<String, dynamic>> startMonitoring(
      List<Map<String, dynamic>> cameraProfiles) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse(AppConfig.getUrl('${AppConfig.monitoringEndpoint}/start')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'camera_profiles': cameraProfiles,
      }),
    );

    if (response.statusCode == 200) {
      _detectionState.setActive(true);
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Failed to start monitoring');
    }
  }

  Future<Map<String, dynamic>> stopMonitoring(
      List<Map<String, dynamic>> cameraProfiles) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse(AppConfig.getUrl('${AppConfig.monitoringEndpoint}/stop')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'camera_profiles': cameraProfiles,
      }),
    );

    if (response.statusCode == 200) {
      _detectionState.setActive(false);
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['detail'] ?? 'Failed to stop monitoring');
    }
  }

  bool get isDetectionActive => _detectionState.isActive;

  void addStateListener(VoidCallback listener) {
    _detectionState.addListener(listener);
  }

  void removeStateListener(VoidCallback listener) {
    _detectionState.removeListener(listener);
  }
}
