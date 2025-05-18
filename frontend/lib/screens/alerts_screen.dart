import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../components/notification_list.dart';

class AlertsScreen extends StatelessWidget {
  final List<NotificationItem> notifications;
  const AlertsScreen({Key? key, required this.notifications}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: NotificationList(notifications: notifications),
    );
  }
}
