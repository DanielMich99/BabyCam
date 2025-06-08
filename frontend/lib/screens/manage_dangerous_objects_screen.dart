import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';
import '../screens/class_edit_screen.dart';
import '../components/settings/add_dangerous_object_section.dart';
import 'dangerous_object_list_dialog.dart';
import '../services/user_service.dart';

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

  Future<void> _startAddObjectFlow(BuildContext context) async {
    // Step 1: Select camera type
    String? cameraType = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Camera Type'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Head Camera'),
            child: const Text('Head Camera'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Static Camera'),
            child: const Text('Static Camera'),
          ),
        ],
      ),
    );
    if (cameraType == null) return;

    // Step 2: Enter object name
    String? objectName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Object Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. scissors'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
    if (objectName == null || objectName.isEmpty) return;

    // Step 3: Select risk level
    String? riskLevel = await showDialog<String>(
      context: context,
      builder: (context) {
        String selected = 'medium';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Select Risk Level'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: 'low',
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v!),
                  title: const Text('Low'),
                ),
                RadioListTile<String>(
                  value: 'medium',
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v!),
                  title: const Text('Medium'),
                ),
                RadioListTile<String>(
                  value: 'high',
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v!),
                  title: const Text('High'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text('Next'),
              ),
            ],
          ),
        );
      },
    );
    if (riskLevel == null) return;

    // Step 4: Go to ClassEditScreen
    final userService = UserService();
    final babyProfile = await userService.getCurrentBabyProfile();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassEditScreen(
          className: objectName,
          initialImages: const [],
          babyProfileId: babyProfile.id,
          modelType: cameraType == 'Head Camera'
              ? 'head_camera_model'
              : 'static_camera_model',
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
              ElevatedButton(
                onPressed: () => _startAddObjectFlow(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  side: const BorderSide(color: Colors.transparent),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('➕ Add Object Class',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue)),
              ),
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
