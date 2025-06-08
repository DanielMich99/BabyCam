import 'package:flutter/material.dart';
import '../components/settings/add_dangerous_object_section.dart';
import 'dangerous_object_list_dialog.dart';

class ManageDangerousObjectsScreen extends StatelessWidget {
  final int babyProfileId;
  const ManageDangerousObjectsScreen({Key? key, required this.babyProfileId})
      : super(key: key);

  void _openDangerousObjectListDialog(BuildContext context, String cameraType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DangerousObjectListDialog(
          babyProfileId: babyProfileId,
          cameraType: cameraType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Dangerous Objects'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddDangerousObjectSection(cameraType: 'Head Camera'),
              const SizedBox(height: 16),
              AddDangerousObjectSection(cameraType: 'Static Camera'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () =>
                    _openDangerousObjectListDialog(context, 'head_camera'),
                child: const Text('View Dangerous Objects (Head Camera)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    _openDangerousObjectListDialog(context, 'static_camera'),
                child: const Text('View Dangerous Objects (Static Camera)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
