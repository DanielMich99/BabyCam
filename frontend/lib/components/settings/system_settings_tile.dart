import 'package:flutter/material.dart';

class SystemSettingsTile extends StatelessWidget {
  const SystemSettingsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.settings),
      title: const Text('system settings',
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        // Add system settings widgets here
      ],
    );
  }
}
