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
    return const SizedBox.shrink();
  }
}
