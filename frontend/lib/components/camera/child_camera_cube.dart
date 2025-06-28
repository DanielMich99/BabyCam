import 'package:flutter/material.dart';

class ChildCameraCube extends StatelessWidget {
  final String childName;
  final String? profilePicture;
  final bool isHeadCameraActive;
  final bool isStaticCameraActive;
  final bool isHeadCameraConnecting;
  final bool isStaticCameraConnecting;
  final VoidCallback onHeadCameraTap;
  final VoidCallback onStaticCameraTap;

  const ChildCameraCube({
    Key? key,
    required this.childName,
    required this.profilePicture,
    required this.isHeadCameraActive,
    required this.isStaticCameraActive,
    required this.isHeadCameraConnecting,
    required this.isStaticCameraConnecting,
    required this.onHeadCameraTap,
    required this.onStaticCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Baby Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue[50],
              backgroundImage:
                  profilePicture != null ? AssetImage(profilePicture!) : null,
              child: profilePicture == null
                  ? Icon(Icons.child_care, color: Colors.grey, size: 36)
                  : null,
            ),
            const SizedBox(height: 10),
            // Baby Name
            Text(
              childName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Camera Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCameraButton(
                  context,
                  'Head',
                  Icons.videocam,
                  isHeadCameraActive,
                  isHeadCameraConnecting,
                  onHeadCameraTap,
                ),
                _buildCameraButton(
                  context,
                  'Static',
                  Icons.videocam_outlined,
                  isStaticCameraActive,
                  isStaticCameraConnecting,
                  onStaticCameraTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isActive,
    bool isConnecting,
    VoidCallback onTap,
  ) {
    Color buttonColor;
    if (isConnecting) {
      buttonColor = Colors.amber;
    } else if (isActive) {
      buttonColor = Colors.green;
    } else {
      buttonColor = Colors.grey.shade400;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Material(
              color: buttonColor.withOpacity(0.15),
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(icon, size: 28),
                color: buttonColor,
                onPressed: isConnecting ? null : onTap,
                tooltip: label,
              ),
            ),
            if (isConnecting)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: buttonColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
