import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountSettingsTile extends StatefulWidget {
  final String username;
  final ValueChanged<String> onUsernameChanged;
  final VoidCallback onLogout;

  const AccountSettingsTile({
    Key? key,
    required this.username,
    required this.onUsernameChanged,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<AccountSettingsTile> createState() => _AccountSettingsTileState();
}

class _AccountSettingsTileState extends State<AccountSettingsTile> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  bool _obscurePassword = true;
  String _initialUsername = '';
  String _initialEmail = '';
  File? _profileImage;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _passwordController = TextEditingController();
    _emailController =
        TextEditingController(text: ''); // Set to user's email if available
    _initialUsername = widget.username;
    _initialEmail = '';
  }

  @override
  void didUpdateWidget(covariant AccountSettingsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _usernameController.text = widget.username;
      _initialUsername = widget.username;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _hasChanged =>
      _usernameController.text != _initialUsername ||
      _emailController.text != _initialEmail ||
      _passwordController.text.isNotEmpty;

  void _onSave() {
    widget.onUsernameChanged(_usernameController.text);
    setState(() {
      _initialUsername = _usernameController.text;
      _initialEmail = _emailController.text;
      _passwordController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved (UI only, no backend logic)')),
    );
  }

  void _onCancel() {
    setState(() {
      _usernameController.text = _initialUsername;
      _emailController.text = _initialEmail;
      _passwordController.clear();
      _emailError = null;
    });
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _changePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _changePicture,
              child: CircleAvatar(
                radius: 38,
                backgroundColor: Colors.blue[50],
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.person, size: 44, color: Colors.blue[300])
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blue[700],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: const OutlineInputBorder(),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _emailError = null;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasChanged
                        ? () {
                            if (_emailController.text.isNotEmpty &&
                                !_validateEmail(_emailController.text)) {
                              setState(() {
                                _emailError = 'Invalid email format';
                              });
                              return;
                            }
                            _onSave();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _hasChanged ? _onCancel : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 18),
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
