import 'package:flutter/material.dart';
import '../components/settings/account_settings_tile.dart';
import '../components/settings/system_settings_tile.dart';
import '../components/settings/settings_appbar_title.dart';
import '../screens/home_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_state.dart';
import '../services/notification_service.dart';

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

  final storage = FlutterSecureStorage();

  void _handleLogout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _updateUser({String? email, String? password}) async {
    final url = Uri.parse('${AppConfig.baseUrl}/users/me');
    final token = await _getToken(); // Implement this to get JWT
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    });
    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        _showSnackBar('Update successful!');
      } else {
        _showSnackBar('Update failed: \\${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<String?> _getToken() async {
    return await AuthState.getAuthToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AccountSettingsTile(
              //   username: babyName,
              //   onUsernameChanged: (value) => setState(() => babyName = value),
              //   onLogout: _handleLogout,
              // ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Change Email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showChangeEmailDialog(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showChangePasswordDialog(context),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'New Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateUser(email: emailController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != confirmController.text) {
                _showSnackBar('Passwords do not match!');
                return;
              }
              Navigator.of(context).pop();
              await _updateUser(password: passwordController.text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleDeleteAccount();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    try {
      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      // 1. Gather baby_profile_ids
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final babiesResponse = await http.get(
        Uri.parse('${AppConfig.baseUrl}/baby_profiles/my_profiles'),
        headers: headers,
      );
      if (babiesResponse.statusCode != 200) {
        if (mounted) Navigator.of(context).pop();
        _showSnackBar('Failed to fetch baby profiles: ${babiesResponse.body}');
        return;
      }
      final List<dynamic> babies = jsonDecode(babiesResponse.body);
      final List<int> babyProfileIds =
          babies.map((b) => b['id'] as int).toList();

      // 2. Get FCM token
      String? fcmToken;
      try {
        fcmToken = await NotificationService().getFCMToken();
      } catch (e) {
        fcmToken = null;
      }
      if (fcmToken == null) {
        if (mounted) Navigator.of(context).pop();
        _showSnackBar('Failed to get FCM token.');
        return;
      }

      // 3. Call logout endpoint and clear state
      final logoutUrl = Uri.parse('${AppConfig.baseUrl}/auth/logout');
      final logoutBody = jsonEncode({
        'baby_profile_ids': babyProfileIds,
        'fcm_token': fcmToken,
      });
      final logoutResponse =
          await http.post(logoutUrl, headers: headers, body: logoutBody);
      if (logoutResponse.statusCode != 200) {
        if (mounted) Navigator.of(context).pop();
        _showSnackBar('Logout failed: ${logoutResponse.body}');
        return;
      }
      await AuthState.logout();
      // 4. Call delete user endpoint
      final deleteUrl = Uri.parse('${AppConfig.baseUrl}/users/me');
      final deleteResponse = await http.delete(deleteUrl, headers: headers);
      if (mounted) Navigator.of(context).pop(); // Remove loader
      if (deleteResponse.statusCode == 200) {
        // 5. Redirect to login screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        _showSnackBar('Delete failed: ${deleteResponse.body}');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
