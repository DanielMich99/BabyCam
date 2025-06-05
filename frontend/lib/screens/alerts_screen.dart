import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/detection_service.dart';

class AlertsScreen extends StatefulWidget {
  final DetectionService detectionService;

  const AlertsScreen({
    Key? key,
    required this.detectionService,
  }) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final notifications =
          await widget.detectionService.getMyDetectionResults();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await widget.detectionService.deleteDetectionResult(id);
      setState(() {
        _notifications.removeWhere((notification) => notification.id == id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification: $e')),
        );
      }
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchNotifications,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                'No detection alerts yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: ValueKey(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) =>
                      _deleteNotification(notification.id),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  notification.className,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${(notification.confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: notification.confidence > 0.8
                                      ? Colors.red
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notification.cameraType,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}:${notification.timestamp.second.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  notification.isViewed
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                  color: notification.isViewed
                                      ? Colors.blue
                                      : Colors.grey,
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
                                  color: notification.isHandled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                tooltip: notification.isHandled
                                    ? 'Unmark as handled'
                                    : 'Mark as handled',
                                onPressed: () => _toggleHandled(index),
                              ),
                            ],
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
