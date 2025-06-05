import 'package:flutter/material.dart';
import '../../screens/camera_screen.dart';
import '../../screens/alerts_screen.dart';
import '../../screens/babies_screen.dart';
import '../../screens/settings_screen.dart';
import '../../models/notification_item.dart';
import '../../services/detection_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<NotificationItem> notifications;

  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.notifications,
  }) : super(key: key);

  void _handleNavigation(BuildContext context, int index) {
    onTap(index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertsScreen(
              detectionService: DetectionService(),
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BabiesScreen(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _handleNavigation(context, index),
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
            icon: Icon(Icons.child_care),
            label: 'Babies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
