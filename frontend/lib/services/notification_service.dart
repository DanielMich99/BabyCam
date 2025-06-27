import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      print('Firebase initialized successfully');

      // Request permission for notifications
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for notifications');
      } else {
        print('User declined or has not accepted permission for notifications');
        print('Authorization status: ${settings.authorizationStatus}');
      }

      // Initialize local notifications
      await _initializeLocalNotifications();
      print('Local notifications initialized');

      // Get FCM token with retry logic
      String? token;
      int retryCount = 0;
      const maxRetries = 3;

      while (token == null && retryCount < maxRetries) {
        try {
          print('Attempting to get FCM token (attempt ${retryCount + 1})');
          token = await _firebaseMessaging.getToken();
          if (token != null) {
            print(
                'FCM Token obtained successfully: ${token.substring(0, 20)}...');
            await _saveTokenToBackend(token);
          } else {
            print('FCM Token is null, retrying...');
            await Future.delayed(Duration(seconds: 2));
          }
        } catch (e) {
          print('Error getting FCM token (attempt ${retryCount + 1}): $e');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: 2));
          }
        }
      }

      if (token == null) {
        print('Failed to get FCM token after $maxRetries attempts');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: ${newToken.substring(0, 20)}...');
        _saveTokenToBackend(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle notification taps when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      _isInitialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notification service: $e');
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android with proper sound configuration
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      // Use custom notification sound
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      enableLights: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      final authToken = await AuthState.getAuthToken();
      if (authToken == null) return;

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/save-fcm-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 201) {
        print('FCM token saved to backend successfully');
      } else {
        print('Failed to save FCM token to backend: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving FCM token to backend: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.notification?.title}');

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'BabyCam Alert',
      body: message.notification?.body ?? 'New detection alert',
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      // Use custom notification sound
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      enableLights: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Use default system sound for iOS
      sound: null,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    // Handle navigation to specific screen based on the notification
    // You can add navigation logic here
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle local notification tap
    // You can add navigation logic here
  }

  Future<void> removeToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        final authToken = await AuthState.getAuthToken();
        if (authToken != null) {
          await http.post(
            Uri.parse('${AppConfig.baseUrl}/auth/remove-fcm-token'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'token': token}),
          );
        }
      }
    } catch (e) {
      print('Error removing FCM token: $e');
    }
  }

  // Get the current FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Force re-initialization and FCM token registration
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

  // Test method to show a local notification
  Future<void> showTestNotification() async {
    print('Showing test notification...');
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from BabyCam',
      payload: 'test',
    );
    print('Test notification sent');
  }
}

// This function must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase for background messages
  await Firebase.initializeApp();

  print('Handling background message: ${message.notification?.title}');

  // You can show a local notification here if needed
  // Note: For background messages, the system will automatically show the notification
  // based on the payload from FCM
}
