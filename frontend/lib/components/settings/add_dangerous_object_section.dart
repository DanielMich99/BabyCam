import 'package:flutter/material.dart';
import '../../screens/class_edit_screen.dart';
import '../../services/user_service.dart';

class AddDangerousObjectSection extends StatelessWidget {
  final String cameraType;
  const AddDangerousObjectSection({Key? key, required this.cameraType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Dangerous Object ($cameraType)',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Add/Edit Object Class'),
              onPressed: () async {
                final userService = UserService();
                final babyProfile = await userService.getCurrentBabyProfile();

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassEditScreen(
                      className: 'Dangerous Object ($cameraType)',
                      initialImages: const [],
                      babyProfileId: babyProfile.id,
                      modelType: cameraType == 'Head Camera'
                          ? 'head_camera_model'
                          : 'static_camera_model',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
