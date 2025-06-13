import 'package:flutter/material.dart';
import '../../screens/class_edit_screen.dart';
import '../../services/user_service.dart';

class AddDangerousObjectSection extends StatelessWidget {
  final String cameraType;
  final String? buttonText;
  const AddDangerousObjectSection(
      {Key? key, required this.cameraType, this.buttonText})
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
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(buttonText ?? 'Add/Edit Object Class'),
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
