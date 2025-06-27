import 'package:flutter/material.dart';

class HeadCameraIcon extends StatelessWidget {
  final double size;
  final Color skinColor;
  final Color cameraColor;

  const HeadCameraIcon({
    Key? key,
    this.size = 64.0,
    this.skinColor = const Color(0xFFFFD1A9),
    this.cameraColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _HeadCameraPainter(skinColor, cameraColor),
    );
  }
}

class _HeadCameraPainter extends CustomPainter {
  final Color skinColor;
  final Color cameraColor;

  _HeadCameraPainter(this.skinColor, this.cameraColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Increase head size so the icon better fills its square canvas
    final headRadius = size.width * 0.43;

    // Draw head
    final paint = Paint()..color = skinColor;
    canvas.drawCircle(center, headRadius, paint);

    // Ears
    final earOffset = headRadius * 0.8;
    final earRadius = headRadius * 0.2;
    canvas.drawCircle(Offset(center.dx - earOffset, center.dy), earRadius, paint);
    canvas.drawCircle(Offset(center.dx + earOffset, center.dy), earRadius, paint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    final eyeOffsetX = headRadius * 0.4;
    final eyeOffsetY = headRadius * 0.2;
    final eyeRadius = headRadius * 0.08;
    canvas.drawCircle(Offset(center.dx - eyeOffsetX, center.dy - eyeOffsetY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX, center.dy - eyeOffsetY), eyeRadius, eyePaint);

    // Smile
    final smilePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final smileRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + headRadius * 0.2),
      width: headRadius * 0.7,
      height: headRadius * 0.4,
    );
    canvas.drawArc(smileRect, 0, 3.14, false, smilePaint);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFFA8A8);
    final cheekRadius = headRadius * 0.1;
    canvas.drawCircle(Offset(center.dx - eyeOffsetX, center.dy + eyeOffsetY), cheekRadius, cheekPaint);
    canvas.drawCircle(Offset(center.dx + eyeOffsetX, center.dy + eyeOffsetY), cheekRadius, cheekPaint);

    // Headband on forehead
    final bandHeight = size.height * 0.08;
    final bandY = center.dy - headRadius * 0.6;
    final bandRect = Rect.fromCenter(
      center: Offset(center.dx, bandY),
      width: headRadius * 2,
      height: bandHeight,
    );
    final bandPaint = Paint()..color = const Color(0xFFFF6B6B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, Radius.circular(bandHeight / 2)),
      bandPaint,
    );

    // Camera on headband (on forehead)
    final camWidth = headRadius * 1.1;
    final camHeight = bandHeight * 1.6;
    final camRect = Rect.fromCenter(
      center: Offset(center.dx, bandY),
      width: camWidth,
      height: camHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(camRect, Radius.circular(4)),
      Paint()..color = cameraColor,
    );

    // Camera lens
    final lensOuter = Paint()..color = Colors.white;
    final lensInner = Paint()..color = Colors.blueAccent;
    final lensCenter = camRect.center;
    final outerRadius = camHeight * 0.35;
    final innerRadius = camHeight * 0.2;
    canvas.drawCircle(lensCenter, outerRadius, lensOuter);
    canvas.drawCircle(lensCenter, innerRadius, lensInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
