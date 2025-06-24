import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/detection_service.dart';

class AlertsScreen extends StatefulWidget {
  final DetectionService detectionService;
  final Map<int, String> babyProfileNames;

  const AlertsScreen({
    Key? key,
    required this.detectionService,
    required this.babyProfileNames,
  }) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String _sortBy = 'time'; // 'time' or 'name'

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

      final notifications = await widget.detectionService.getMyDetectionResults();
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

  Future<void> _showImage(int id) async {
    try {
      final bytes = await widget.detectionService.getDetectionImage(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Image.memory(bytes),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: $e')),
      );
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

    List<NotificationItem> sortedNotifications = List.from(_notifications);
    if (_sortBy == 'name') {
      sortedNotifications.sort((a, b) {
        final nameA = widget.babyProfileNames[a.babyProfileId] ?? '';
        final nameB = widget.babyProfileNames[b.babyProfileId] ?? '';
        return nameA.compareTo(nameB);
      });
    } else {
      sortedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'time', child: Text('Time (Newest)')),
                    DropdownMenuItem(value: 'name', child: Text('Baby Name')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: sortedNotifications.isEmpty
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
                    itemCount: sortedNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = sortedNotifications[index];
                      final babyName = widget.babyProfileNames[notification.babyProfileId] ?? 'Unknown';
                      return Dismissible(
                        key: ValueKey(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) => _deleteNotification(notification.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  babyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blueGrey,
                                  ),
                                ),
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
                                        color: notification.confidence > 0.8 ? Colors.red : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.videocam, size: 16, color: Colors.grey.shade600),
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
                                    IconButton(
                                      icon: const Icon(Icons.image),
                                      onPressed: () => _showImage(notification.id),
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
          ),
        ],
      ),
    );
  }
}
