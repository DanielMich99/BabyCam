import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../models/notification_item.dart';
import '../services/auth_state.dart';
import '../services/websocket_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../components/home/home_header.dart';
import '../components/alerts/notification_list.dart';
import '../components/home/custom_bottom_nav.dart';
import '../screens/login_screen.dart';
import '../screens/babies_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/camera_screen.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WebSocketService _websocketService = WebSocketService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationItem> _notifications = [];
  int _selectedIndex = 0;
  bool _isCameraOn = false;
  late Future<List<BabyProfile>> _babiesFuture;

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
    _babiesFuture = _authService.getBabyProfiles();
    _initializeWebSocket();
    _loadNotifications();
  }

  Future<void> _initializeWebSocket() async {
    final token = await AuthState.getAuthToken();
    if (token != null) {
      await _websocketService.initialize(
        AppConfig.baseUrl.replaceFirst(RegExp(r'^https?://'), ''),
        token,
      );
      _websocketService.addDetectionListener(_handleDetection);
    }
  }

  Future<void> _loadNotifications() async {
    try {
      // Load notifications from your detection service
      // This is a placeholder - implement based on your needs
      setState(() {
        _notifications = [];
      });
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  void _handleDetection(Map<String, dynamic> detection) {
    if (!mounted) return;

    setState(() {
      _notifications.insert(
          0,
          NotificationItem(
            id: detection['detection_id'] ??
                DateTime.now().millisecondsSinceEpoch,
            babyProfileId: detection['baby_profile_id'],
            classId: detection['class_id'],
            className: '${detection['class_name']} detected',
            confidence: detection['confidence'].toDouble(),
            cameraType: detection['camera_type'],
            timestamp: DateTime.parse(detection['timestamp']),
            riskLevel: detection['risk_level'],
          ));
    });

    // Show a snackbar for new detections
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New detection: ${detection['class_name']}'),
        backgroundColor: _getRiskLevelColor(detection['risk_level']),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Disconnect WebSocket
      _websocketService.disconnect();

      // Perform logout with backend integration
      await AuthState.logout();

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<BabyProfile>> fetchBabies() async {
    return await _authService.getBabyProfiles();
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BabyCam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: FutureBuilder<List<BabyProfile>>(
          future: _babiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final babies = snapshot.data ?? [];
            final Map<int, String> babyProfileNames = {
              for (var baby in babies) baby.id: baby.name,
            };
            return Column(
              children: [
                HomeHeader(
                  username: widget.username,
                  isCameraOn: _isCameraOn,
                  onCameraToggle: (value) =>
                      setState(() => _isCameraOn = value),
                ),
                Expanded(
                  child: NotificationList(
                    notifications: _notifications,
                    onDelete: _deleteNotification,
                  ),
                ),
                CustomBottomNav(
                  selectedIndex: _selectedIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  notifications: _notifications,
                  babyProfileNames: babyProfileNames,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _websocketService.removeDetectionListener(_handleDetection);
    super.dispose();
  }
}

extension BabyProfileExtension on BabyProfile {
  BabyProfile copyWith(
      {String? name, String? profilePicture, bool? isSelected}) {
    return BabyProfile(
      id: id,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
