import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Column(
        children: [
          // Camera preview placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black26, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam,
                  color: Colors.grey,
                  size: 80,
                ),
              ),
            ),
          ),
          // Thumbnail placeholder
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 32),
                ),
              ],
            ),
          ),
          // Camera controls
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Switch camera button
                RawMaterialButton(
                  onPressed: () {},
                  shape: const CircleBorder(),
                  fillColor: Colors.white,
                  elevation: 2,
                  constraints:
                      const BoxConstraints.tightFor(width: 64, height: 64),
                  child: const Icon(Icons.cameraswitch,
                      size: 32, color: Colors.blue),
                ),
                const SizedBox(width: 48),
                // Take photo button
                RawMaterialButton(
                  onPressed: () {},
                  shape: const CircleBorder(),
                  fillColor: Colors.blue,
                  elevation: 4,
                  constraints:
                      const BoxConstraints.tightFor(width: 72, height: 72),
                  child: const Icon(Icons.camera_alt,
                      size: 36, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
