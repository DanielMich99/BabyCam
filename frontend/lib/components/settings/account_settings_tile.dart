import 'package:flutter/material.dart';

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
  bool _obscurePassword = true;
  String _initialUsername = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _passwordController = TextEditingController();
    _initialUsername = widget.username;
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
    super.dispose();
  }

  bool get _hasChanged =>
      _usernameController.text != _initialUsername ||
      _passwordController.text.isNotEmpty;

  void _onSave() {
    widget.onUsernameChanged(_usernameController.text);
    // Password change is just UI for now
    setState(() {
      _initialUsername = _usernameController.text;
      _passwordController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved (UI only, no backend logic)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.person),
      title: const Text('account settings',
          style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasChanged ? _onSave : null,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
