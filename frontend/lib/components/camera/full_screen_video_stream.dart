import 'package:flutter/material.dart';
import 'package:mjpeg_stream/mjpeg_stream.dart';

class FullScreenVideoStream extends StatefulWidget {
  final String streamUrl;
  final String title;

  const FullScreenVideoStream({
    Key? key,
    required this.streamUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<FullScreenVideoStream> createState() => _FullScreenVideoStreamState();
}

class _FullScreenVideoStreamState extends State<FullScreenVideoStream> {
  bool _isStreamActive = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isStreamActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isStreamActive = !_isStreamActive;
                if (_isStreamActive) {
                  _hasError = false;
                  _errorMessage = '';
                }
              });
            },
          ),
        ],
      ),
      body: Center(
        child: _buildStreamContent(),
      ),
    );
  }

  Widget _buildStreamContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isStreamActive) {
      return _buildPausedWidget();
    }

    return MJPEGStreamScreen(
      streamUrl: widget.streamUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      timeout: const Duration(seconds: 10),
      showLiveIcon: true,
      showWatermark: false,
      blurSensitiveContent: false,
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Stream Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Failed to connect to camera',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isStreamActive = true;
                  _hasError = false;
                  _errorMessage = '';
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pause_circle_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Stream Paused',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the play button to resume',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
