import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'services/websocket_service.dart';
import 'services/auth_state.dart';
import 'services/notification_service.dart';

// This function must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final WebSocketService _webSocketService = WebSocketService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize notification service
    await _notificationService.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   final isAuth = await AuthState.isAuthenticated();
  //   if (!isAuth) {
  //     _webSocketService.disconnect();
  //     return;
  //   }
  //   if (state == AppLifecycleState.resumed) {
  //     if (!_webSocketService.isConnected) {
  //       _webSocketService.enableReconnect();
  //       _webSocketService.connect();
  //     }
  //   } else if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive ||
  //       state == AppLifecycleState.detached) {
  //     _webSocketService.disconnect();
  //   }
  // }

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