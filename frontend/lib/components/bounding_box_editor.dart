import 'package:flutter/material.dart';
import '../models/image_data.dart';
import '../models/bounding_box.dart';

class BoundingBoxEditor extends StatefulWidget {
  final ImageData image;
  final Function(ImageData) onSave;
  final bool isLastImage;
  final VoidCallback? onSaveAll;
  final String className;

  const BoundingBoxEditor({
    Key? key,
    required this.image,
    required this.onSave,
    required this.className,
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
          label: widget.className,
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
              final updatedImage = widget.image.copyWith(
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
              final updatedImage = widget.image.copyWith(
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
