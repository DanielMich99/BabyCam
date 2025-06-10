import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';
import 'child_camera_cube.dart';

typedef CameraConnectionCallback = void Function(
    List<BabyProfile> babies, int index, String cameraType);

class CameraGrid extends StatelessWidget {
  final List<BabyProfile> babies;
  final CameraConnectionCallback onCameraConnection;

  const CameraGrid({
    Key? key,
    required this.babies,
    required this.onCameraConnection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            profilePicture: baby.profilePicture,
            isHeadCameraActive: baby.camera2On,
            isStaticCameraActive: baby.camera1On,
            isHeadCameraConnecting: baby.isConnectingCamera2,
            isStaticCameraConnecting: baby.isConnectingCamera1,
            onHeadCameraTap: () =>
                onCameraConnection(babies, index, 'head_camera'),
            onStaticCameraTap: () =>
                onCameraConnection(babies, index, 'static_camera'),
          );
        },
      ),
    );
  }
}
