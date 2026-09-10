import 'dart:math' as math;

import 'package:flutter/material.dart';

class AtmospherePainter extends CustomPainter {
  const AtmospherePainter({
    required this.position,
    required this.ambient,
    required this.activeColor,
  });

  final double position;
  final double ambient;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(73);
    final horizon = size.height * 0.74;
    final cyberpunk = (1 - (position - 4).abs()).clamp(0.0, 1.0);
    final industrial = (1 - (position - 3).abs()).clamp(0.0, 1.0);
    final finale = (position - 5.2).clamp(0.0, 1.0);

    for (var i = 0; i < 68; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = random.nextDouble() * math.pi * 2;
      final speed = 0.25 + random.nextDouble() * 0.8;
      final driftX = math.sin(ambient * math.pi * 2 * speed + phase) * 12;
      final driftY = math.cos(ambient * math.pi * 2 * speed + phase) * 8;
      final radius = 0.45 + random.nextDouble() * 1.5;
      final alpha =
          (0.1 + random.nextDouble() * 0.45) * (0.72 + cyberpunk * 0.5);
      final color = Color.lerp(
        activeColor,
        Colors.white,
        random.nextDouble() * 0.55,
      )!.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(x + driftX, y + driftY),
        radius,
        Paint()..color = color,
      );
    }

    if (industrial > 0.05) {
      final smokePaint = Paint()
        ..color = const Color(0xffd2d1ca).withValues(alpha: 0.04 * industrial)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;
      for (var i = 0; i < 4; i++) {
        final path = Path()..moveTo(size.width * (0.12 + i * 0.25), horizon);
        path.cubicTo(
          size.width * (0.05 + i * 0.26),
          horizon - size.height * 0.13,
          size.width * (0.22 + i * 0.23),
          horizon - size.height * 0.24,
          size.width * (0.15 + i * 0.25),
          horizon - size.height * 0.36,
        );
        canvas.drawPath(path, smokePaint);
      }
    }

    if (cyberpunk > 0.05) {
      final gridPaint = Paint()
        ..color = const Color(0xff4cdfff).withValues(alpha: 0.08 * cyberpunk)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      for (var i = 0; i < 9; i++) {
        final y = horizon + i * size.height * 0.025;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
      for (var i = -5; i < 6; i++) {
        canvas.drawLine(
          Offset(size.width / 2 + i * 20, horizon),
          Offset(size.width / 2 + i * 94, size.height),
          gridPaint,
        );
      }
      final scanPaint = Paint()
        ..color = const Color(0xffd43aff).withValues(alpha: 0.07 * cyberpunk)
        ..strokeWidth = 1;
      final scanY = (ambient * size.height * 1.3) % size.height;
      canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);
    }

    if (finale > 0) {
      final linePaint = Paint()
        ..color = const Color(0xffb8d6ff).withValues(alpha: 0.12 * finale)
        ..strokeWidth = 0.6;
      for (var i = 0; i < 12; i++) {
        final y = size.height * (0.08 + i * 0.065);
        canvas.drawLine(
          Offset(size.width * 0.16, y),
          Offset(size.width * 0.84, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AtmospherePainter oldDelegate) => true;
}
