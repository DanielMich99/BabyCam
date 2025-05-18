import 'package:flutter/material.dart';
import '../components/account_settings_tile.dart';
import '../components/baby_profiles_tile.dart';
import '../components/system_settings_tile.dart';
import '../components/settings_appbar_title.dart';

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
              const AccountSettingsTile(),
              BabyProfilesTile(
                babyName: babyName,
                babyAgeMonths: babyAgeMonths,
                healthCondition: healthCondition,
                healthConditions: healthConditions,
                onNameChanged: (value) => setState(() => babyName = value),
                onAgeChanged: (value) => setState(() => babyAgeMonths = value),
                onHealthChanged: (value) =>
                    setState(() => healthCondition = value),
              ),
              const SystemSettingsTile(),
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
          // Handle navigation
        },
      ),
    );
  }
}
