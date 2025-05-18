import 'package:flutter/material.dart';

class AccountSettingsTile extends StatelessWidget {
  const AccountSettingsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.person),
      title: const Text('account settings',
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        // Add account settings widgets here
      ],
    );
  }
}
