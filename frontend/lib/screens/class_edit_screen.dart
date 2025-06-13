import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../models/image_data.dart';
import '../components/bounding_box_editor.dart';
import '../services/training_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_state.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ClassEditScreen extends StatefulWidget {
  final String className;
  final List<ImageData> initialImages;
  final int babyProfileId;
  final String modelType;

  const ClassEditScreen({
    Key? key,
    required this.className,
    required this.babyProfileId,
    required this.modelType,
    this.initialImages = const [],
  }) : super(key: key);

  @override
  State<ClassEditScreen> createState() => _ClassEditScreenState();
}

class _ClassEditScreenState extends State<ClassEditScreen> {
  List<ImageData> images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  String _riskLevel = 'medium'; // Default risk level

  bool get allImagesLabeled =>
      images.every((img) => img.boundingBoxes.isNotEmpty);

  @override
  void initState() {
    super.initState();
    images = List.from(widget.initialImages);
  }

  String _generateImageFilename(int index) {
    // Format: class_name_00001.jpg
    return '${widget.className}_${index.toString().padLeft(5, '0')}.jpg';
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          final startIndex = images.length;
          for (var i = 0; i < pickedFiles.length; i++) {
            final filename = _generateImageFilename(startIndex + i);
            images.add(ImageData(File(pickedFiles[i].path), filename));
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<File>> _extractFramesFromVideo(String videoPath) async {
    final videoController = VideoPlayerController.file(File(videoPath));
    await videoController.initialize();

    final duration = videoController.value.duration;
    final frameInterval = const Duration(milliseconds: 500); // 0.5 seconds
    final tempDir = await getTemporaryDirectory();
    final framesDir = await Directory('${tempDir.path}/video_frames').create();

    final frames = <File>[];
    var currentPosition = Duration.zero;

    while (currentPosition < duration) {
      // Extract frame at current position
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1280, // Full HD width
        quality: 100,
        timeMs: currentPosition.inMilliseconds,
      );

      if (thumbnail != null) {
        final frameFile = File('${framesDir.path}/frame_${frames.length}.jpg');
        await frameFile.writeAsBytes(thumbnail);
        frames.add(frameFile);
      }

      currentPosition += frameInterval;
    }

    await videoController.dispose();
    return frames;
  }

  void _pickVideoAndExtractFrames() async {
    try {
      final XFile? videoFile =
          await _picker.pickVideo(source: ImageSource.gallery);
      if (videoFile == null) return;

      // Show loading indicator
      setState(() => _isSaving = true);

      // Extract frames locally
      final frames = await _extractFramesFromVideo(videoFile.path);

      // Add frames to the images list
      setState(() {
        final startIndex = images.length;
        for (var i = 0; i < frames.length; i++) {
          final frameFile = frames[i];
          final filename = _generateImageFilename(startIndex + i);
          images.add(ImageData(frameFile, filename));
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing video: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _editBoundingBox(ImageData image) {
    final isLastImage =
        images.lastWhere((img) => img.boundingBoxes.isEmpty) == image;

    showDialog(
      context: context,
      builder: (context) => BoundingBoxEditor(
        image: image,
        isLastImage: isLastImage,
        onSave: (updatedImage) {
          setState(() {
            final index =
                images.indexWhere((img) => img.filename == image.filename);
            if (index != -1) {
              images[index] = updatedImage;
            }
          });
        },
        onSaveAll: isLastImage ? _save : null,
        className: widget.className,
      ),
    );
  }

  Future<void> _save() async {
    if (!allImagesLabeled) return;

    // Instead of uploading, return the new class data to the previous screen
    final newClass = {
      'className': widget.className,
      'images': images,
      'riskLevel': _riskLevel,
      'babyProfileId': widget.babyProfileId,
      'modelType': widget.modelType,
    };
    if (mounted) {
      Navigator.pop(context, newClass);
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = images.length;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Class: ${widget.className}')),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      '${widget.className} - $imageCount images',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Add Images'),
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.video_library),
                    label: const Text('Add from Video'),
                    onPressed: _pickVideoAndExtractFrames,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  images.isEmpty
                      ? 'Add images to get started.'
                      : allImagesLabeled
                          ? 'All images labeled! Ready to save.'
                          : '${images.where((img) => img.boundingBoxes.isEmpty).length} images need labeling.',
                  style: TextStyle(
                    color: images.isEmpty
                        ? Colors.blue
                        : allImagesLabeled
                            ? Colors.green
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, idx) {
                    final image = images[idx];
                    return GestureDetector(
                      onTap: () => _editBoundingBox(image),
                      child: Stack(
                        children: [
                          Image.file(
                            image.file,
                            fit: BoxFit.cover,
                          ),
                          if (image.boundingBoxes.isNotEmpty)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${image.boundingBoxes.length} boxes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          if (image.boundingBoxes.isEmpty)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black38,
                                child: const Center(
                                  child: Icon(
                                    Icons.label_outline,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (allImagesLabeled && !_isSaving) ? _save : null,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                  OutlinedButton(
                    onPressed: _isSaving ? null : _cancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Saving images and labels...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
