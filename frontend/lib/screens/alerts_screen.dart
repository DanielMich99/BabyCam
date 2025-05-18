import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../components/alerts/notification_list.dart';

class AlertsScreen extends StatefulWidget {
  final List<NotificationItem> notifications;
  const AlertsScreen({Key? key, required this.notifications}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _toggleViewed(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(
        isViewed: !_notifications[index].isViewed,
      );
    });
  }

  void _toggleHandled(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(
        isHandled: !_notifications[index].isHandled,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: ValueKey(
                notification.time.toIso8601String() + notification.message),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => _deleteNotification(index),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                title: Text(notification.message,
                    style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${notification.time.hour}:${notification.time.minute.toString().padLeft(2, '0')}:${notification.time.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        notification.isViewed
                            ? Icons.visibility
                            : Icons.visibility_outlined,
                        color:
                            notification.isViewed ? Colors.blue : Colors.grey,
                      ),
                      tooltip: notification.isViewed
                          ? 'Unmark as viewed'
                          : 'Mark as viewed',
                      onPressed: () => _toggleViewed(index),
                    ),
                    IconButton(
                      icon: Icon(
                        notification.isHandled
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            notification.isHandled ? Colors.green : Colors.grey,
                      ),
                      tooltip: notification.isHandled
                          ? 'Unmark as handled'
                          : 'Mark as handled',
                      onPressed: () => _toggleHandled(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
