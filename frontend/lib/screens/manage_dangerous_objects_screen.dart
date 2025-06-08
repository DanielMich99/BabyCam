import 'package:flutter/material.dart';
import '../components/settings/add_dangerous_object_section.dart';
import 'dangerous_object_list_dialog.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';

class ManageDangerousObjectsScreen extends StatelessWidget {
  final int babyProfileId;
  const ManageDangerousObjectsScreen({Key? key, required this.babyProfileId})
      : super(key: key);

  Future<void> _openDangerousObjectListDialog(
      BuildContext context, String cameraType, String cameraLabel) async {
    final deletedObjects = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DangerousObjectListDialog(
          babyProfileId: babyProfileId,
          cameraType: cameraType,
        ),
      ),
    );
    if (deletedObjects != null &&
        deletedObjects is List &&
        deletedObjects.isNotEmpty) {
      await _deleteObjects(context, deletedObjects);
      _showDeletedDialog(context, deletedObjects, cameraLabel);
    }
  }

  Future<void> _deleteObjects(BuildContext context, List deletedObjects) async {
    final token = await AuthState.getAuthToken();
    if (token == null) return;
    for (final obj in deletedObjects) {
      final id = obj['id'];
      final uri = Uri.parse('http://10.0.2.2:8000/classes/$id');
      await http.delete(uri, headers: {'Authorization': 'Bearer $token'});
    }
  }

  void _showDeletedDialog(
      BuildContext context, List deletedObjects, String cameraLabel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deleted from $cameraLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              deletedObjects.map<Widget>((obj) => Text(obj['name'])).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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
                onPressed: () => _openDangerousObjectListDialog(
                    context, 'head_camera', 'Head Camera'),
                child: const Text('View Dangerous Objects (Head Camera)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _openDangerousObjectListDialog(
                    context, 'static_camera', 'Static Camera'),
                child: const Text('View Dangerous Objects (Static Camera)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
