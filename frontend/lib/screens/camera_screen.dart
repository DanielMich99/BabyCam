import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baby_profile.dart';
import '../components/camera/child_camera_cube.dart';
import '../services/auth_state.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late Future<List<BabyProfile>> _babiesFuture;
  bool _detectionSystemActive = false;

  @override
  void initState() {
    super.initState();
    _babiesFuture = fetchBabies();
  }

  Future<List<BabyProfile>> fetchBabies() async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/baby_profiles/my_profiles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BabyProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load babies');
    }
  }

  void _toggleDetectionSystem() {
    setState(() {
      _detectionSystemActive = !_detectionSystemActive;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_detectionSystemActive
            ? 'Detection System Activated'
            : 'Detection System Deactivated'),
      ),
    );
  }

  void _toggleHeadCamera(List<BabyProfile> babies, int index) {
    setState(() {
      babies[index] =
          babies[index].copyWith(camera2On: !(babies[index].camera2On));
    });
  }

  void _toggleStaticCamera(List<BabyProfile> babies, int index) {
    setState(() {
      babies[index] =
          babies[index].copyWith(camera1On: !(babies[index].camera1On));
    });
  }

  void _navigateToAllCameras() {
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
      body: FutureBuilder<List<BabyProfile>>(
        future: _babiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No babies found.'));
          }
          final babies = snapshot.data!;
          return Column(
            children: [
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
                      color:
                          _detectionSystemActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: _detectionSystemActive
                        ? Colors.green.withOpacity(0.1)
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: babies.length,
                        itemBuilder: (context, index) {
                          final baby = babies[index];
                          return ChildCameraCube(
                            childName: baby.name,
                            profilePicture: baby.profilePicture ??
                                'assets/images/default_baby.jpg',
                            isHeadCameraActive: baby.camera2On,
                            isStaticCameraActive: baby.camera1On,
                            onHeadCameraTap: () =>
                                _toggleHeadCamera(babies, index),
                            onStaticCameraTap: () =>
                                _toggleStaticCamera(babies, index),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 280,
                      child: _buildCameraPreviewPager(babies),
                    ),
                    Spacer(flex: 2),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraPreviewPager(List<BabyProfile> babies) {
    final List<Map<String, dynamic>> activeCameras = [];
    for (final baby in babies) {
      if (baby.camera1On) {
        activeCameras.add({
          'name': baby.name,
          'type': 'Static',
          'profilePicture':
              baby.profilePicture ?? 'assets/images/default_baby.jpg',
        });
      }
      if (baby.camera2On) {
        activeCameras.add({
          'name': baby.name,
          'type': 'Head',
          'profilePicture':
              baby.profilePicture ?? 'assets/images/default_baby.jpg',
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
                    backgroundImage: AssetImage(cam['profilePicture'] ??
                        'assets/images/default_baby.jpg'),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
