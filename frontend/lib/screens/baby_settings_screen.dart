import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/settings/general_baby_details_section.dart';
import '../components/settings/add_dangerous_object_section.dart';
import '../components/settings/dangerous_object_list_section.dart';

class BabySettingsScreen extends StatefulWidget {
  final BabyProfile baby;
  const BabySettingsScreen({Key? key, required this.baby}) : super(key: key);

  @override
  State<BabySettingsScreen> createState() => _BabySettingsScreenState();
}

class _BabySettingsScreenState extends State<BabySettingsScreen> {
  // Placeholder lists for dangerous objects
  final List<String> _headCameraDangerous = ['Knife', 'Scissors'];
  final List<String> _staticCameraDangerous = ['Box Cutter'];

  void _deleteHeadCameraDangerous(String obj) {
    setState(() {
      _headCameraDangerous.remove(obj);
    });
  }

  void _deleteStaticCameraDangerous(String obj) {
    setState(() {
      _staticCameraDangerous.remove(obj);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General Baby Details
              GeneralBabyDetailsSection(baby: widget.baby),
              const SizedBox(height: 24),
              // Add Dangerous Object (Head Camera)
              AddDangerousObjectSection(cameraType: 'Head Camera'),
              const SizedBox(height: 16),
              // Add Dangerous Object (Static Camera)
              AddDangerousObjectSection(cameraType: 'Static Camera'),
              const SizedBox(height: 32),
              // List all dangerous objects for head camera
              DangerousObjectListSection(
                cameraType: 'Head Camera',
                dangerousObjects: _headCameraDangerous,
                onDelete: _deleteHeadCameraDangerous,
              ),
              const SizedBox(height: 16),
              // List all dangerous objects for static camera
              DangerousObjectListSection(
                cameraType: 'Static Camera',
                dangerousObjects: _staticCameraDangerous,
                onDelete: _deleteStaticCameraDangerous,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
