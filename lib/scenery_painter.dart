import 'package:flutter/material.dart';
import 'dart:math';

class SceneryPainter extends CustomPainter {
  final double angle;
  final bool isNight;

  SceneryPainter(this.angle, {required this.isNight});

  // Helper method to draw a cloud
  void _drawCloud(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center.translate(-20, 0), 15, paint);
    canvas.drawCircle(center.translate(0, -10), 20, paint);
    canvas.drawCircle(center.translate(20, 0), 15, paint);
    canvas.drawCircle(center.translate(0, 10), 12, paint);
  }

  void _drawBird(Canvas canvas, Offset position, Paint paint) {
    final path = Path()
      ..moveTo(position.dx, position.dy)
      ..relativeLineTo(-10, -5)
      ..relativeLineTo(10, 5)
      ..relativeLineTo(-10, 5);
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [
                Colors.indigo.shade900,
                Colors.purple.shade900,
              ]
            : [
                Colors.lightBlue.shade300,
                Colors.lightBlue.shade100,
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    final celestialPaint = Paint()
      ..color = isNight ? Colors.grey.shade200 : Colors.yellow;

    final celestialX = (cos(angle) * 100) + size.width * 0.8;
    final celestialY = (sin(angle) * 50) + size.height * 0.2;

    canvas.drawCircle(
      Offset(celestialX, celestialY),
      40,
      celestialPaint,
    );

    if (isNight) {
      final craterPaint = Paint()..color = Colors.grey.shade400;
      canvas.drawCircle(
        Offset(celestialX - 15, celestialY - 10),
        8,
        craterPaint,
      );
      canvas.drawCircle(
        Offset(celestialX + 10, celestialY + 5),
        5,
        craterPaint,
      );
      canvas.drawCircle(
        Offset(celestialX + 15, celestialY - 15),
        10,
        craterPaint,
      );
    }

    final cloudPaint = Paint()
      ..color = isNight ? Colors.grey.shade700 : Colors.white.withOpacity(0.9);

    for (int i = 0; i < 4; i++) {
      double x = (sin(angle + i) * 80) + size.width * (0.1 + i * 0.25);
      double y = 60.0 + i * 40;
      _drawCloud(canvas, Offset(x, y), cloudPaint);
    }

    if (!isNight) {
      final birdPaint = Paint()..color = Colors.black;
      for (int i = 0; i < 3; i++) {
        double bx = size.width * (0.3 + i * 0.2) + cos(angle + i) * 50;
        double by = 140.0 + sin(angle + i) * 20;
        _drawBird(canvas, Offset(bx, by), birdPaint);
      }
    }

    final groundPaint = Paint()
      ..color = isNight ? Colors.grey.shade900 : Colors.green.shade700;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SceneryPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.isNight != isNight;
  }
}
