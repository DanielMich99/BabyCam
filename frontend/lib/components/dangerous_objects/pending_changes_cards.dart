import 'package:flutter/material.dart';

class PendingAdditionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> pendingAdditions;
  final Function(int) onEdit;
  final Function(int) onRemove;

  const PendingAdditionsCard({
    Key? key,
    required this.pendingAdditions,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingAdditions.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Additions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingAdditions.asMap().entries.map((entry) {
              final obj = entry.value;
              final idx = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.green[300], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${obj['className']} (Risk: ${obj['riskLevel']}, ${obj['modelType'] == 'head_camera_model' ? 'Head Camera' : 'Static Camera'})',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit',
                      onPressed: () => onEdit(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove',
                      onPressed: () => onRemove(idx),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class PendingRiskLevelUpdatesCard extends StatelessWidget {
  final List<Map<String, dynamic>> pendingRiskLevelUpdates;
  final Function(int) onUndo;

  const PendingRiskLevelUpdatesCard({
    Key? key,
    required this.pendingRiskLevelUpdates,
    required this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingRiskLevelUpdates.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.yellow[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Risk Level Updates:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingRiskLevelUpdates.asMap().entries.map((entry) {
              final obj = entry.value;
              final idx = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[300], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${obj['name']} (${obj['camera_type'] == 'head_camera' ? 'Head Camera' : 'Static Camera'})',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const Text('Risk: ', style: TextStyle(fontSize: 15)),
                    Text(
                      '${obj['old_risk']}',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    const Icon(Icons.arrow_right_alt, color: Colors.orange),
                    Text(
                      '${obj['new_risk']}',
                      style:
                          const TextStyle(fontSize: 15, color: Colors.orange),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.blue),
                      tooltip: 'Undo',
                      onPressed: () => onUndo(idx),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class PendingUpdatesCard extends StatelessWidget {
  final List<Map<String, dynamic>> pendingUpdates;
  final Function(int) onEdit;
  final Function(int) onRemove;

  const PendingUpdatesCard({
    Key? key,
    required this.pendingUpdates,
    required this.onEdit,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingUpdates.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Updates:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingUpdates.asMap().entries.map((entry) {
              final obj = entry.value;
              final idx = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.orange[300], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${obj['className']} (Risk: ${obj['riskLevel']}, ${obj['camera_type'] == 'head_camera' ? 'Head Camera' : 'Static Camera'})',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit',
                      onPressed: () => onEdit(idx),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove',
                      onPressed: () => onRemove(idx),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class PendingDeletionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> pendingDeletions;
  final Function(int) onUndo;

  const PendingDeletionsCard({
    Key? key,
    required this.pendingDeletions,
    required this.onUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingDeletions.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Deletions:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingDeletions.asMap().entries.map((entry) {
              final obj = entry.value;
              final idx = entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red[300], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${obj['name']} (Risk: ${obj['risk_level']}, ${obj['camera_label']})',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.blue),
                      tooltip: 'Undo',
                      onPressed: () => onUndo(idx),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
