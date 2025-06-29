import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/home/baby_profiles_list.dart';
import '../screens/baby_settings_screen.dart';
import '../screens/manage_dangerous_objects_screen.dart';
import '../services/auth_state.dart';
import 'package:http/http.dart' as http;
import '../services/baby_profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/home/add_baby_dialog.dart';
import '../config/app_config.dart';
import '../services/model_training_status_service.dart';

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
    ModelTrainingStatusService().addListener(_onTrainingStatusChanged);
  }

  @override
  void dispose() {
    ModelTrainingStatusService().removeListener(_onTrainingStatusChanged);
    super.dispose();
  }

  void _onTrainingStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<BabyProfile>> fetchBabies() async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
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

  void _addNewBaby() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const AddBabyDialog(),
    );
    if (result == true) {
      setState(() {
        _babiesFuture = fetchBabies();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baby added successfully!')),
      );
    }
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No babies found.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Baby'),
                      onPressed: _addNewBaby,
                    ),
                  ],
                ),
              );
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
                      } else if (option == 'head_camera_model') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageDangerousObjectsScreen(
                              babyProfileId: babies[index].id,
                              cameraType: 'Head Camera',
                            ),
                          ),
                        );
                      } else if (option == 'static_camera_model') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageDangerousObjectsScreen(
                              babyProfileId: babies[index].id,
                              cameraType: 'Static Camera',
                            ),
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
