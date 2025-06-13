import 'package:http/http.dart' as http;
import 'dart:convert';

class BabyProfile {
  final int id;
  final String name;
  // Add other fields as needed

  BabyProfile({required this.id, required this.name});

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: json['id'],
      name: json['name'],
    );
  }
}

class UserService {
  static const String baseUrl = 'http://localhost:8000/api';

  Future<BabyProfile> getCurrentBabyProfile() async {
    // TODO: In a real app, this would get the current baby profile from the server
    // For now, return a mock profile
    return BabyProfile(id: 1, name: 'Default Baby');
  }
}
