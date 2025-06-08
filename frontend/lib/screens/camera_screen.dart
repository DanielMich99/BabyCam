import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/baby_profile.dart';
import '../components/camera/child_camera_cube.dart';
import '../services/auth_state.dart';
import '../services/camera_service.dart';
import '../components/home/add_baby_dialog.dart';

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

  Future<void> _handleCameraConnection(
      List<BabyProfile> babies, int index, String cameraType) async {
    final baby = babies[index];
    final isHeadCamera = cameraType == 'head_camera';

    // If camera is already connected, disconnect it
    if ((isHeadCamera && baby.camera2On) || (!isHeadCamera && baby.camera1On)) {
      try {
        await CameraService.disconnectCamera(baby.id, cameraType);
        setState(() {
          babies[index] = baby.copyWith(
            camera1On: isHeadCamera ? baby.camera1On : false,
            camera2On: isHeadCamera ? false : baby.camera2On,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera disconnected successfully')),
        );
      } catch (e) {
        _showErrorDialog('Failed to disconnect camera', e.toString());
      }
      return;
    }

    // Set connecting state
    setState(() {
      babies[index] = baby.copyWith(
        isConnectingCamera1: !isHeadCamera,
        isConnectingCamera2: isHeadCamera,
      );
    });

    try {
      final success = await CameraService.connectCamera(baby.id, cameraType);
      if (success) {
        setState(() {
          babies[index] = baby.copyWith(
            camera1On: !isHeadCamera,
            camera2On: isHeadCamera,
            isConnectingCamera1: false,
            isConnectingCamera2: false,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera connected successfully')),
        );
      }
    } catch (e) {
      setState(() {
        babies[index] = baby.copyWith(
          isConnectingCamera1: false,
          isConnectingCamera2: false,
        );
      });
      _showErrorDialog('Failed to connect camera', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _babiesFuture = fetchBabies();
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllCameras() async {
    try {
      final userId = await AuthState.getUserId();
      if (userId == null) throw Exception('User not authenticated');

      final updatedCount = await CameraService.resetUserCameras(userId);
      setState(() {
        _babiesFuture = fetchBabies();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Successfully reset $updatedCount camera connections')),
      );
    } catch (e) {
      _showErrorDialog('Failed to reset cameras', e.toString());
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetAllCameras,
            tooltip: 'Reset All Cameras',
          ),
        ],
      ),
      body: FutureBuilder<List<BabyProfile>>(
        future: _babiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No babies found.'));
          }
          final babies = snapshot.data!;
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
          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                        horizontal: 24, vertical: 16),
                    backgroundColor: _detectionSystemActive
                        ? Colors.green.withOpacity(0.1)
                        : null,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: GridView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
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
                              isHeadCameraConnecting: baby.isConnectingCamera2,
                              isStaticCameraConnecting:
                                  baby.isConnectingCamera1,
                              onHeadCameraTap: () => _handleCameraConnection(
                                  babies, index, 'head_camera'),
                              onStaticCameraTap: () => _handleCameraConnection(
                                  babies, index, 'static_camera'),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (activeCameras.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 250,
                          child:
                              _buildCameraPreviewPagerFromList(activeCameras),
                        ),
                      ),
                    if (activeCameras.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                        child: Text(
                          'No active cameras',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper to build pager from a given list
  Widget _buildCameraPreviewPagerFromList(
      List<Map<String, dynamic>> activeCameras) {
    return PageView.builder(
      itemCount: activeCameras.length,
      controller: PageController(viewportFraction: 0.8),
      itemBuilder: (context, index) {
        final cam = activeCameras[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueGrey[50],
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

  void _navigateToAllCameras() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All cameras view not implemented yet')),
    );
  }
}
