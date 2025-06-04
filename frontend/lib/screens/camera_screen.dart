import 'package:flutter/material.dart';
import '../components/camera/child_camera_cube.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Placeholder data - replace with actual data from your backend
  final List<Map<String, dynamic>> _children = [
    {
      'name': 'Baby 1',
      'imageUrl': 'assets/images/default_baby.jpg',
      'isHeadCameraActive': false,
      'isStaticCameraActive': false,
    },
    {
      'name': 'Baby 2',
      'imageUrl': 'assets/images/default_baby.jpg',
      'isHeadCameraActive': false,
      'isStaticCameraActive': false,
    },
    // Add more children as needed
  ];

  bool _detectionSystemActive = false;

  void _toggleDetectionSystem() {
    setState(() {
      _detectionSystemActive = !_detectionSystemActive;
    });
    // TODO: Implement detection system logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_detectionSystemActive
            ? 'Detection System Activated'
            : 'Detection System Deactivated'),
      ),
    );
  }

  void _toggleHeadCamera(int index) {
    setState(() {
      _children[index]['isHeadCameraActive'] =
          !_children[index]['isHeadCameraActive'];
    });
  }

  void _toggleStaticCamera(int index) {
    setState(() {
      _children[index]['isStaticCameraActive'] =
          !_children[index]['isStaticCameraActive'];
    });
  }

  void _navigateToAllCameras() {
    // TODO: Implement navigation to all cameras view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All cameras view not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cameras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: _navigateToAllCameras,
            tooltip: 'View All Cameras',
          ),
        ],
      ),
      body: Column(
        children: [
          // Detection System button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _toggleDetectionSystem,
              icon: Icon(
                _detectionSystemActive
                    ? Icons.security
                    : Icons.security_outlined,
                color: _detectionSystemActive ? Colors.green : Colors.grey,
              ),
              label: Text(
                _detectionSystemActive
                    ? 'Detection System Active'
                    : 'Activate Detection System',
                style: TextStyle(
                  color: _detectionSystemActive ? Colors.green : Colors.grey,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: _detectionSystemActive
                    ? Colors.green.withOpacity(0.1)
                    : null,
              ),
            ),
          ),
          // Children's camera cubes
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _children.length,
              itemBuilder: (context, index) {
                final child = _children[index];
                return ChildCameraCube(
                  childName: child['name'],
                  imageUrl: child['imageUrl'],
                  isHeadCameraActive: child['isHeadCameraActive'],
                  isStaticCameraActive: child['isStaticCameraActive'],
                  onHeadCameraTap: () => _toggleHeadCamera(index),
                  onStaticCameraTap: () => _toggleStaticCamera(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
