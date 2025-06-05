import 'package:flutter/material.dart';
import '../../models/notification_item.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationList({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
            ),
            title: Text(
              notification.className,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}:${notification.timestamp.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: notification.isHandled ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
