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
          // Swipeable video preview section (even larger and higher)
          Padding(
            padding: const EdgeInsets.only(bottom: 0.0, top: 8.0),
            child: SizedBox(
              height: 280,
              child: _buildCameraPreviewPager(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreviewPager() {
    // Gather all active cameras
    final List<Map<String, dynamic>> activeCameras = [];
    for (final child in _children) {
      if (child['isStaticCameraActive'] == true) {
        activeCameras.add({
          'name': child['name'],
          'type': 'Static',
          'imageUrl': child['imageUrl'],
        });
      }
      if (child['isHeadCameraActive'] == true) {
        activeCameras.add({
          'name': child['name'],
          'type': 'Head',
          'imageUrl': child['imageUrl'],
        });
      }
    }
    if (activeCameras.isEmpty) {
      return Center(
        child: Text(
          'No active cameras',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }
    return PageView.builder(
      itemCount: activeCameras.length,
      controller: PageController(viewportFraction: 0.8),
      itemBuilder: (context, index) {
        final cam = activeCameras[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(cam['imageUrl']),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cam['name'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${cam['type']} Camera',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.videocam, size: 40, color: Colors.blueGrey),
                  // Replace above with actual video feed widget if available
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
