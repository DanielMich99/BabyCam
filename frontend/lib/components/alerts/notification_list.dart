import 'package:flutter/material.dart';
import '../../models/notification_item.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;
  final Function(int) onDelete;

  const NotificationList({
    Key? key,
    required this.notifications,
    required this.onDelete,
  }) : super(key: key);

  // Helper method to get color based on risk level
  Color _getRiskLevelColor(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.red; // Default to red for unknown risk levels
    }
  }

  // Helper method to get color based on confidence percentage
  Color _getConfidenceColor(double confidence) {
    final percentage = confidence * 100;
    if (percentage >= 50 && percentage < 65) {
      return Colors.red;
    } else if (percentage >= 65 && percentage < 80) {
      return Colors.orange;
    } else if (percentage >= 80 && percentage <= 100) {
      return Colors.green;
    } else {
      return Colors.grey; // Default for values outside the specified ranges
    }
  }

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final riskColor = _getRiskLevelColor(notification.riskLevel);
        final confidenceColor = _getConfidenceColor(notification.confidence);

        return Dismissible(
          key: Key(notification.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            onDelete(notification.id);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: riskColor.withOpacity(0.1),
                child: Icon(
                  Icons.warning,
                  color: riskColor,
                ),
              ),
              title: Text(
                notification.className,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '${notification.cameraType} - ',
                  ),
                  Text(
                    '${(notification.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: confidenceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(' confidence'),
                ],
              ),
              trailing: Text(
                _formatTimestamp(notification.timestamp),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
