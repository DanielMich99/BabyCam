class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'label': label,
      };

  BoundingBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    String? label,
  }) {
    return BoundingBox(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
    );
  }
}
