import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baby_profile.dart';
import 'auth_state.dart';

class BabyProfileService {
  static Future<BabyProfile> updateBabyProfile({
    required int id,
    required Map<String, dynamic> updateData,
  }) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/baby_profiles/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData),
    );
    if (response.statusCode == 200) {
      return BabyProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update baby: ${response.body}');
    }
  }

  static Future<BabyProfile> createBabyProfile(
      Map<String, dynamic> data) async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/baby_profiles/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BabyProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create baby: ${response.body}');
    }
  }
}
