import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';
import 'dart:convert';
import '../icons/head_camera_icon.dart';
import '../icons/static_camera_icon.dart';

typedef BabyOptionSelected = void Function(int index, String option);
typedef CameraToggle = void Function(int index, int cameraNumber);

class BabyProfilesList extends StatelessWidget {
  final List<BabyProfile> babies;
  final Function(int) onBabySelected;
  final BabyOptionSelected? onOptionSelected;
  final CameraToggle? onCameraToggle;

  const BabyProfilesList({
    Key? key,
    required this.babies,
    required this.onBabySelected,
    this.onOptionSelected,
    this.onCameraToggle,
  }) : super(key: key);

  ImageProvider _getProfileImage(String? profilePicture) {
    if (profilePicture != null) {
      if (profilePicture.startsWith('/9j/') ||
          profilePicture.startsWith('iVBOR') ||
          profilePicture.startsWith('data:image')) {
        try {
          final base64Str = profilePicture.contains(',')
              ? profilePicture.split(',').last
              : profilePicture;
          return MemoryImage(base64Decode(base64Str));
        } catch (_) {}
      } else {
        return AssetImage(profilePicture);
      }
    }
    return const AssetImage('assets/images/default_baby.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        itemCount: babies.length,
        itemBuilder: (context, index) {
          final baby = babies[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _getProfileImage(baby.profilePicture),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      baby.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: 'Head Camera Model',
                          onPressed: onOptionSelected != null
                              ? () =>
                                  onOptionSelected!(index, 'head_camera_model')
                              : null,
                          icon: const Align(
                            alignment: Alignment(0, -0.1), // מרים את האייקון טיפה למעלה
                            child: HeadCameraIcon(),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Static Camera Model',
                          onPressed: onOptionSelected != null
                              ? () =>
                                  onOptionSelected!(index, 'static_camera_model')
                              : null,
                          icon: StaticCameraIcon(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.settings,
                            color: Colors.blueAccent, size: 28),
                        tooltip: 'Manage',
                        onPressed: onOptionSelected != null
                            ? () => onOptionSelected!(index, 'settings')
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
