import 'package:flutter/material.dart';

class CameraPreview extends StatelessWidget {
  final bool isCameraOn;

  const CameraPreview({
    Key? key,
    required this.isCameraOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isCameraOn
          ? Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Camera Feed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          : const Icon(
              Icons.camera_alt,
              size: 48,
              color: Colors.grey,
            ),
    );
  }
}
