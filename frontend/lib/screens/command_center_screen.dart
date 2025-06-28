import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../services/auth_service.dart';
import '../components/camera/full_screen_video_stream.dart';
import '../components/camera/video_stream_player.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({Key? key}) : super(key: key);

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  late Future<List<BabyProfile>> _babiesFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _babiesFuture = _fetchBabies();
  }

  Future<List<BabyProfile>> _fetchBabies() async {
    return await _authService.getBabyProfiles();
  }

  List<Map<String, dynamic>> _getActiveCameras(List<BabyProfile> babies) {
    final List<Map<String, dynamic>> activeCameras = [];
    for (final baby in babies) {
      if (baby.camera1On && baby.staticCameraIp != null) {
        activeCameras.add({
          'name': baby.name,
          'type': 'Static',
          'profilePicture': baby.profilePicture,
          'ip': baby.staticCameraIp,
          'babyId': baby.id,
        });
      }
      if (baby.camera2On && baby.headCameraIp != null) {
        activeCameras.add({
          'name': baby.name,
          'type': 'Head',
          'profilePicture': baby.profilePicture,
          'ip': baby.headCameraIp,
          'babyId': baby.id,
        });
      }
    }
    return activeCameras;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Center'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _babiesFuture = _fetchBabies();
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<BabyProfile>>(
        future: _babiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _babiesFuture = _fetchBabies();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No baby profiles found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final babies = snapshot.data!;
          final activeCameras = _getActiveCameras(babies);

          if (activeCameras.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No cameras connected',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect cameras from the Camera screen\nto view them here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Go to Camera Screen'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.videocam, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      '${activeCameras.length} Connected Camera${activeCameras.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    const Spacer(),
                    if (activeCameras.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Camera grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: activeCameras.length,
                  itemBuilder: (context, index) {
                    final camera = activeCameras[index];
                    return _buildCameraCard(context, camera);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraCard(BuildContext context, Map<String, dynamic> camera) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Camera feed
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenVideoStream(
                        streamUrl: 'http://${camera['ip']}:80/stream',
                        title: '${camera['name']} - ${camera['type']} Camera',
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    VideoStreamPlayer(
                      streamUrl: 'http://${camera['ip']}:80/stream',
                      isActive: true,
                    ),
                    // Camera type indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: camera['type'] == 'Head'
                              ? Colors.orange[600]
                              : Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          camera['type'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Camera info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: camera['profilePicture'] != null
                      ? AssetImage(camera['profilePicture'])
                      : null,
                  child: camera['profilePicture'] == null
                      ? Icon(Icons.child_care, color: Colors.grey, size: 20)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${camera['type']} Camera',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
