import 'package:flutter/material.dart';
import '../../screens/settings_screen.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final bool isCameraOn;
  final Function(bool) onCameraToggle;

  const HomeHeader({
    Key? key,
    required this.username,
    required this.isCameraOn,
    required this.onCameraToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Welcome, ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                username,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.power_settings_new,
                  color: isCameraOn ? Colors.green : Colors.grey,
                ),
                onPressed: () => onCameraToggle(!isCameraOn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
