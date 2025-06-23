import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../models/image_data.dart';
import 'auth_state.dart';
import '../config/app_config.dart';

class TrainingService {
  static final String tempUploadUrl = '${AppConfig.baseUrl}/upload-to-temp';
  static final String modelUpdateUrl = '${AppConfig.baseUrl}/model/update';

  // 1. Upload files (images and labels) to temp
  static Future<void> uploadFilesToTemp(List<ImageData> images) async {
    if (images.isEmpty) {
      return; // No files to upload
    }
    final token = await AuthState.getAuthToken();  // ✅ שלוף את הטוקן כמו בשאר הקוד
    if (token == null) throw Exception('Not authenticated');

    var uri = Uri.parse(tempUploadUrl);
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';  // ✅ הוספת הטוקן

    for (var image in images) {
      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        image.file.path,
        filename: image.filename,
      ));

      // Add label file
      final labelContent = await image.generateLabelFileContent();
      final labelFile = http.MultipartFile.fromString(
        'files',
        labelContent,
        filename: '${image.filename.split('.').first}.txt',
      );
      request.files.add(labelFile);
    }

    var response = await request.send();
    if (response.statusCode != 200) {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Failed to upload files to temp: ${response.statusCode} - $errorBody');
    }
  }

  // 2. Send metadata to /model/update
  static Future<void> uploadClassData({
    required int babyProfileId,
    required String modelType,
    required String className,
    required String riskLevel,
    required List<ImageData> images,
  }) async {
    final imageFilenames = <String>[];
    final labelFilenames = <String>[];

    for (var image in images) {
      imageFilenames.add(image.filename);
      labelFilenames.add('${image.filename.split('.').first}.txt');
    }

    final newClass = {
      'name': className,
      'risk_level': riskLevel,
      'files': {
        'images': imageFilenames,
        'labels': labelFilenames,
      },
    };

    final requestBody = {
      'baby_profile_id': babyProfileId,
      'model_type': modelType,
      'new_classes': [newClass],
      'updated_classes': [],
      'deleted_classes': [],
    };

    final response = await http.post(
      Uri.parse(modelUpdateUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload class metadata: ${response.body}');
    }
  }
}
