import 'package:flutter/widgets.dart';
import 'websocket_service.dart';

class ModelTrainingStatusService {
  static final ModelTrainingStatusService _instance = ModelTrainingStatusService._internal();
  factory ModelTrainingStatusService() => _instance;
  ModelTrainingStatusService._internal();

  bool _initialized = false;

  final Map<int, Map<String, bool>> _status = {};
  final List<VoidCallback> _listeners = [];

  void initialize(WebSocketService service) {
    if (_initialized) return;
    _initialized = true;
    service.addDetectionListener(_handleEvent);
  }

  void _handleEvent(Map<String, dynamic> event) {
    if (event['type'] == 'model_training_completed') {
      completeTraining(event['baby_profile_id'], event['camera_type']);
    }
  }

  void startTraining(int babyProfileId, String cameraType) {
    _status.putIfAbsent(babyProfileId, () => {});
    _status[babyProfileId]![cameraType] = true;
    _notify();
  }

  void completeTraining(int babyProfileId, String cameraType) {
    if (_status[babyProfileId] != null) {
      _status[babyProfileId]![cameraType] = false;
    }
    _notify();
  }

  bool isTraining(int babyProfileId, String cameraType) {
    return _status[babyProfileId]?[cameraType] ?? false;
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notify() {
    for (final l in List<VoidCallback>.from(_listeners)) {
      l();
    }
  }
}