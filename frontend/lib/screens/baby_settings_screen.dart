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
              // Add Sharp Object (Model Training)
              _AddSharpObjectSection(),
              const SizedBox(height: 32),
              // Save/Discard Actions
              _SaveDiscardActions(),
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
                    child: Icon(Icons.edit, size: 16, color: Colors.blue[700]),
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
                // Only allow numbers and decimal point
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
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
          ],
        ),
      ),
    );
  }
}

// Placeholder for Add Sharp Object Section
class _AddSharpObjectSection extends StatelessWidget {
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
            const Text('Add Sharp Object (Model Training)',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Add/Edit Object Class'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassEditScreen(
                      className: 'Sharp Object',
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

// Placeholder for Save/Discard Actions
class _SaveDiscardActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]),
          child: const Text('Discard'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ],
    );
  }
}
