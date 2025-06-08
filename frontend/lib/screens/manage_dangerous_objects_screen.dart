import 'package:flutter/material.dart';
import '../components/settings/add_dangerous_object_section.dart';
import 'dangerous_object_list_dialog.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';

class ManageDangerousObjectsScreen extends StatefulWidget {
  final int babyProfileId;
  const ManageDangerousObjectsScreen({Key? key, required this.babyProfileId})
      : super(key: key);

  @override
  State<ManageDangerousObjectsScreen> createState() =>
      _ManageDangerousObjectsScreenState();
}

class _ManageDangerousObjectsScreenState
    extends State<ManageDangerousObjectsScreen> {
  final List<Map<String, dynamic>> _pendingDeletions = [];

  Future<void> _openDangerousObjectListDialog(
      BuildContext context, String cameraType, String cameraLabel) async {
    final deletedObjects = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DangerousObjectListDialog(
          babyProfileId: widget.babyProfileId,
          cameraType: cameraType,
        ),
      ),
    );
    if (deletedObjects != null &&
        deletedObjects is List &&
        deletedObjects.isNotEmpty) {
      setState(() {
        _pendingDeletions.addAll(deletedObjects.map((obj) => {
              'id': obj['id'],
              'name': obj['name'],
              'risk_level': obj['risk_level'],
              'camera_label': cameraLabel,
            }));
      });
    }
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
              AddDangerousObjectSection(
                  cameraType: 'Head Camera',
                  buttonText: 'Add Object Class (Head Camera)'),
              const SizedBox(height: 16),
              AddDangerousObjectSection(
                  cameraType: 'Static Camera',
                  buttonText: 'Add Object Class (Static Camera)'),
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
              const SizedBox(height: 32),
              if (_pendingDeletions.isNotEmpty) ...[
                Card(
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Deletions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._pendingDeletions.map((obj) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red[300], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(
                                          '${obj['name']} (Risk: ${obj['risk_level']}, ${obj['camera_label']})',
                                          style:
                                              const TextStyle(fontSize: 15))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Update Model',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
