import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import '../models/notification_item.dart';
import '../models/baby_profile.dart';
import '../components/home/home_header.dart';
import '../components/home/custom_bottom_nav.dart';
import '../components/alerts/notification_list.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCameraOn = false;
  final List<NotificationItem> _notifications = [
    NotificationItem(
      message: 'Tom stared at the Electrical Socket',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    NotificationItem(
      message: 'Tom reached to the Electrical Socket',
      time: DateTime.now().subtract(const Duration(minutes: 1, seconds: 54)),
    ),
    NotificationItem(
      message: 'Tom touched the Electrical Socket',
      time: DateTime.now().subtract(const Duration(minutes: 1, seconds: 52)),
    ),
    NotificationItem(
      message: 'Tom reached to the front door',
      time: DateTime.now().subtract(const Duration(seconds: 15)),
      isRead: false,
    ),
  ];

  final List<BabyProfile> _babies = [
    BabyProfile(
      name: 'Tom',
      imageUrl: 'assets/images/tom.jpg',
      isSelected: true,
    ),
    BabyProfile(name: 'Yael', imageUrl: 'assets/images/yael.jpg'),
    BabyProfile(name: 'David', imageUrl: 'assets/images/david.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuthenticated = await AuthState.isAuthenticated();
    if (!isAuthenticated && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _handleLogout() async {
    await AuthState.clearAuth();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _handleBabySelected(int index) {
    setState(() {
      for (var i = 0; i < _babies.length; i++) {
        _babies[i] = _babies[i].copyWith(isSelected: i == index);
      }
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
        child: Column(
          children: [
            HomeHeader(
              username: widget.username,
              isCameraOn: _isCameraOn,
              onCameraToggle: (value) => setState(() => _isCameraOn = value),
            ),
            Expanded(
              child: NotificationList(notifications: _notifications),
            ),
            CustomBottomNav(
              selectedIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              notifications: _notifications,
              babies: _babies,
            ),
          ],
        ),
      ),
    );
  }
}

extension BabyProfileExtension on BabyProfile {
  BabyProfile copyWith({String? name, String? imageUrl, bool? isSelected}) {
    return BabyProfile(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
