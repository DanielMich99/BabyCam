import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/settings/general_baby_details_section.dart';
import '../screens/manage_dangerous_objects_screen.dart';

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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageDangerousObjectsScreen(
                        babyProfileId: widget.baby.id,
                        cameraType: 'Head Camera',
                      ),
                    ),
                  );
                },
                child: Text('Manage Dangerous Objects for ${widget.baby.name}'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
