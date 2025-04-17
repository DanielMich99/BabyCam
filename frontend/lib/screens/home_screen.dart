import 'package:flutter/material.dart';
import '../services/auth_state.dart';
import 'login_screen.dart';

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

class BabyProfile {
  final String name;
  final String imageUrl;
  final bool isSelected;

  BabyProfile({
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
  });
}

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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
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
                          // Handle settings
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                      ),
                      title: Text(
                        notification.message,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${notification.time.hour}:${notification.time.minute.toString().padLeft(2, '0')}:${notification.time.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: notification.isRead
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Camera Preview Placeholder
            Expanded(
              child: Center(
                child: _isCameraOn
                    ? Container(
                        margin: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Camera Feed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),

            // Baby Profiles
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 88,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _babies.length,
                      itemBuilder: (context, index) {
                        final baby = _babies[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    for (var b in _babies) {
                                      b = b.copyWith(isSelected: false);
                                    }
                                    _babies[index] = baby.copyWith(
                                      isSelected: true,
                                    );
                                  });
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: baby.isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage: AssetImage(baby.imageUrl),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                baby.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
