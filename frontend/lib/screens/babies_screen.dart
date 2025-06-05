import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/home/baby_profiles_list.dart';
import '../screens/baby_settings_screen.dart';
import '../services/auth_state.dart';
import 'package:http/http.dart' as http;
import '../services/baby_profile_service.dart';

class BabiesScreen extends StatefulWidget {
  const BabiesScreen({Key? key}) : super(key: key);

  @override
  State<BabiesScreen> createState() => _BabiesScreenState();
}

class _BabiesScreenState extends State<BabiesScreen> {
  late Future<List<BabyProfile>> _babiesFuture;

  @override
  void initState() {
    super.initState();
    _babiesFuture = fetchBabies();
  }

  Future<List<BabyProfile>> fetchBabies() async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/baby_profiles/my_profiles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BabyProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load babies');
    }
  }

  void _handleBabySelected(int index, List<BabyProfile> babies,
      void Function(List<BabyProfile>) setBabies) {
    setState(() {
      for (var i = 0; i < babies.length; i++) {
        babies[i] = babies[i].copyWith(isSelected: i == index);
      }
      setBabies(babies);
    });
  }

  void _addNewBaby() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final genderOptions = ['Male', 'Female', 'Other'];
    String selectedGender = genderOptions[0];
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final medicalConditionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add New Baby'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Baby Name',
                      hintText: 'Enter baby name',
                    ),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty) return;
                        setState(() => isLoading = true);
                        try {
                          final data = {
                            'name': nameController.text.trim(),
                            if (ageController.text.trim().isNotEmpty)
                              'age': int.tryParse(ageController.text.trim()),
                            'gender': selectedGender,
                            if (weightController.text.trim().isNotEmpty)
                              'weight':
                                  double.tryParse(weightController.text.trim()),
                            if (heightController.text.trim().isNotEmpty)
                              'height':
                                  int.tryParse(heightController.text.trim()),
                            if (medicalConditionController.text
                                .trim()
                                .isNotEmpty)
                              'medical_condition':
                                  medicalConditionController.text.trim(),
                          };
                          await BabyProfileService.createBabyProfile(data);
                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {
                              _babiesFuture = fetchBabies();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Baby added successfully!')),
                            );
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Babies'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<BabyProfile>>(
          future: _babiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No babies found.'));
            }
            final babies = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: BabyProfilesList(
                    babies: babies,
                    onBabySelected: (index) =>
                        _handleBabySelected(index, babies, (b) {}),
                    onOptionSelected: (index, option) {
                      if (option == 'view') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(babies[index].name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(
                                      babies[index].profilePicture ??
                                          'assets/images/default_baby.jpg'),
                                ),
                                const SizedBox(height: 16),
                                Text('Name: \\${babies[index].name}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      } else if (option == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BabySettingsScreen(baby: babies[index]),
                          ),
                        ).then((result) {
                          if (result == true) {
                            setState(() {
                              _babiesFuture = fetchBabies();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully!')),
                            );
                          }
                        });
                      } else if (option == 'remove') {
                        // Optionally implement remove
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewBaby,
        icon: const Icon(Icons.add),
        label: const Text('Add Baby'),
      ),
    );
  }
}
