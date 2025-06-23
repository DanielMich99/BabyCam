import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import '../screens/class_edit_screen.dart';
import '../components/dangerous_objects/pending_changes_cards.dart';
import '../components/dangerous_objects/dialogs.dart';
import '../screens/dangerous_object_list_dialog.dart';
import '../services/user_service.dart';
import '../services/websocket_service.dart';
import '../services/dangerous_objects_service.dart';

class ManageDangerousObjectsScreen extends StatefulWidget {
  final int babyProfileId;
  final String cameraType;
  const ManageDangerousObjectsScreen({
    Key? key,
    required this.babyProfileId,
    required this.cameraType,
  }) : super(key: key);

  @override
  State<ManageDangerousObjectsScreen> createState() =>
      _ManageDangerousObjectsScreenState();
}

class _ManageDangerousObjectsScreenState
    extends State<ManageDangerousObjectsScreen> {
  final List<Map<String, dynamic>> _pendingDeletions = [];
  final List<Map<String, dynamic>> _pendingAdditions = [];
  final List<Map<String, dynamic>> _pendingUpdates = [];
  final List<Map<String, dynamic>> _pendingRiskLevelUpdates = [];
  final _websocketService = WebSocketService();
  final _dangerousObjectsService = DangerousObjectsService();

  @override
  void initState() {
    super.initState();
    _websocketService.addDetectionListener(_handleWebSocketEvent);
  }

  @override
  void dispose() {
    _websocketService.removeDetectionListener(_handleWebSocketEvent);
    super.dispose();
  }

  void _handleWebSocketEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    if (event['type'] == 'model_training_completed') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Model Training'),
          content: const Text('Model training completed! New model is ready.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openDangerousObjectListDialog(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => DangerousObjectListDialog(
          babyProfileId: widget.babyProfileId,
          cameraType: widget.cameraType == 'Head Camera'
              ? 'head_camera'
              : 'static_camera',
          allowCameraTypeChange: false,
        ),
      ),
    );
    if (result != null && result is List) {
      setState(() {
        for (var obj in result) {
          if (obj['original_id'] != null) {
            // This is an update
            _pendingUpdates.add(obj);
          } else if (obj['old_risk'] != null && obj['new_risk'] != null) {
            // This is a risk level update
            final existing = _pendingRiskLevelUpdates
                .indexWhere((e) => e['id'] == obj['id']);
            if (existing != -1) {
              _pendingRiskLevelUpdates[existing] = obj;
            } else {
              _pendingRiskLevelUpdates.add(obj);
            }
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
    String cameraType = editClass != null
        ? (editClass['modelType'] == 'head_camera_model'
            ? 'Head Camera'
            : 'Static Camera')
        : widget.cameraType;

    String? objectName = editClass != null
        ? editClass['className']
        : await showDialog<String>(
            context: context,
            builder: (context) => const ObjectNameInputDialog(),
          );
    if (objectName == null || objectName.isEmpty) return;

    String? riskLevel = editClass != null
        ? editClass['riskLevel']
        : await showDialog<String>(
            context: context,
            builder: (context) => const RiskLevelSelectionDialog(),
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

  void _removePendingRiskLevelUpdate(int index) {
    setState(() {
      _pendingRiskLevelUpdates.removeAt(index);
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
        _pendingUpdates.isEmpty &&
        _pendingRiskLevelUpdates.isEmpty) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _dangerousObjectsService.updateModel(
        babyProfileId: widget.babyProfileId,
        cameraType: widget.cameraType,
        newClasses: _pendingAdditions,
        updatedClasses: _pendingUpdates,
        deletedClasses:
            _pendingDeletions.map((obj) => obj['name'] as String).toList(),
      );

      Navigator.of(context).pop(); // Remove loading
      setState(() {
        _pendingAdditions.clear();
        _pendingDeletions.clear();
        _pendingUpdates.clear();
        _pendingRiskLevelUpdates.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model updated successfully!')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Manage Dangerous Objects (${widget.cameraType})'),
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
              PendingAdditionsCard(
                pendingAdditions: _pendingAdditions,
                onEdit: (index) => _startAddObjectFlow(context,
                    editClass: _pendingAdditions[index], editIndex: index),
                onRemove: _removePendingAddition,
              ),
              if (_pendingAdditions.isNotEmpty) const SizedBox(height: 24),
              PendingRiskLevelUpdatesCard(
                pendingRiskLevelUpdates: _pendingRiskLevelUpdates,
                onUndo: _removePendingRiskLevelUpdate,
              ),
              if (_pendingRiskLevelUpdates.isNotEmpty)
                const SizedBox(height: 24),
              PendingUpdatesCard(
                pendingUpdates: _pendingUpdates,
                onEdit: (index) => _startAddObjectFlow(context,
                    editClass: _pendingUpdates[index], editIndex: index),
                onRemove: _removePendingUpdate,
              ),
              if (_pendingUpdates.isNotEmpty) const SizedBox(height: 24),
              PendingDeletionsCard(
                pendingDeletions: _pendingDeletions,
                onUndo: _undoPendingDeletion,
              ),
              if (_pendingDeletions.isNotEmpty) const SizedBox(height: 24),
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
