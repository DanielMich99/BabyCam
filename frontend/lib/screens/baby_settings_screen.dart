import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import '../components/settings/general_baby_details_section.dart';
import '../config/app_config.dart';
import '../services/auth_state.dart';
import 'package:http/http.dart' as http;

class BabySettingsScreen extends StatefulWidget {
  final BabyProfile baby;
  const BabySettingsScreen({Key? key, required this.baby}) : super(key: key);

  @override
  State<BabySettingsScreen> createState() => _BabySettingsScreenState();
}

class _BabySettingsScreenState extends State<BabySettingsScreen> {
  bool _isDeleting = false;

  Future<void> _deleteBaby() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Baby'),
        content: const Text(
            'Are you sure you want to delete this baby profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _isDeleting = true;
    });
    try {
      final token = await AuthState.getAuthToken();
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/baby_profiles/${widget.baby.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.of(context).pop(true); // Indicate success to BabiesScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Baby profile deleted successfully!')),
          );
        }
      } else {
        _showSnackBar('Delete failed: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted)
        setState(() {
          _isDeleting = false;
        });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General Baby Details
              GeneralBabyDetailsSection(baby: widget.baby),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Baby'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isDeleting ? null : _deleteBaby,
              ),
              if (_isDeleting)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
