class NotificationItem {
  final String message;
  final DateTime time;
  final bool isRead;

  NotificationItem({
    required this.message,
    required this.time,
    this.isRead = false,
  });
}
