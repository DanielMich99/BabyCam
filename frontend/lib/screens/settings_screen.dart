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
    );
  }
}
