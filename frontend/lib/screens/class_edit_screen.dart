import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'label': label,
      };
}

class ImageData {
  final File file;
  final String filename;
  final List<BoundingBox> boundingBoxes;

  ImageData(this.file, this.filename, {this.boundingBoxes = const []});

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'bounding_boxes': boundingBoxes.map((box) => box.toJson()).toList(),
      };
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
  final ImagePicker _picker = ImagePicker();

  bool get allImagesLabeled =>
      images.every((img) => img.boundingBoxes.isNotEmpty);

  @override
  void initState() {
    super.initState();
    images = List.from(widget.initialImages);
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (var file in pickedFiles) {
            final filename =
                '${widget.className}_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            images.add(ImageData(File(file.path), filename));
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
    showDialog(
      context: context,
      builder: (context) => BoundingBoxEditor(
        image: image,
        onSave: (updatedImage) {
          setState(() {
            final index =
                images.indexWhere((img) => img.filename == image.filename);
            if (index != -1) {
              images[index] = updatedImage;
            }
          });
        },
      ),
    );
  }

  Future<void> _save() async {
    try {
      // TODO: Implement API call to save images and bounding boxes
      final data = {
        'class_name': widget.className,
        'images': images.map((img) => img.toJson()).toList(),
      };

      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Images and bounding boxes saved successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
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
            child: Column(
              children: [
                Text(
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
                if (imageCount >= 30 && imageCount <= 100)
                  Text(
                    allImagesLabeled
                        ? 'All images labeled! Ready to save.'
                        : '${images.where((img) => img.boundingBoxes.isEmpty).length} images need labeling.',
                    style: TextStyle(
                      color: allImagesLabeled ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
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
                onPressed:
                    imageCount >= 30 && imageCount <= 100 && allImagesLabeled
                        ? _save
                        : null,
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

class BoundingBoxEditor extends StatefulWidget {
  final ImageData image;
  final Function(ImageData) onSave;
  final bool isLastImage;
  final VoidCallback? onSaveAll;

  const BoundingBoxEditor({
    Key? key,
    required this.image,
    required this.onSave,
    this.isLastImage = false,
    this.onSaveAll,
  }) : super(key: key);

  @override
  State<BoundingBoxEditor> createState() => _BoundingBoxEditorState();
}

class _BoundingBoxEditorState extends State<BoundingBoxEditor> {
  late List<BoundingBox> boundingBoxes;
  BoundingBox? currentBox;
  Offset? startPoint;
  String currentLabel = '';

  @override
  void initState() {
    super.initState();
    boundingBoxes = List.from(widget.image.boundingBoxes);
  }

  void _startDrawing(Offset position) {
    setState(() {
      startPoint = position;
      currentBox = null;
    });
  }

  void _updateDrawing(Offset position) {
    if (startPoint != null) {
      setState(() {
        final x = position.dx < startPoint!.dx ? position.dx : startPoint!.dx;
        final y = position.dy < startPoint!.dy ? position.dy : startPoint!.dy;
        final width = (position.dx - startPoint!.dx).abs();
        final height = (position.dy - startPoint!.dy).abs();

        currentBox = BoundingBox(
          x: x,
          y: y,
          width: width,
          height: height,
          label: currentLabel,
        );
      });
    }
  }

  void _endDrawing() {
    if (currentBox != null) {
      setState(() {
        boundingBoxes.add(currentBox!);
        currentBox = null;
        startPoint = null;
      });
    }
  }

  void _deleteBox(int index) {
    setState(() {
      boundingBoxes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bounding Box Editor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'Enter label for the bounding box',
            ),
            onChanged: (value) => currentLabel = value,
          ),
          const SizedBox(height: 16),
          Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: GestureDetector(
              onPanStart: (details) => _startDrawing(details.localPosition),
              onPanUpdate: (details) => _updateDrawing(details.localPosition),
              onPanEnd: (_) => _endDrawing(),
              child: Stack(
                children: [
                  Image.file(
                    widget.image.file,
                    fit: BoxFit.contain,
                  ),
                  ...boundingBoxes.asMap().entries.map((entry) {
                    final box = entry.value;
                    return Positioned(
                      left: box.x,
                      top: box.y,
                      child: GestureDetector(
                        onTap: () => _deleteBox(entry.key),
                        child: Container(
                          width: box.width,
                          height: box.height,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              color: Colors.red.withOpacity(0.5),
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                box.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (currentBox != null)
                    Positioned(
                      left: currentBox!.x,
                      top: currentBox!.y,
                      child: Container(
                        width: currentBox!.width,
                        height: currentBox!.height,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (widget.isLastImage && widget.onSaveAll != null)
          ElevatedButton(
            onPressed: () {
              final updatedImage = ImageData(
                widget.image.file,
                widget.image.filename,
                boundingBoxes: boundingBoxes,
              );
              widget.onSave(updatedImage);
              widget.onSaveAll!();
            },
            child: const Text('Save & Finish'),
          )
        else
          ElevatedButton(
            onPressed: () {
              final updatedImage = ImageData(
                widget.image.file,
                widget.image.filename,
                boundingBoxes: boundingBoxes,
              );
              widget.onSave(updatedImage);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
      ],
    );
  }
}
