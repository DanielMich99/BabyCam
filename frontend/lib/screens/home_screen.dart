import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import '../models/notification_item.dart';
import '../models/baby_profile.dart';
import '../components/home/baby_profiles_list.dart';
import '../components/settings/account_settings_tile.dart';
import '../components/auth/login_form.dart';
import '../components/home/camera_preview.dart';
import '../components/alerts/notification_list.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'alerts_screen.dart';
import 'camera_screen.dart';

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
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Welcome, ',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        widget.username,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.power_settings_new,
                          color: _isCameraOn ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCameraOn = !_isCameraOn;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notifications
            Expanded(
              child: NotificationList(notifications: _notifications),
            ),

            // Baby Profiles
            BabyProfilesList(
              babies: _babies,
              onBabySelected: _handleBabySelected,
              onOptionSelected: (index, option) {
                if (option == 'view') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(_babies[index].name),
                      content: Text('Details for \\${_babies[index].name}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                } else if (option == 'remove') {
                  setState(() {
                    _babies.removeAt(index);
                  });
                }
              },
              onCameraToggle: (index, cameraNumber) {
                setState(() {
                  if (cameraNumber == 1) {
                    _babies[index] = _babies[index]
                        .copyWith(camera1On: !_babies[index].camera1On);
                  } else if (cameraNumber == 2) {
                    _babies[index] = _babies[index]
                        .copyWith(camera2On: !_babies[index].camera2On);
                  }
                });
              },
            ),

            // Bottom Navigation Bar
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AlertsScreen(notifications: _notifications),
                      ),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.camera_alt),
                    label: 'Camera',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: 'Alerts',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
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
