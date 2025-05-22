import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/home/baby_profiles_list.dart';
import '../screens/baby_settings_screen.dart';

class BabiesScreen extends StatefulWidget {
  final List<BabyProfile> babies;

  const BabiesScreen({Key? key, required this.babies}) : super(key: key);

  @override
  State<BabiesScreen> createState() => _BabiesScreenState();
}

class _BabiesScreenState extends State<BabiesScreen> {
  late List<BabyProfile> _babies;

  @override
  void initState() {
    super.initState();
    _babies = List.from(widget.babies);
  }

  void _handleBabySelected(int index) {
    setState(() {
      for (var i = 0; i < _babies.length; i++) {
        _babies[i] = _babies[i].copyWith(isSelected: i == index);
      }
    });
  }

  void _addNewBaby() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Baby'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Baby Name',
                hintText: 'Enter baby name',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _babies.add(
                      BabyProfile(
                        name: value,
                        imageUrl: 'assets/images/default_baby.jpg',
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle adding new baby
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Babies'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BabyProfilesList(
                babies: _babies,
                onBabySelected: _handleBabySelected,
                onOptionSelected: (index, option) {
                  if (option == 'view') {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(_babies[index].name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage(_babies[index].imageUrl),
                            ),
                            const SizedBox(height: 16),
                            Text('Name: ${_babies[index].name}'),
                            const SizedBox(height: 8),
                            Text(
                                'Camera 1: ${_babies[index].camera1On ? "On" : "Off"}'),
                            Text(
                                'Camera 2: ${_babies[index].camera2On ? "On" : "Off"}'),
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
                            BabySettingsScreen(baby: _babies[index]),
                      ),
                    );
                  } else if (option == 'remove') {
                    setState(() {
                      _babies.removeAt(index);
                    });
                  }
                },
                onCameraToggle: (index, cameraNumber) {
                  setState(() {
                    if (cameraNumber == 1) {
                      _babies[index] = _babies[index]
                          .copyWith(camera1On: !_babies[index].camera1On);
                    } else if (cameraNumber == 2) {
                      _babies[index] = _babies[index]
                          .copyWith(camera2On: !_babies[index].camera2On);
                    }
                  });
                },
              ),
            ),
          ],
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
