import 'dart:io';
import 'package:image/image.dart' as img;
import 'bounding_box.dart';

class ImageData {
  final File file;
  final String filename;
  final List<BoundingBox> boundingBoxes;
  int? _width;
  int? _height;

  ImageData(this.file, this.filename, {this.boundingBoxes = const []});

  Future<void> loadDimensions() async {
    if (_width == null || _height == null) {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        _width = image.width;
        _height = image.height;
      }
    }
  }

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'bounding_boxes': boundingBoxes.map((box) => box.toJson()).toList(),
      };

  Future<String> generateLabelFileContent() async {
    await loadDimensions();
    if (_width == null || _height == null) {
      throw Exception('Could not load image dimensions');
    }

    final lines = <String>[];
    for (var box in boundingBoxes) {
      // Convert to YOLO format (normalized coordinates)
      final xCenter = (box.x + box.width / 2) / _width!;
      final yCenter = (box.y + box.height / 2) / _height!;
      final width = box.width / _width!;
      final height = box.height / _height!;

      // Format: <class_id> <x_center> <y_center> <width> <height>
      // For now, we'll use class_id 0 since we're dealing with a single class
      lines.add('0 $xCenter $yCenter $width $height');
    }
    return lines.join('\n');
  }

  ImageData copyWith({
    File? file,
    String? filename,
    List<BoundingBox>? boundingBoxes,
  }) {
    return ImageData(
      file ?? this.file,
      filename ?? this.filename,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
    );
  }
}
