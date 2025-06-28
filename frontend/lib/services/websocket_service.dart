import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  String? _baseUrl;
  String? _token;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = false;
  final List<Function(Map<String, dynamic>)> _detectionListeners = [];

  Future<void> initialize(String baseUrl, String token) async {
    _baseUrl = baseUrl;
    _token = token;
    _shouldReconnect = true;
    await connect();
  }

  Future<void> connect() async {
    if (_baseUrl == null || _token == null) {
      throw Exception('WebSocket not initialized. Call initialize() first.');
    }
    if (!_shouldReconnect) return;

    // If a connection already exists and is active, avoid opening another one
    if (_channel != null && _isConnected) {
      return;
    }

    // Clean up any stale connection
    if (_channel != null) {
      try {
        await _channel!.sink.close(status.goingAway);
      } catch (_) {}
      _channel = null;
      _isConnected = false;
    }

    try {
      final uri = Uri.parse('ws://$_baseUrl/ws/detections');
      print('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);

      // 🔥 Send the token right after connection
      final cleanToken = _token!.trim();
      final authMessage = jsonEncode({'token': cleanToken});
      _channel!.sink.add(authMessage);

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          for (final listener in _detectionListeners) {
            listener(data);
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket Connection Closed');
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _isConnected = true;
      print('WebSocket Connected');
    } catch (e) {
      print('WebSocket Connection Error: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }


  void disconnect({bool preserveReconnect = false}) {
    if (!preserveReconnect) {
      _shouldReconnect = false;
    }
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && _shouldReconnect) {
        connect();
      }
    });
  }

  void addDetectionListener(Function(Map<String, dynamic>) listener) {
    _detectionListeners.add(listener);
  }

  void removeDetectionListener(Function(Map<String, dynamic>) listener) {
    _detectionListeners.remove(listener);
  }

  bool get isConnected => _isConnected;
  bool get shouldReconnect => _shouldReconnect;
}