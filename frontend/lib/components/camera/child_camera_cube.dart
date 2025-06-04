import 'package:flutter/material.dart';

class ChildCameraCube extends StatefulWidget {
  final String childName;
  final String? imageUrl;
  final bool isHeadCameraActive;
  final bool isStaticCameraActive;
  final VoidCallback onHeadCameraTap;
  final VoidCallback onStaticCameraTap;

  const ChildCameraCube({
    Key? key,
    required this.childName,
    this.imageUrl,
    this.isHeadCameraActive = false,
    this.isStaticCameraActive = false,
    required this.onHeadCameraTap,
    required this.onStaticCameraTap,
  }) : super(key: key);

  @override
  State<ChildCameraCube> createState() => _ChildCameraCubeState();
}

class _ChildCameraCubeState extends State<ChildCameraCube> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 160,
        height: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Child's image or placeholder
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  widget.imageUrl != null ? AssetImage(widget.imageUrl!) : null,
              child: widget.imageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            // Child's name
            Text(
              widget.childName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Camera icons row with labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Static camera icon (left)
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.videocam,
                        size: 32,
                        color: widget.isStaticCameraActive
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      onPressed: widget.onStaticCameraTap,
                      tooltip: 'Static Camera',
                    ),
                    const Text(
                      'Static',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                // Head camera icon (right)
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.videocam,
                        size: 32,
                        color: widget.isHeadCameraActive
                            ? Colors.yellow
                            : Colors.grey,
                      ),
                      onPressed: widget.onHeadCameraTap,
                      tooltip: 'Head Camera',
                    ),
                    const Text(
                      'Head',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
