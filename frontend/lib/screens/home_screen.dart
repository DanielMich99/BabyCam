import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_state.dart';
import '../models/notification_item.dart';
import '../models/baby_profile.dart';
import '../components/home/home_header.dart';
import '../components/home/custom_bottom_nav.dart';
import '../components/alerts/notification_list.dart';
import 'login_screen.dart';
import '../components/home/add_baby_dialog.dart';

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
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 1,
      babyProfileId: 1,
      classId: 1,
      className: 'Tom stared at the Electrical Socket',
      confidence: 0.95,
      cameraType: 'Front Camera',
      timestamp: DateTime.now(),
    ),
    NotificationItem(
      id: 2,
      babyProfileId: 1,
      classId: 2,
      className: 'Tom reached to the Electrical Socket',
      confidence: 0.85,
      cameraType: 'Front Camera',
      timestamp: DateTime.now(),
    ),
    NotificationItem(
      id: 3,
      babyProfileId: 1,
      classId: 3,
      className: 'Tom touched the Electrical Socket',
      confidence: 0.75,
      cameraType: 'Front Camera',
      timestamp: DateTime.now(),
    ),
    NotificationItem(
      id: 4,
      babyProfileId: 1,
      classId: 4,
      className: 'Tom reached to the front door',
      confidence: 0.90,
      cameraType: 'Front Camera',
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _babiesFuture = fetchBabies();
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
      Uri.parse('http://10.0.2.2:8000/baby_profiles/my_profiles'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BabyCam'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final babies = snapshot.data ?? [];
            return Column(
              children: [
                HomeHeader(
                  username: widget.username,
                  isCameraOn: _isCameraOn,
                  onCameraToggle: (value) =>
                      setState(() => _isCameraOn = value),
                ),
                Expanded(
                  child: NotificationList(notifications: _notifications),
                ),
                CustomBottomNav(
                  selectedIndex: _selectedIndex,
                  onTap: (index) => setState(() => _selectedIndex = index),
                  notifications: _notifications,
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
