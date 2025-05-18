import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import '../components/auth/logo_header.dart';
import '../components/auth/login_form.dart';
import '../components/auth/social_login_buttons.dart';

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
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final result = await googleSignIn.signIn();
      if (result != null) {
        // Handle successful Google sign in
        print('Google Sign In: \\${result.email}');
      }
    } catch (error) {
      print('Google Sign In Error: \\${error}');
    }
  }

  Future<void> _handleFacebookSignIn() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // Handle successful Facebook sign in
        final userData = await FacebookAuth.instance.getUserData();
        print('Facebook Sign In: \\${userData['email']}');
      }
    } catch (error) {
      print('Facebook Sign In Error: \\${error}');
    }
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
        await AuthState.saveAuthToken(response['access_token']);
        await AuthState.saveUsername(_usernameController.text);

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
                SocialLoginButtons(
                  onGoogleSignIn: _handleGoogleSignIn,
                  onFacebookSignIn: _handleFacebookSignIn,
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
