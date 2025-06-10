import 'package:flutter/material.dart';
import 'package:mjpeg/mjpeg.dart';

class VideoStreamPlayer extends StatelessWidget {
  final String streamUrl;
  final bool isActive;

  const VideoStreamPlayer({
    Key? key,
    required this.streamUrl,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Mjpeg(
        stream: streamUrl,
        isLive: true,
        error: (context, error, stack) {
          return Center(child: Text('Stream error: \$error'));
        },
      ),
    );
  }
}
