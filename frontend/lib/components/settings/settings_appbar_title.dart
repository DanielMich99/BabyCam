import 'package:flutter/material.dart';

class SettingsAppBarTitle extends StatelessWidget {
  const SettingsAppBarTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/babycam_logo.png',
          height: 48,
        ),
        const SizedBox(height: 4),
        const Text('BABY CAM',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
