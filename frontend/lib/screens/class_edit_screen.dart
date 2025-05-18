import 'package:flutter/material.dart';
import 'dart:io';

class ImageData {
  final File file;
  // Add more fields as needed (e.g., labelFile)
  ImageData(this.file);
}

class ClassEditScreen extends StatefulWidget {
  final String className;
  final List<ImageData> initialImages;

  const ClassEditScreen({
    Key? key,
    required this.className,
    this.initialImages = const [],
  }) : super(key: key);

  @override
  State<ClassEditScreen> createState() => _ClassEditScreenState();
}

class _ClassEditScreenState extends State<ClassEditScreen> {
  List<ImageData> images = [];

  @override
  void initState() {
    super.initState();
    images = List.from(widget.initialImages);
  }

  void _pickImages() async {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker not implemented.')),
    );
  }

  void _pickVideoAndExtractFrames() async {
    // TODO: Implement video picker and frame extraction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video frame extraction not implemented.')),
    );
  }

  void _editBoundingBox(ImageData image) {
    // TODO: Implement bounding box editor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bounding Box Editor'),
        content: const Text('Bounding box UI not implemented.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _save() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save not implemented.')),
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = images.length;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Class: ${widget.className}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.className} - $imageCount images (min 30, max 100)',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              imageCount < 30
                  ? 'Add at least ${30 - imageCount} more images.'
                  : imageCount > 100
                      ? 'Remove ${imageCount - 100} images.'
                      : '',
              style: TextStyle(
                color: imageCount < 30 || imageCount > 100
                    ? Colors.red
                    : Colors.green,
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
                return GestureDetector(
                  onTap: () => _editBoundingBox(images[idx]),
                  child: Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image)),
                    // In real use: Image.file(images[idx].file, fit: BoxFit.cover)
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: imageCount >= 30 && imageCount <= 100 ? _save : null,
                child: const Text('Save'),
              ),
              OutlinedButton(
                onPressed: _cancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
