import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_data.dart';

class TrainingService {
  static const String baseUrl = 'http://localhost:8000/api/training';

  static Future<void> uploadClassData({
    required String className,
    required List<ImageData> images,
  }) async {
    final formData = <String, dynamic>{
      'class_name': className,
      'images': [],
    };

    // Process each image and its label file
    for (var image in images) {
      final imageBytes = await image.file.readAsBytes();
      final labelContent = await image.generateLabelFileContent();

      formData['images'].add({
        'filename': image.filename,
        'image_data': base64Encode(imageBytes),
        'label_data': labelContent,
      });
    }

    final response = await http.post(
      Uri.parse('$baseUrl/upload-class-data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(formData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload class data: ${response.body}');
    }
  }
}
