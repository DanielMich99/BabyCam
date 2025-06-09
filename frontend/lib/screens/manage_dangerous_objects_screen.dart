import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';
import '../screens/class_edit_screen.dart';
import '../components/settings/add_dangerous_object_section.dart';
import 'dangerous_object_list_dialog.dart';
import '../services/user_service.dart';
import 'dart:convert';
import '../services/training_service.dart';

class ManageDangerousObjectsScreen extends StatefulWidget {
  final int babyProfileId;
  final String cameraType;
  const ManageDangerousObjectsScreen(
      {Key? key, required this.babyProfileId, required this.cameraType})
      : super(key: key);

  @override
  State<ManageDangerousObjectsScreen> createState() =>
      _ManageDangerousObjectsScreenState();
}

class _ManageDangerousObjectsScreenState
    extends State<ManageDangerousObjectsScreen> {
  final List<Map<String, dynamic>> _pendingDeletions = [];
  final List<Map<String, dynamic>> _pendingAdditions = [];
  final List<Map<String, dynamic>> _pendingUpdates = [];

  Future<void> _openDangerousObjectListDialog(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DangerousObjectListDialog(
          babyProfileId: widget.babyProfileId,
        ),
      ),
    );
    if (result != null && result is List) {
      setState(() {
        for (var obj in result) {
          if (obj['original_id'] != null) {
            // This is an update
            _pendingUpdates.add(obj);
          } else {
            // This is a deletion
            _pendingDeletions.add({
              'id': obj['id'],
              'name': obj['name'],
              'risk_level': obj['risk_level'],
              'camera_label': obj['camera_type'] == 'head_camera'
                  ? 'Head Camera'
                  : 'Static Camera',
            });
          }
        }
      });
    }
  }

  Future<void> _startAddObjectFlow(BuildContext context,
      {Map<String, dynamic>? editClass, int? editIndex}) async {
    String? cameraType = editClass != null
        ? (editClass['modelType'] == 'head_camera_model'
            ? 'Head Camera'
            : 'Static Camera')
        : await showDialog<String>(
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

    String? objectName = editClass != null
        ? editClass['className']
        : await showDialog<String>(
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
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Next'),
                  ),
                ],
              );
            },
          );
    if (objectName == null || objectName.isEmpty) return;

    String? riskLevel = editClass != null
        ? editClass['riskLevel']
        : await showDialog<String>(
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

    final userService = UserService();
    final babyProfile = await userService.getCurrentBabyProfile();
    if (!context.mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassEditScreen(
          className: objectName,
          initialImages:
              editClass != null ? List.from(editClass['images']) : const [],
          babyProfileId: babyProfile.id,
          modelType: cameraType == 'Head Camera'
              ? 'head_camera_model'
              : 'static_camera_model',
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        if (editIndex != null) {
          _pendingAdditions[editIndex] = result;
        } else {
          _pendingAdditions.add(result);
        }
      });
    }
  }

  void _removePendingAddition(int index) {
    setState(() {
      _pendingAdditions.removeAt(index);
    });
  }

  void _removePendingUpdate(int index) {
    setState(() {
      _pendingUpdates.removeAt(index);
    });
  }

  void _undoPendingDeletion(int index) {
    setState(() {
      _pendingDeletions.removeAt(index);
    });
  }

  Future<void> _updateModel(BuildContext context) async {
    if (_pendingAdditions.isEmpty &&
        _pendingDeletions.isEmpty &&
        _pendingUpdates.isEmpty) return;
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      // 1. Upload all new images and label files for each pending addition and update
      for (final cls in [..._pendingAdditions, ..._pendingUpdates]) {
        await TrainingService.uploadFilesToTemp(List.from(cls['images']));
      }
      // 2. Prepare new_classes
      List<Map<String, dynamic>> newClasses = _pendingAdditions.map((cls) {
        final imageFilenames = <String>[];
        final labelFilenames = <String>[];
        for (var image in cls['images']) {
          imageFilenames.add(image.filename);
          labelFilenames.add('${image.filename.split('.').first}.txt');
        }
        return {
          'name': cls['className'],
          'risk_level': cls['riskLevel'],
          'files': {
            'images': imageFilenames,
            'labels': labelFilenames,
          },
        };
      }).toList();
      // 3. Prepare updated_classes
      List<Map<String, dynamic>> updatedClasses = _pendingUpdates.map((cls) {
        final imageFilenames = <String>[];
        final labelFilenames = <String>[];
        for (var image in cls['images']) {
          imageFilenames.add(image.filename);
          labelFilenames.add('${image.filename.split('.').first}.txt');
        }
        return {
          'id': cls['original_id'],
          'name': cls['className'],
          'risk_level': cls['riskLevel'],
          'files': {
            'images': imageFilenames,
            'labels': labelFilenames,
          },
        };
      }).toList();
      // 4. Prepare deleted_classes
      List<String> deletedClasses =
          _pendingDeletions.map((obj) => obj['name'] as String).toList();
      // 5. Prepare request
      final body = {
        'baby_profile_id': widget.babyProfileId,
        'model_type': widget.cameraType == 'Head Camera'
            ? 'head_camera'
            : 'static_camera',
        'new_classes': newClasses,
        'updated_classes': updatedClasses,
        'deleted_classes': deletedClasses,
      };
      // 6. Send request
      final token = await AuthState.getAuthToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/model/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      Navigator.of(context).pop(); // Remove loading
      if (response.statusCode == 200) {
        setState(() {
          _pendingAdditions.clear();
          _pendingDeletions.clear();
          _pendingUpdates.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update model: ${response.body}')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              ElevatedButton(
                onPressed: () => _startAddObjectFlow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Colors.transparent),
                ),
                child: const Text('Add Object Class',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _openDangerousObjectListDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Colors.transparent),
                ),
                child: const Text('View Dangerous Objects',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue)),
              ),
              const SizedBox(height: 32),
              if (_pendingAdditions.isNotEmpty) ...[
                Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Additions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._pendingAdditions.asMap().entries.map((entry) {
                          final obj = entry.value;
                          final idx = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle,
                                    color: Colors.green[300], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        '${obj['className']} (Risk: ${obj['riskLevel']}, ${obj['modelType'] == 'head_camera_model' ? 'Head Camera' : 'Static Camera'})',
                                        style: const TextStyle(fontSize: 15))),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Edit',
                                  onPressed: () => _startAddObjectFlow(context,
                                      editClass: obj, editIndex: idx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Remove',
                                  onPressed: () => _removePendingAddition(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_pendingUpdates.isNotEmpty) ...[
                Card(
                  color: Colors.orange[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Updates:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._pendingUpdates.asMap().entries.map((entry) {
                          final obj = entry.value;
                          final idx = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.edit,
                                    color: Colors.orange[300], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        '${obj['className']} (Risk: ${obj['riskLevel']}, ${obj['camera_type'] == 'head_camera' ? 'Head Camera' : 'Static Camera'})',
                                        style: const TextStyle(fontSize: 15))),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'Edit',
                                  onPressed: () => _startAddObjectFlow(context,
                                      editClass: obj, editIndex: idx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Remove',
                                  onPressed: () => _removePendingUpdate(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
                        ..._pendingDeletions.asMap().entries.map((entry) {
                          final obj = entry.value;
                          final idx = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    color: Colors.red[300], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                        '${obj['name']} (Risk: ${obj['risk_level']}, ${obj['camera_label']})',
                                        style: const TextStyle(fontSize: 15))),
                                IconButton(
                                  icon: const Icon(Icons.undo,
                                      color: Colors.blue),
                                  tooltip: 'Undo',
                                  onPressed: () => _undoPendingDeletion(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: () => _updateModel(context),
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
