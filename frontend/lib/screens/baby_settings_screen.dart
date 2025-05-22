import 'package:flutter/material.dart';
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
              // Dangerous Objects List
              _DangerousObjectsSection(),
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
  String? _imageUrl;

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
    _imageUrl = baby.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _changePicture() {
    // Placeholder for image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change picture not implemented.')),
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
          ],
        ),
      ),
    );
  }
}

// Dangerous Objects List Section with add/remove functionality
class _DangerousObjectsSection extends StatefulWidget {
  @override
  State<_DangerousObjectsSection> createState() =>
      _DangerousObjectsSectionState();
}

class _DangerousObjectsSectionState extends State<_DangerousObjectsSection> {
  final List<String> _dangerousObjects = ['Knife', 'Scissors', 'Socket'];
  final TextEditingController _controller = TextEditingController();

  void _addObject() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_dangerousObjects.contains(text)) {
      setState(() {
        _dangerousObjects.add(text);
        _controller.clear();
      });
    }
  }

  void _removeObject(int index) {
    setState(() {
      _dangerousObjects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dangerous Objects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dangerousObjects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_dangerousObjects[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeObject(index),
                  ),
                );
              },
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add new object',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addObject(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addObject,
                  child: const Text('Add'),
                ),
              ],
            ),
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
