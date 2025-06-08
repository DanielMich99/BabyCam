import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/image_data.dart';
import '../components/bounding_box_editor.dart';
import '../services/training_service.dart';

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

  void _pickVideoAndExtractFrames() async {
    // TODO: Implement video picker and frame extraction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video frame extraction not implemented.')),
    );
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
      ),
    );
  }

  Future<void> _save() async {
    if (!allImagesLabeled) return;

    setState(() => _isSaving = true);

    try {
      // 1. Upload files to temp
      await TrainingService.uploadFilesToTemp(images);
      // 2. Send metadata to model/update
      await TrainingService.uploadClassData(
        className: widget.className,
        images: images,
        riskLevel: _riskLevel,
        babyProfileId: widget.babyProfileId,
        modelType: widget.modelType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Images and labels saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                    DropdownButton<String>(
                      value: _riskLevel,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low Risk')),
                        DropdownMenuItem(
                            value: 'medium', child: Text('Medium Risk')),
                        DropdownMenuItem(
                            value: 'high', child: Text('High Risk')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _riskLevel = value);
                        }
                      },
                    ),
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
                  allImagesLabeled
                      ? 'All images labeled! Ready to save.'
                      : '${images.where((img) => img.boundingBoxes.isEmpty).length} images need labeling.',
                  style: TextStyle(
                    color: allImagesLabeled ? Colors.green : Colors.orange,
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
