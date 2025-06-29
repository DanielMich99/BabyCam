import 'dart:io';
import 'package:image/image.dart' as img;
import 'bounding_box.dart';

class ImageData {
  final File file;
  final String filename;
  final List<BoundingBox> boundingBoxes;
  int? _width;
  int? _height;
  final double? containerWidth;
  final double? containerHeight;

  ImageData(this.file, this.filename,
      {this.boundingBoxes = const [],
      this.containerWidth,
      this.containerHeight});

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

  Future<String> generateLabelFileContent(
      {double? containerWidth, double? containerHeight}) async {
    await loadDimensions();
    if (_width == null || _height == null) {
      throw Exception('Could not load image dimensions');
    }
    final usedContainerWidth = containerWidth ?? this.containerWidth;
    final usedContainerHeight = containerHeight ?? this.containerHeight;
    if (usedContainerWidth == null || usedContainerHeight == null) {
      throw Exception('Container size not set');
    }
    final imageAspect = _width! / _height!;
    final containerAspect = usedContainerWidth / usedContainerHeight;

    double displayedImageWidth, displayedImageHeight, offsetX, offsetY;

    if (imageAspect > containerAspect) {
      // Image fills width, vertical padding
      displayedImageWidth = usedContainerWidth;
      displayedImageHeight = usedContainerWidth / imageAspect;
      offsetX = 0;
      offsetY = (usedContainerHeight - displayedImageHeight) / 2;
    } else {
      // Image fills height, horizontal padding
      displayedImageHeight = usedContainerHeight;
      displayedImageWidth = usedContainerHeight * imageAspect;
      offsetY = 0;
      offsetX = (usedContainerWidth - displayedImageWidth) / 2;
    }

    final lines = <String>[];
    for (var box in boundingBoxes) {
      // Map from container to image pixel coordinates
      final xInImage = ((box.x - offsetX) / displayedImageWidth) * _width!;
      final yInImage = ((box.y - offsetY) / displayedImageHeight) * _height!;
      final widthInImage = (box.width / displayedImageWidth) * _width!;
      final heightInImage = (box.height / displayedImageHeight) * _height!;

      // YOLO format (normalized)
      final xCenter = (xInImage + widthInImage / 2) / _width!;
      final yCenter = (yInImage + heightInImage / 2) / _height!;
      final normWidth = widthInImage / _width!;
      final normHeight = heightInImage / _height!;

      // For now, we'll use class_id 0 since we're dealing with a single class
      lines.add('0 $xCenter $yCenter $normWidth $normHeight');
    }
    return lines.join('\n');
  }

  ImageData copyWith({
    File? file,
    String? filename,
    List<BoundingBox>? boundingBoxes,
    double? containerWidth,
    double? containerHeight,
  }) {
    return ImageData(
      file ?? this.file,
      filename ?? this.filename,
      boundingBoxes: boundingBoxes ?? this.boundingBoxes,
      containerWidth: containerWidth ?? this.containerWidth,
      containerHeight: containerHeight ?? this.containerHeight,
    );
  }
}
