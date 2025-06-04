import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/baby_profile.dart';
import 'class_edit_screen.dart';

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
              _GeneralBabyDetailsSection(),
              const SizedBox(height: 24),
              // Add Dangerous Object (Head Camera)
              _AddDangerousObjectSection(cameraType: 'Head Camera'),
              const SizedBox(height: 16),
              // Add Dangerous Object (Static Camera)
              _AddDangerousObjectSection(cameraType: 'Static Camera'),
              const SizedBox(height: 32),
              // List all dangerous objects for head camera
              _DangerousObjectListSection(
                cameraType: 'Head Camera',
                dangerousObjects: _headCameraDangerous,
                onDelete: _deleteHeadCameraDangerous,
              ),
              const SizedBox(height: 16),
              // List all dangerous objects for static camera
              _DangerousObjectListSection(
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

// Placeholder for General Baby Details
class _GeneralBabyDetailsSection extends StatefulWidget {
  @override
  State<_GeneralBabyDetailsSection> createState() =>
      _GeneralBabyDetailsSectionState();
}

class _GeneralBabyDetailsSectionState
    extends State<_GeneralBabyDetailsSection> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _customMedicalConditionController;
  String? _imageUrl;
  String _selectedGender = 'Male';
  String _selectedMedicalCondition = 'None';

  bool _settingsExpanded = false;

  @override
  void initState() {
    super.initState();
    final baby = (context.findAncestorStateOfType<_BabySettingsScreenState>()
            as _BabySettingsScreenState)
        .widget
        .baby;
    _nameController = TextEditingController(text: baby.name);
    _ageController = TextEditingController(
        text: '10 months'); // Placeholder, replace with baby.age if available
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _customMedicalConditionController = TextEditingController();
    _imageUrl = baby.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _customMedicalConditionController.dispose();
    super.dispose();
  }

  void _changePicture() {
    // Placeholder for image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change picture not implemented.')),
    );
  }

  void _saveDetails() {
    // TODO: Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved (UI only, no backend logic)')),
    );
  }

  void _discardDetails() {
    // TODO: Implement discard logic (reset fields to initial values)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Changes discarded (UI only, no backend logic)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _settingsExpanded = !_settingsExpanded;
                });
              },
              child: Row(
                children: [
                  const Text(
                    'Edit Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(_settingsExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                ],
              ),
            ),
            if (_settingsExpanded) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _changePicture,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      AssetImage(_imageUrl ?? 'assets/images/default_baby.jpg'),
                  backgroundColor: Colors.blue[50],
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child:
                          Icon(Icons.edit, size: 16, color: Colors.blue[700]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age (e.g. 10 months)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? 'Male';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9]*\.?[0-9]*')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMedicalCondition,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None')),
                  DropdownMenuItem(value: 'Allergy', child: Text('Allergy')),
                  DropdownMenuItem(value: 'Asthma', child: Text('Asthma')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMedicalCondition = value ?? 'None';
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Medical Condition',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_selectedMedicalCondition == 'Other') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _customMedicalConditionController,
                  decoration: const InputDecoration(
                    labelText: 'Enter custom condition',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _discardDetails,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400]),
                    child: const Text('Discard'),
                  ),
                  ElevatedButton(
                    onPressed: _saveDetails,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Rename and duplicate Add Dangerous Object Section
class _AddDangerousObjectSection extends StatelessWidget {
  final String cameraType;
  const _AddDangerousObjectSection({required this.cameraType});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Dangerous Object ($cameraType)',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Add/Edit Object Class'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassEditScreen(
                      className: 'Dangerous Object ($cameraType)',
                      initialImages: const [],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Collapsible list section for dangerous objects
class _DangerousObjectListSection extends StatefulWidget {
  final String cameraType;
  final List<String> dangerousObjects;
  final void Function(String) onDelete;
  const _DangerousObjectListSection(
      {required this.cameraType,
      required this.dangerousObjects,
      required this.onDelete});

  @override
  State<_DangerousObjectListSection> createState() =>
      _DangerousObjectListSectionState();
}

class _DangerousObjectListSectionState
    extends State<_DangerousObjectListSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Row(
                children: [
                  Text('Dangerous Objects (${widget.cameraType})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              if (widget.dangerousObjects.isEmpty)
                const Text('No dangerous objects added.'),
              for (final obj in widget.dangerousObjects)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(child: Text('• $obj')),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.onDelete(obj),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
