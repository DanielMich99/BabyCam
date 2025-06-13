import 'package:flutter/material.dart';

class DangerousObjectListSection extends StatefulWidget {
  final String cameraType;
  final List<String> dangerousObjects;
  final void Function(String) onDelete;

  const DangerousObjectListSection({
    Key? key,
    required this.cameraType,
    required this.dangerousObjects,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DangerousObjectListSection> createState() =>
      _DangerousObjectListSectionState();
}

class _DangerousObjectListSectionState
    extends State<DangerousObjectListSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Row(
                children: [
                  Text('Dangerous Objects (${widget.cameraType})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              if (widget.dangerousObjects.isEmpty)
                const Text('No dangerous objects added.'),
              for (final obj in widget.dangerousObjects)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(child: Text('• $obj')),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => widget.onDelete(obj),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
