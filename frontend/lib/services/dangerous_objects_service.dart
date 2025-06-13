import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_state.dart';
import 'training_service.dart';

class DangerousObjectsService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<void> updateModel({
    required int babyProfileId,
    required String cameraType,
    required List<Map<String, dynamic>> newClasses,
    required List<Map<String, dynamic>> updatedClasses,
    required List<String> deletedClasses,
  }) async {
    // 1. Upload all new images and label files for each pending addition and update
    for (final cls in [...newClasses, ...updatedClasses]) {
      await TrainingService.uploadFilesToTemp(List.from(cls['images']));
    }

    // 2. Prepare request body
    final body = {
      'baby_profile_id': babyProfileId,
      'model_type':
          cameraType == 'Head Camera' ? 'head_camera' : 'static_camera',
      'new_classes': newClasses.map((cls) {
        final imageFilenames = <String>[];
        final labelFilenames = <String>[];
        for (var image in cls['images']) {
          imageFilenames.add(image.filename);
          labelFilenames.add('${image.filename.split('.').first}.txt');
        }
        return {
          'name': cls['className'],
          'risk_level': cls['riskLevel'],
          'files': {
            'images': imageFilenames,
            'labels': labelFilenames,
          },
        };
      }).toList(),
      'updated_classes': updatedClasses.map((cls) {
        final imageFilenames = <String>[];
        final labelFilenames = <String>[];
        for (var image in cls['images']) {
          imageFilenames.add(image.filename);
          labelFilenames.add('${image.filename.split('.').first}.txt');
        }
        return {
          'id': cls['original_id'],
          'name': cls['className'],
          'risk_level': cls['riskLevel'],
          'files': {
            'images': imageFilenames,
            'labels': labelFilenames,
          },
        };
      }).toList(),
      'deleted_classes': deletedClasses,
    };

    // 3. Send request
    final token = await AuthState.getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/model/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update model: ${response.body}');
    }
  }
}
