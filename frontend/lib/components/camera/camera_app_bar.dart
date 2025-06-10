import 'package:flutter/material.dart';

AppBar buildCameraAppBar({
  required VoidCallback onGridView,
  required VoidCallback onResetCameras,
}) {
  return AppBar(
    title: const Text('Cameras'),
    actions: [
      IconButton(
        icon: const Icon(Icons.grid_view),
        onPressed: onGridView,
        tooltip: 'View All Cameras',
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: onResetCameras,
        tooltip: 'Reset All Cameras',
      ),
    ],
  );
}
