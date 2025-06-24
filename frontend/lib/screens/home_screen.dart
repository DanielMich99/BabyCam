import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';
import '../services/websocket_service.dart';
import '../models/notification_item.dart';
import '../models/baby_profile.dart';
import '../components/home/home_header.dart';
import '../components/home/custom_bottom_nav.dart';
import '../components/alerts/notification_list.dart';
import 'login_screen.dart';
import '../components/home/add_baby_dialog.dart';
import '../config/app_config.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCameraOn = false;
  late Future<List<BabyProfile>> _babiesFuture;
  final List<NotificationItem> _notifications = [];
  final _websocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _babiesFuture = fetchBabies();
    _websocketService.addDetectionListener(_handleDetection);
  }

  @override
  void dispose() {
    _websocketService.removeDetectionListener(_handleDetection);
    super.dispose();
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
          ));
    });

    // Show a snackbar for new detections
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New detection: ${detection['class_name']}'),
        backgroundColor: Colors.red,
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

  Future<void> _checkAuthentication() async {
    final isAuthenticated = await AuthState.isAuthenticated();
    if (!mounted) return;
    if (!isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<List<BabyProfile>> fetchBabies() async {
    final token = await AuthState.getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BabyProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load babies');
    }
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
            onPressed: () async {
              _websocketService.disconnect();
              await AuthState.clearAuth();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
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
