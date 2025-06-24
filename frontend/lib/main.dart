import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/websocket_service.dart';
import 'services/auth_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final isAuth = await AuthState.isAuthenticated();
    if (!isAuth) {
      _webSocketService.disconnect();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      if (!_webSocketService.isConnected && _webSocketService.shouldReconnect) {
        _webSocketService.connect();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _webSocketService.disconnect(preserveReconnect: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}