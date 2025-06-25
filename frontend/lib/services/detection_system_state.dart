import 'package:flutter/widgets.dart';

class DetectionSystemState {
  static final DetectionSystemState _instance =
      DetectionSystemState._internal();
  factory DetectionSystemState() => _instance;
  DetectionSystemState._internal();

  bool _isActive = false;
  final List<VoidCallback> _listeners = [];

  bool get isActive => _isActive;

  void setActive(bool active) {
    if (_isActive != active) {
      _isActive = active;
      _notifyListeners();
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }
}
