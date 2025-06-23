import 'package:flutter/material.dart';

class StaticCameraIcon extends StatelessWidget {
  final double size;
  final Color cameraColor;
  final Color dresserColor;

  const StaticCameraIcon({
    Key? key,
    this.size = 64.0,
    this.cameraColor = Colors.black,
    this.dresserColor = const Color(0xFFE68A00),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StaticCameraPainter(cameraColor, dresserColor),
    );
  }
}

class _StaticCameraPainter extends CustomPainter {
  final Color cameraColor;
  final Color dresserColor;

  _StaticCameraPainter(this.cameraColor, this.dresserColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final width = size.width;
    final height = size.height;

    // Draw dresser (body)
    // Adjust proportions so the icon uses its space evenly
    final dresserTop = height * 0.45;
    final dresserHeight = height * 0.35;
    final drawerHeight = dresserHeight / 2;

    final dresserRect = Rect.fromLTWH(width * 0.2, dresserTop, width * 0.6, dresserHeight);
    paint.color = dresserColor;
    canvas.drawRect(dresserRect, paint);

    // Draw drawers
    paint.color = Colors.black;
    double handleWidth = width * 0.2;
    double handleHeight = height * 0.05;
    for (int i = 0; i < 2; i++) {
      final drawerCenterY = dresserTop + drawerHeight * (i + 0.5);
      final handleRect = Rect.fromCenter(
        center: Offset(width / 2, drawerCenterY),
        width: handleWidth,
        height: handleHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(handleRect, Radius.circular(handleHeight / 2)),
        paint,
      );
    }

    // Draw dresser legs
    final legWidth = width * 0.08;
    final legHeight = height * 0.1;
    final leftLeg = Rect.fromLTWH(width * 0.22, dresserTop + dresserHeight, legWidth, legHeight);
    final rightLeg = Rect.fromLTWH(width * 0.7, dresserTop + dresserHeight, legWidth, legHeight);
    canvas.drawRect(leftLeg, paint);
    canvas.drawRect(rightLeg, paint);

    // Draw camera body
    final camWidth = width * 0.6;
    final camHeight = height * 0.25;
    final camRect = Rect.fromCenter(
      center: Offset(width / 2, dresserTop - camHeight / 2),
      width: camWidth,
      height: camHeight,
    );
    paint.color = cameraColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(camRect, Radius.circular(6)),
      paint,
    );

    // Draw camera lens
    final lensOuterRadius = camHeight * 0.3;
    final lensInnerRadius = camHeight * 0.18;
    final lensCenter = camRect.center;
    canvas.drawCircle(lensCenter, lensOuterRadius, Paint()..color = Colors.white);
    canvas.drawCircle(lensCenter, lensInnerRadius, Paint()..color = Colors.blueAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
