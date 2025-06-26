import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/notification_item.dart';
import '../config/app_config.dart';
import 'auth_state.dart';

class DetectionService {
  Future<String?> _getAuthToken() async {
    return await AuthState.getAuthToken();
  }

  Future<List<NotificationItem>> getMyDetectionResults() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(AppConfig.getUrl(AppConfig.detectionResultsEndpoint + '/my')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load detection results');
    }
  }

  Future<void> deleteDetectionResult(int id) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse(AppConfig.getUrl('${AppConfig.detectionResultsEndpoint}/$id')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete detection result');
    }
  }

  Future<List<NotificationItem>> getFilteredDetectionResults({
    required int babyProfileId,
    required String cameraType,
  }) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
              AppConfig.getUrl(AppConfig.detectionResultsEndpoint + '/filter'))
          .replace(queryParameters: {
        'baby_profile_id': babyProfileId.toString(),
        'camera_type': cameraType,
      }),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load filtered detection results');
    }
  }

  Future<Uint8List> getDetectionImage(int id) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
          AppConfig.getUrl('${AppConfig.detectionResultsEndpoint}/$id/image')),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load detection image');
    }
  }

  // Bulk delete alerts grouped by baby profile
  // Request body format:
  // {
  //   "alerts_by_baby": {
  //     "babyId1": [alertId1, alertId2],
  //     "babyId2": [alertId3, alertId4]
  //   }
  // }
  Future<void> bulkDeleteAlertsByBaby(Map<int, List<int>> alertsByBaby) async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    // Convert int keys to strings for JSON serialization
    final Map<String, dynamic> requestBody = {
      'alerts_by_baby':
          alertsByBaby.map((key, value) => MapEntry(key.toString(), value)),
    };

    final response = await http.delete(
      Uri.parse(AppConfig.getUrl('${AppConfig.detectionResultsEndpoint}/batch_delete')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to bulk delete alerts');
    }
  }
}
