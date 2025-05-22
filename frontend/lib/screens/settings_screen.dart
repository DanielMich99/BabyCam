import 'package:flutter/material.dart';
import '../components/settings/account_settings_tile.dart';
import '../components/settings/system_settings_tile.dart';
import '../components/settings/settings_appbar_title.dart';
import '../screens/home_screen.dart';
import '../screens/alerts_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String babyName = 'Tom';
  int babyAgeMonths = 11;
  String healthCondition = 'None';
  final List<String> healthConditions = ['None', 'Allergy', 'Asthma', 'Other'];

  void _handleLogout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.pop(context),
        ),
        title: const SettingsAppBarTitle(),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AccountSettingsTile(
                username: babyName,
                onUsernameChanged: (value) => setState(() => babyName = value),
                onLogout: _handleLogout,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Camera'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(username: babyName)),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AlertsScreen(notifications: [])),
            );
          } else if (index == 3) {
            // Already on settings, do nothing
          }
        },
      ),
    );
  }
}
