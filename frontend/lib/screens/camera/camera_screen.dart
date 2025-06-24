import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/baby_profile.dart';
import '../../components/camera/child_camera_cube.dart';
import '../../services/auth_state.dart';
import '../../services/camera_service.dart';
import '../../services/websocket_service.dart';
import '../../services/monitoring_service.dart';
import '../../components/home/add_baby_dialog.dart';
import '../../components/camera/video_stream_player.dart';
import '../../components/camera/camera_app_bar.dart';
import '../../components/camera/camera_grid.dart';
import '../../components/camera/camera_preview_pager.dart';
import '../../components/camera/camera_helpers.dart';
import '../../config/app_config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late Future<List<BabyProfile>> _babiesFuture;
  bool _detectionSystemActive = false;
  final _websocketService = WebSocketService();
  final _monitoringService = MonitoringService();
  bool _cameraConnectionInProgress = false;

  @override
  void initState() {
    super.initState();
    _babiesFuture = fetchBabies();
    _websocketService.addDetectionListener(_handleDetection);
    _websocketService.addDetectionListener(_handleCameraEvents);
  }

  @override
  void dispose() {
    _websocketService.removeDetectionListener(_handleDetection);
    _websocketService.removeDetectionListener(_handleCameraEvents);
    super.dispose();
  }

  void _handleDetection(Map<String, dynamic> detection) {
    if (!_detectionSystemActive || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Detection: ${detection['type']} - ${detection['confidence']}%'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleCameraEvents(Map<String, dynamic> event) {
    if (!mounted) return;
    final type = event['type'];
    if (type == 'camera_connected') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera connected!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (type == 'camera_disconnected') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Camera disconnected!'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleDetectionSystem() async {
    try {
      // Get current babies data
      final babies = await _babiesFuture;

      // Prepare camera profiles for monitoring
      final List<Map<String, dynamic>> cameraProfiles = [];

      for (final baby in babies) {
        if (baby.camera1On && baby.staticCameraIp != null) {
          cameraProfiles.add({
            'baby_profile_id': baby.id,
            'camera_type': 'static_camera',
          });
        }
        if (baby.camera2On && baby.headCameraIp != null) {
          cameraProfiles.add({
            'baby_profile_id': baby.id,
            'camera_type': 'head_camera',
          });
        }
      }

      if (cameraProfiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No active cameras found. Please connect cameras first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!_detectionSystemActive) {
        // Start monitoring
        await _monitoringService.startMonitoring(cameraProfiles);
        setState(() {
          _detectionSystemActive = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detection System Activated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Stop monitoring
        await _monitoringService.stopMonitoring(cameraProfiles);
        setState(() {
          _detectionSystemActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detection System Deactivated'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<BabyProfile>> fetchBabies() async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
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

  Future<void> _handleCameraConnection(
      List<BabyProfile> babies, int index, String cameraType) async {
    if (_cameraConnectionInProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please wait for the current camera to finish connecting')),
      );
      return;
    }
    setState(() {
      _cameraConnectionInProgress = true;
    });
    final baby = babies[index];
    final isHeadCamera = cameraType == 'head_camera';
    try {
      if ((isHeadCamera && baby.camera2On) ||
          (!isHeadCamera && baby.camera1On)) {
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
        return;
      }
      setState(() {
        babies[index] = baby.copyWith(
          isConnectingCamera1: !isHeadCamera,
          isConnectingCamera2: isHeadCamera,
        );
      });
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
      showErrorDialog(context, 'Failed to connect camera', e.toString(), () {
        setState(() {
          _babiesFuture = fetchBabies();
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _cameraConnectionInProgress = false;
        });
      } else {
        _cameraConnectionInProgress = false;
      }
    }
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
      showErrorDialog(context, 'Failed to reset cameras', e.toString(), () {
        setState(() {
          _babiesFuture = fetchBabies();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _cameraConnectionInProgress,
          child: Scaffold(
            appBar: buildCameraAppBar(
              onGridView: _navigateToAllCameras,
              onResetCameras: _resetAllCameras,
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
                  if (baby.camera1On && baby.staticCameraIp != null) {
                    activeCameras.add({
                      'name': baby.name,
                      'type': 'Static',
                      'profilePicture': baby.profilePicture,
                      'ip': baby.staticCameraIp,
                    });
                  }
                  if (baby.camera2On && baby.headCameraIp != null) {
                    activeCameras.add({
                      'name': baby.name,
                      'type': 'Head',
                      'profilePicture': baby.profilePicture,
                      'ip': baby.headCameraIp,
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
                          color: _detectionSystemActive
                              ? Colors.green
                              : Colors.grey,
                        ),
                        label: Text(
                          _detectionSystemActive
                              ? 'Detection System Active'
                              : 'Activate Detection System',
                          style: TextStyle(
                            color: _detectionSystemActive
                                ? Colors.green
                                : Colors.grey,
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
                            child: CameraGrid(
                              babies: babies,
                              onCameraConnection: _handleCameraConnection,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (activeCameras.isNotEmpty)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                child: CameraPreviewPager(
                                  activeCameras: activeCameras,
                                ),
                              ),
                            ),
                          if (activeCameras.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 32.0, bottom: 16.0),
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
          ),
        ),
        if (_cameraConnectionInProgress) const _CameraConnectingOverlay(),
      ],
    );
  }

  void _navigateToAllCameras() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All cameras view not implemented yet')),
    );
  }
}

class _CameraConnectingOverlay extends StatelessWidget {
  const _CameraConnectingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      alignment: Alignment.center,
      child: const _PleaseWaitMessage(),
    );
  }
}

class _PleaseWaitMessage extends StatefulWidget {
  const _PleaseWaitMessage();

  @override
  State<_PleaseWaitMessage> createState() => _PleaseWaitMessageState();
}

class _PleaseWaitMessageState extends State<_PleaseWaitMessage> {
  late Timer _timer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dotCount = _dotCount % 3 + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text(
      'Please wait$dots',
      style: const TextStyle(color: Colors.white, fontSize: 18),
    );
  }
}
