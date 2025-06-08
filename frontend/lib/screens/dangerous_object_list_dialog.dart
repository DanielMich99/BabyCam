import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_state.dart';

class DangerousObjectListDialog extends StatefulWidget {
  final int babyProfileId;
  final String cameraType;
  const DangerousObjectListDialog(
      {Key? key, required this.babyProfileId, required this.cameraType})
      : super(key: key);

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

  @override
  void initState() {
    super.initState();
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
      final baseUrl = 'http://10.0.2.2:8000/classes/';
      final uri = Uri.parse(
          '$baseUrl?baby_profile_id=${widget.babyProfileId}&camera_type=${Uri.encodeComponent(widget.cameraType)}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dangerous Objects (' +
            (widget.cameraType == 'head_camera'
                ? 'Head Camera'
                : 'Static Camera') +
            ')'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_deleteMode)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              onPressed: _dangerousObjects.isEmpty ? null : _toggleDeleteMode,
            ),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _dangerousObjects.isEmpty
                  ? const Center(child: Text('No dangerous objects found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _dangerousObjects.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final obj = _dangerousObjects[index];
                        if (_deleteMode) {
                          return CheckboxListTile(
                            value:
                                _selectedForDelete.contains(obj['id'] as int),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedForDelete.add(obj['id'] as int);
                                } else {
                                  _selectedForDelete.remove(obj['id'] as int);
                                }
                              });
                            },
                            title: Text(obj['name']),
                            subtitle: Text('Risk: ${obj['risk_level']}'),
                          );
                        } else {
                          return ListTile(
                            title: Text(obj['name']),
                            subtitle: Text('Risk: ${obj['risk_level']}'),
                          );
                        }
                      },
                    ),
    );
  }
}
