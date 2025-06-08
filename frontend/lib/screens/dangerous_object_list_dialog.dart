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
  List<String> _dangerousObjects = [];
  bool _loading = true;
  String? _error;

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
        _dangerousObjects = list.map((e) => e['name'] as String).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: \\$_error'))
              : _dangerousObjects.isEmpty
                  ? const Center(child: Text('No dangerous objects found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _dangerousObjects.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_dangerousObjects[index]),
                        );
                      },
                    ),
    );
  }
}
