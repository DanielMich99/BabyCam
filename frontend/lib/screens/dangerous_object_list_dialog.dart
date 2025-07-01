import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_state.dart';
import '../screens/class_edit_screen.dart';
import '../config/app_config.dart';

class DangerousObjectListDialog extends StatefulWidget {
  final int babyProfileId;
  final String cameraType;
  final bool allowCameraTypeChange;
  const DangerousObjectListDialog({
    Key? key,
    required this.babyProfileId,
    required this.cameraType,
    this.allowCameraTypeChange = true,
  }) : super(key: key);

  @override
  State<DangerousObjectListDialog> createState() =>
      _DangerousObjectListDialogState();
}

class _DangerousObjectListDialogState extends State<DangerousObjectListDialog> {
  List<Map<String, dynamic>> _dangerousObjects = [];
  Set<int> _selectedForDelete = {};
  bool _loading = true;
  String? _error;
  bool _deleteMode = false;
  late String _selectedCameraType;
  final List<Map<String, dynamic>> _pendingRiskLevelUpdates = [];

  @override
  void initState() {
    super.initState();
    _selectedCameraType = widget.cameraType;
    _fetchDangerousObjects();
  }

  Future<void> _fetchDangerousObjects() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await AuthState.getAuthToken();
      if (token == null) throw Exception('Not authenticated');
      final baseUrl = '${AppConfig.baseUrl}/classes/';
      final uri = Uri.parse(
          '$baseUrl?baby_profile_id=${widget.babyProfileId}&camera_type=${Uri.encodeComponent(_selectedCameraType)}');
      final resp =
          await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      if (resp.statusCode != 200) {
        throw Exception('Failed to fetch dangerous objects');
      }
      final list = json.decode(resp.body) as List;
      setState(() {
        _dangerousObjects = list
            .map((e) => {
                  'id': e['id'],
                  'name': e['name'],
                  'risk_level': e['risk_level'],
                  'camera_type': _selectedCameraType,
                })
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onCameraTypeChanged(String? newValue) {
    if (!widget.allowCameraTypeChange) return;
    if (newValue != null && newValue != _selectedCameraType) {
      setState(() {
        _selectedCameraType = newValue;
        _selectedForDelete.clear();
      });
      _fetchDangerousObjects();
    }
  }

  void _onDeleteSelected() {
    final deleted = _dangerousObjects
        .where((obj) => _selectedForDelete.contains(obj['id'] as int))
        .toList();
    Navigator.of(context).pop(deleted);
  }

  void _toggleDeleteMode() {
    setState(() {
      _deleteMode = !_deleteMode;
      if (!_deleteMode) _selectedForDelete.clear();
    });
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  Future<void> _handleUpdate(Map<String, dynamic> obj) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassEditScreen(
          className: obj['name'],
          initialImages: const [], // Start with empty images for update
          babyProfileId: widget.babyProfileId,
          modelType: _selectedCameraType == 'head_camera'
              ? 'head_camera_model'
              : 'static_camera_model',
          initialRiskLevel: obj['risk_level'] ?? 'medium',
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      // Add the original object's data to the result
      result['original_id'] = obj['id'];
      result['original_name'] = obj['name'];
      result['original_risk_level'] = obj['risk_level'];
      result['camera_type'] = _selectedCameraType;
      Navigator.of(context)
          .pop([result]); // Return as a list to match deletion pattern
    }
  }

  void _addPendingRiskLevelUpdate(Map<String, dynamic> obj, String newRisk) {
    final existing =
        _pendingRiskLevelUpdates.indexWhere((e) => e['id'] == obj['id']);
    if (existing != -1) {
      _pendingRiskLevelUpdates[existing]['new_risk'] = newRisk;
    } else {
      _pendingRiskLevelUpdates.add({
        'id': obj['id'],
        'name': obj['name'],
        'old_risk': obj['risk_level'],
        'new_risk': newRisk,
        'camera_type': obj['camera_type'],
      });
    }
    setState(() {
      final idx = _dangerousObjects.indexWhere((o) => o['id'] == obj['id']);
      if (idx != -1) _dangerousObjects[idx]['risk_level'] = newRisk;
    });
  }

  void _showRiskLevelDialog(Map<String, dynamic> obj) async {
    String selected = obj['risk_level'];
    final newRisk = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Risk Level'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (newRisk != null && newRisk != obj['risk_level']) {
      _addPendingRiskLevelUpdate(obj, newRisk);
    }
  }

  void _returnAllChanges() {
    Navigator.of(context).pop(
        _pendingRiskLevelUpdates.isNotEmpty ? _pendingRiskLevelUpdates : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.allowCameraTypeChange
            ? 'Dangerous Objects'
            : "Dangerous Objects (${widget.cameraType == 'head_camera' ? 'Head Camera' : 'Static Camera'})"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _returnAllChanges,
        ),
        actions: [
          if (_deleteMode) ...[
            IconButton(
              icon: const Icon(Icons.cancel),
              tooltip: 'Cancel',
              onPressed: _toggleDeleteMode,
            ),
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Confirm Delete',
              onPressed: _selectedForDelete.isEmpty ? null : _onDeleteSelected,
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          if (widget.allowCameraTypeChange)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Camera Type:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedCameraType,
                    items: const [
                      DropdownMenuItem(
                        value: 'head_camera',
                        child: Text('Head Camera'),
                      ),
                      DropdownMenuItem(
                        value: 'static_camera',
                        child: Text('Static Camera'),
                      ),
                    ],
                    onChanged: _onCameraTypeChanged,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _dangerousObjects.isEmpty
                        ? const Center(
                            child: Text('No dangerous objects found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _dangerousObjects.length,
                            itemBuilder: (context, index) {
                              final obj = _dangerousObjects[index];
                              final riskColor = _riskColor(obj['risk_level']);
                              Widget content = Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: riskColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          obj['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'Risk: ${obj['risk_level']}',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 16,
                                                  color: Colors.orange),
                                              tooltip: 'Edit Risk Level',
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () =>
                                                  _showRiskLevelDialog(obj),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_deleteMode) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      tooltip: 'Update',
                                      onPressed: () => _handleUpdate(obj),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        setState(() {
                                          _selectedForDelete
                                              .add(obj['id'] as int);
                                        });
                                        _onDeleteSelected();
                                      },
                                    ),
                                  ],
                                ],
                              );
                              if (_deleteMode) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: CheckboxListTile(
                                    value: _selectedForDelete
                                        .contains(obj['id'] as int),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedForDelete
                                              .add(obj['id'] as int);
                                        } else {
                                          _selectedForDelete
                                              .remove(obj['id'] as int);
                                        }
                                      });
                                    },
                                    title: content,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                );
                              } else {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: content,
                                  ),
                                );
                              }
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
