import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/home/baby_profiles_list.dart';
import '../screens/baby_settings_screen.dart';
import '../services/auth_state.dart';
import 'package:http/http.dart' as http;

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
                        );
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
      floatingActionButton: null, // Remove add button for backend-only
    );
  }
}
