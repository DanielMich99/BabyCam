import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_state.dart';
import '../config/app_config.dart';

class ClassSuggestionService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<List<String>> getClassSuggestions({
    required int babyProfileId,
    required String cameraType,
  }) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('$baseUrl/class_suggestions/').replace(queryParameters: {
      'baby_profile_id': babyProfileId.toString(),
      'camera_type': cameraType,
    });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch class suggestions: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final classes = data['classes'] as List<dynamic>;
    return classes.map((c) => c.toString()).toList();
  }
}