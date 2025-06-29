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
  Set<int> _selectedBabyIds = {}; // Track selected baby IDs for filtering
  bool _isFilterExpanded = false; // Track if filter section is expanded
  Set<int> _selectedAlertIds = {}; // Track selected alert IDs for bulk deletion
  bool _isSelectionMode = false; // Track if we're in multi-select mode

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

  void _toggleBabyFilter(int babyId) {
    setState(() {
      if (_selectedBabyIds.contains(babyId)) {
        _selectedBabyIds.remove(babyId);
      } else {
        _selectedBabyIds.add(babyId);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBabyIds.clear();
    });
  }

  List<NotificationItem> _getFilteredNotifications() {
    List<NotificationItem> filtered = List.from(_notifications);

    // Apply baby filter if any babies are selected
    if (_selectedBabyIds.isNotEmpty) {
      filtered = filtered
          .where((notification) =>
              _selectedBabyIds.contains(notification.babyProfileId))
          .toList();
    }

    // Sort by time (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedAlertIds.clear();
      }
    });
  }

  void _toggleAlertSelection(int alertId) {
    setState(() {
      if (_selectedAlertIds.contains(alertId)) {
        _selectedAlertIds.remove(alertId);
      } else {
        _selectedAlertIds.add(alertId);
      }
    });
  }

  void _selectAllVisible() {
    final filteredNotifications = _getFilteredNotifications();
    setState(() {
      _selectedAlertIds = filteredNotifications.map((n) => n.id).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedAlertIds.clear();
    });
  }

  void _selectAlertsByBaby(int babyId) {
    final babyAlerts = _getFilteredNotifications()
        .where((notification) => notification.babyProfileId == babyId)
        .map((n) => n.id)
        .toSet();

    setState(() {
      _selectedAlertIds.addAll(babyAlerts);
    });
  }

  void _showSelectByBabyMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height,
      ),
      items: widget.babyProfileNames.entries.map((entry) {
        final babyId = entry.key;
        final babyName = entry.value;
        final babyAlertCount = _getFilteredNotifications()
            .where((notification) => notification.babyProfileId == babyId)
            .length;

        return PopupMenuItem(
          value: babyId,
          enabled: babyAlertCount > 0,
          child: Row(
            children: [
              Text(babyName),
              const Spacer(),
              Text(
                '($babyAlertCount)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedBabyId) {
      if (selectedBabyId != null) {
        _selectAlertsByBaby(selectedBabyId);
      }
    });
  }

  Future<void> _deleteSelectedAlerts() async {
    if (_selectedAlertIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alerts'),
        content: Text(
            'Are you sure you want to delete ${_selectedAlertIds.length} alert${_selectedAlertIds.length == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Store the count before clearing
        final deletedCount = _selectedAlertIds.length;

        // Group selected alerts by baby profile ID
        final Map<int, List<int>> alertsByBaby = {};

        for (final alertId in _selectedAlertIds) {
          final notification =
              _notifications.firstWhere((n) => n.id == alertId);
          final babyId = notification.babyProfileId;

          if (!alertsByBaby.containsKey(babyId)) {
            alertsByBaby[babyId] = [];
          }
          alertsByBaby[babyId]!.add(alertId);
        }

        await widget.detectionService.bulkDeleteAlertsByBaby(alertsByBaby);

        setState(() {
          _notifications.removeWhere(
              (notification) => _selectedAlertIds.contains(notification.id));
          _selectedAlertIds.clear();
          _isSelectionMode = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Deleted $deletedCount alert${deletedCount == 1 ? '' : 's'}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete alerts: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAllAlerts() async {
    final filteredNotifications = _getFilteredNotifications();
    if (filteredNotifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Alerts'),
        content: Text(
            'Are you sure you want to delete all ${filteredNotifications.length} alert${filteredNotifications.length == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Group all alerts by baby profile ID
        final Map<int, List<int>> alertsByBaby = {};

        for (final notification in filteredNotifications) {
          final babyId = notification.babyProfileId;

          if (!alertsByBaby.containsKey(babyId)) {
            alertsByBaby[babyId] = [];
          }
          alertsByBaby[babyId]!.add(notification.id);
        }

        await widget.detectionService.bulkDeleteAlertsByBaby(alertsByBaby);

        setState(() {
          _notifications.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Deleted all ${filteredNotifications.length} alert${filteredNotifications.length == 1 ? '' : 's'}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete all alerts: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAlertsByBaby(int babyId) async {
    final babyName = widget.babyProfileNames[babyId] ?? 'Unknown';
    final babyAlerts =
        _notifications.where((n) => n.babyProfileId == babyId).toList();

    if (babyAlerts.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Baby Alerts'),
        content: Text(
            'Are you sure you want to delete all ${babyAlerts.length} alert${babyAlerts.length == 1 ? '' : 's'} for $babyName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Create alerts by baby map with only this baby's alerts
        final Map<int, List<int>> alertsByBaby = {
          babyId: babyAlerts.map((n) => n.id).toList(),
        };

        await widget.detectionService.bulkDeleteAlertsByBaby(alertsByBaby);

        setState(() {
          _notifications.removeWhere(
              (notification) => notification.babyProfileId == babyId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted all alerts for $babyName')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to delete alerts for $babyName: $e')),
          );
        }
      }
    }
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

    final filteredNotifications = _getFilteredNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Alerts'),
        actions: [
          if (_isSelectionMode) ...[
            if (_selectedAlertIds.isNotEmpty)
              TextButton(
                onPressed: _deleteSelectedAlerts,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            TextButton(
              onPressed: _toggleSelectionMode,
              child: const Text('Cancel'),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select alerts to delete',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchNotifications,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Baby filter section
          if (widget.babyProfileNames.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    const Text(
                      'Filter by Baby',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_selectedBabyIds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_selectedBabyIds.length} selected',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: _selectedBabyIds.isNotEmpty
                    ? TextButton(
                        onPressed: _clearAllFilters,
                        child: const Text('Clear All'),
                      )
                    : null,
                initiallyExpanded: _isFilterExpanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isFilterExpanded = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              widget.babyProfileNames.entries.map((entry) {
                            final babyId = entry.key;
                            final babyName = entry.value;
                            final isSelected =
                                _selectedBabyIds.contains(babyId);

                            return FilterChip(
                              label: Text(babyName),
                              selected: isSelected,
                              onSelected: (_) => _toggleBabyFilter(babyId),
                              selectedColor: Colors.blue.shade100,
                              checkmarkColor: Colors.blue.shade700,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade300,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Sort options section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: 'time',
                  items: const [
                    DropdownMenuItem(
                        value: 'time', child: Text('Time (Newest)')),
                  ],
                  onChanged: (value) {
                    // No-op since we only have one option
                  },
                ),
              ],
            ),
          ),
          // Selection mode controls
          if (_isSelectionMode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedAlertIds.length} selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectedAlertIds.length ==
                            _getFilteredNotifications().length
                        ? _deselectAll
                        : _selectAllVisible,
                    child: Text(
                      _selectedAlertIds.length ==
                              _getFilteredNotifications().length
                          ? 'Deselect All'
                          : 'Select All',
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showSelectByBabyMenu(context),
                    child: const Text('Select by Baby'),
                  ),
                ],
              ),
            ),
          ],
          // Notifications list
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedBabyIds.isNotEmpty
                              ? 'No alerts for selected babies'
                              : 'No detection alerts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedBabyIds.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _clearAllFilters,
                            child: const Text('Clear filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      final babyName =
                          widget.babyProfileNames[notification.babyProfileId] ??
                              'Unknown';
                      final isSelected =
                          _selectedAlertIds.contains(notification.id);

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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: InkWell(
                            onTap: _isSelectionMode
                                ? () => _toggleAlertSelection(notification.id)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  if (_isSelectionMode) ...[
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleAlertSelection(
                                          notification.id),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              color: _getRiskLevelColor(
                                                  notification.riskLevel),
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
                                                color: _getRiskLevelColor(
                                                    notification.riskLevel),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.videocam,
                                                size: 16,
                                                color: Colors.grey.shade600),
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
                                            if (!_isSelectionMode)
                                              IconButton(
                                                icon: const Icon(Icons.image),
                                                onPressed: () =>
                                                    _showImage(notification.id),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
