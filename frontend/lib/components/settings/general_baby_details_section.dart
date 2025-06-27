import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/baby_profile.dart';
import '../../services/baby_profile_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GeneralBabyDetailsSection extends StatefulWidget {
  final BabyProfile baby;
  const GeneralBabyDetailsSection({Key? key, required this.baby})
      : super(key: key);

  @override
  State<GeneralBabyDetailsSection> createState() =>
      _GeneralBabyDetailsSectionState();
}

class _GeneralBabyDetailsSectionState extends State<GeneralBabyDetailsSection> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _customMedicalConditionController;
  String? _imageUrl;
  String _selectedGender = 'Male';
  String _selectedMedicalCondition = 'None';
  bool _settingsExpanded = false;
  bool _isSaving = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby.name);
    _ageController = TextEditingController(
        text: widget.baby.age != null ? '${widget.baby.age}' : '');
    _weightController = TextEditingController(
        text: widget.baby.weight != null ? '${widget.baby.weight}' : '');
    _heightController = TextEditingController(
        text: widget.baby.height != null ? '${widget.baby.height}' : '');
    _selectedGender = widget.baby.gender ?? 'Male';
    if (widget.baby.medicalCondition != null) {
      if (['None', 'Allergy', 'Asthma']
          .contains(widget.baby.medicalCondition)) {
        _selectedMedicalCondition = widget.baby.medicalCondition!;
        _customMedicalConditionController = TextEditingController();
      } else {
        _selectedMedicalCondition = 'Other';
        _customMedicalConditionController =
            TextEditingController(text: widget.baby.medicalCondition);
      }
    } else {
      _customMedicalConditionController = TextEditingController();
    }
    _imageUrl = widget.baby.profilePicture;
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

  void _changePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
        _imageUrl = null; // Clear asset image if new image picked
      });
    }
  }

  void _saveDetails() async {
    setState(() {
      _isSaving = true;
    });
    try {
      String? base64Image;
      if (_pickedImageFile != null) {
        final bytes = await _pickedImageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }
      final updateData = {
        'name': _nameController.text,
        'age':
            int.tryParse(_ageController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'gender': _selectedGender,
        'weight': double.tryParse(_weightController.text)?.toInt(),
        'height': int.tryParse(_heightController.text),
        'medical_condition': _selectedMedicalCondition == 'Other'
            ? _customMedicalConditionController.text
            : _selectedMedicalCondition,
        if (base64Image != null) 'profile_picture': base64Image,
        if (_imageUrl != null && base64Image == null)
          'profile_picture': _imageUrl,
      };
      // Remove nulls
      updateData.removeWhere((key, value) => value == null);
      await BabyProfileService.updateBabyProfile(
        id: widget.baby.id,
        updateData: updateData,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _discardDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Changes discarded (UI only, no backend logic)')),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_pickedImageFile != null) {
      return FileImage(_pickedImageFile!);
    }
    if (_imageUrl != null) {
      // Heuristically check if it's base64 (starts with /9j/ or data:image)
      if (_imageUrl!.startsWith('/9j/') ||
          _imageUrl!.startsWith('iVBOR') ||
          _imageUrl!.startsWith('data:image')) {
        try {
          final base64Str = _imageUrl!.contains(',')
              ? _imageUrl!.split(',').last
              : _imageUrl!;
          return MemoryImage(base64Decode(base64Str));
        } catch (_) {}
      } else {
        // Otherwise, treat as asset path
        return AssetImage(_imageUrl!);
      }
    }
    return const AssetImage('assets/images/default_baby.jpg');
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
                  backgroundColor: Colors.blue[50],
                  backgroundImage: _getProfileImage(),
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
                    onPressed: _isSaving ? null : _saveDetails,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
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
