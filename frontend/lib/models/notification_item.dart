class NotificationItem {
  final int id;
  final int babyProfileId;
  final int classId;
  final String className;
  final double confidence;
  final String cameraType;
  final DateTime timestamp;
  final bool isViewed;
  final bool isHandled;

  NotificationItem({
    required this.id,
    required this.babyProfileId,
    required this.classId,
    required this.className,
    required this.confidence,
    required this.cameraType,
    required this.timestamp,
    this.isViewed = false,
    this.isHandled = false,
  });

  NotificationItem copyWith({
    int? id,
    int? babyProfileId,
    int? classId,
    String? className,
    double? confidence,
    String? cameraType,
    DateTime? timestamp,
    bool? isViewed,
    bool? isHandled,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      babyProfileId: babyProfileId ?? this.babyProfileId,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      confidence: confidence ?? this.confidence,
      cameraType: cameraType ?? this.cameraType,
      timestamp: timestamp ?? this.timestamp,
      isViewed: isViewed ?? this.isViewed,
      isHandled: isHandled ?? this.isHandled,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      babyProfileId: json['baby_profile_id'],
      classId: json['class_id'],
      className: json['class_name'],
      confidence: json['confidence'].toDouble(),
      cameraType: json['camera_type'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
