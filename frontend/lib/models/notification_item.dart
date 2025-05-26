class NotificationItem {
  final String message;
  final DateTime time;
  final bool isRead;
  final bool isViewed;
  final bool isHandled;

  NotificationItem({
    required this.message,
    required this.time,
    this.isRead = false,
    this.isViewed = false,
    this.isHandled = false,
  });

  NotificationItem copyWith({
    String? message,
    DateTime? time,
    bool? isRead,
    bool? isViewed,
    bool? isHandled,
  }) {
    return NotificationItem(
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      isViewed: isViewed ?? this.isViewed,
      isHandled: isHandled ?? this.isHandled,
    );
  }
}
