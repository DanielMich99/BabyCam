import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/baby_profile_service.dart';

class AddBabyDialog extends StatefulWidget {
  const AddBabyDialog({Key? key}) : super(key: key);

  @override
  State<AddBabyDialog> createState() => _AddBabyDialogState();
}

class _AddBabyDialogState extends State<AddBabyDialog> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderOptions = ['Male', 'Female', 'Other'];
  String selectedGender = 'Male';
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final medicalConditionController = TextEditingController();
  XFile? pickedImage;
  String? imageError;
  String? nameError;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    medicalConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Baby'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final img = await picker.pickImage(source: ImageSource.gallery);
                if (img != null) {
                  setState(() {
                    pickedImage = img;
                    imageError = null;
                  });
                }
              },
              child: CircleAvatar(
                radius: 40,
                backgroundImage: pickedImage != null
                    ? FileImage(File(pickedImage!.path))
                    : null,
                child: pickedImage == null
                    ? const Icon(Icons.camera_alt, size: 32, color: Colors.grey)
                    : null,
              ),
            ),
            if (imageError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(imageError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Baby Name',
                hintText: 'Enter baby name',
                errorText: nameError,
              ),
              onChanged: (_) {
                if (nameError != null &&
                    nameController.text.trim().isNotEmpty) {
                  setState(() => nameError = null);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Age (months)',
                hintText: 'Enter age (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedGender,
              items: genderOptions
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value ?? genderOptions[0];
                });
              },
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Enter weight (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                hintText: 'Enter height (optional)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: medicalConditionController,
              decoration: const InputDecoration(
                labelText: 'Medical Condition',
                hintText: 'Enter medical condition (optional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  if (nameController.text.trim().isEmpty) {
                    setState(() => nameError = 'Name is required');
                    return;
                  }
                  setState(() => isLoading = true);
                  try {
                    String? base64Image;
                    if (pickedImage != null) {
                      final bytes = await pickedImage!.readAsBytes();
                      base64Image = base64Encode(bytes);
                    }
                    final data = {
                      'name': nameController.text.trim(),
                      if (ageController.text.trim().isNotEmpty)
                        'age': int.tryParse(ageController.text.trim()),
                      'gender': selectedGender,
                      if (weightController.text.trim().isNotEmpty)
                        'weight': double.tryParse(weightController.text.trim()),
                      if (heightController.text.trim().isNotEmpty)
                        'height': int.tryParse(heightController.text.trim()),
                      if (medicalConditionController.text.trim().isNotEmpty)
                        'medical_condition':
                            medicalConditionController.text.trim(),
                      if (base64Image != null) 'profile_picture': base64Image,
                    };
                    await BabyProfileService.createBabyProfile(data);
                    if (mounted) {
                      Navigator.pop(context, true);
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add baby: $e')),
                    );
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
