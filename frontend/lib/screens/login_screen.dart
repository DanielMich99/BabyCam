import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';
import '../services/websocket_service.dart';
import '../services/model_training_status_service.dart';
import '../services/notification_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import '../components/auth/logo_header.dart';
import '../components/auth/login_form.dart';
import '../config/app_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _websocketService = WebSocketService();
  bool _isLoading = false;

  Future<void> _initializeServices(String token) async {
    await _websocketService.initialize(
        AppConfig.baseUrl.replaceFirst(RegExp(r'^https?://'), ''), token);
    ModelTrainingStatusService().initialize(_websocketService);

    // Re-initialize notification service to ensure FCM token is registered
    await NotificationService().reinitialize();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        // Save authentication state
        final token = response['access_token'].toString().trim();
        await AuthState.saveAuthToken(token);
        await AuthState.saveUsername(_usernameController.text);

        // Initialize WebSocket and training status tracking
        await _initializeServices(token);

        if (mounted) {
          // Login successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                username: _usernameController.text,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isAuthenticated = await AuthState.isAuthenticated();
    if (isAuthenticated) {
      final username = await AuthState.getUsername();
      final token = await AuthState.getAuthToken();
      if (token != null) {
        await _initializeServices(token);
      }
      if (mounted && username != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: username),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LogoHeader(),
                const SizedBox(height: 32),
                LoginForm(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  onLogin: _handleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
