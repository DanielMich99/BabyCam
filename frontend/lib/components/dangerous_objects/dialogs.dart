import 'package:flutter/material.dart';

class CameraTypeSelectionDialog extends StatelessWidget {
  const CameraTypeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Camera Type'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'Head Camera'),
          child: const Text('Head Camera'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, 'Static Camera'),
          child: const Text('Static Camera'),
        ),
      ],
    );
  }
}

class ObjectNameInputDialog extends StatelessWidget {
  const ObjectNameInputDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text('Enter Object Name'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'e.g. scissors'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class RiskLevelSelectionDialog extends StatelessWidget {
  const RiskLevelSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selected = 'medium';
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Select Risk Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'low',
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v!),
              title: const Text('Low'),
            ),
            RadioListTile<String>(
              value: 'medium',
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v!),
              title: const Text('Medium'),
            ),
            RadioListTile<String>(
              value: 'high',
              groupValue: selected,
              onChanged: (v) => setState(() => selected = v!),
              title: const Text('High'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, selected),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
