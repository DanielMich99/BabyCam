import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/baby_profile.dart';
import '../../services/auth_state.dart';
import '../../config/app_config.dart';

Future<List<BabyProfile>> fetchBabies() async {
  final token = await AuthState.getAuthToken();
  if (token == null) throw Exception('Not authenticated');
  final response = await http.get(
    Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BabyProfile.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load babies');
  }
}

void showErrorDialog(
    BuildContext context, String title, String message, VoidCallback onRetry) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
