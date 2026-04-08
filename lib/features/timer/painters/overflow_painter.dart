import 'dart:math';
import 'package:flutter/material.dart';

/// A single golden sparkle particle for the overflow celebration.
class SparkleParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
  });
}

/// CustomPainter that draws 25 golden sparkle particles for overflow animation.
/// Matches OverflowAnimationView.swift.
class OverflowPainter extends CustomPainter {
  final List<SparkleParticle> sparkles;

  OverflowPainter({required this.sparkles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final alpha =
          (1.0 - sparkle.life / sparkle.maxLife).clamp(0.0, 1.0);
      final x = sparkle.x * size.width;
      final y = sparkle.y * size.height;

      // Core sparkle
      canvas.drawCircle(
        Offset(x, y),
        sparkle.size / 2,
        Paint()..color = Colors.yellow.withValues(alpha: alpha * 0.8),
      );

      // Glow
      canvas.drawCircle(
        Offset(x, y),
        sparkle.size,
        Paint()..color = Colors.orange.withValues(alpha: alpha * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(OverflowPainter oldDelegate) => true;
}

/// Manages the overflow sparkle particle system.
class OverflowSparkleSystem {
  final Random _random = Random();
  List<SparkleParticle> sparkles = [];

  /// Spawn a burst of 25 sparkle particles from center.
  void spawnBurst() {
    sparkles = List.generate(25, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _randRange(0.003, 0.012);
      return SparkleParticle(
        x: 0.5,
        y: 0.45,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        life: 0,
        maxLife: _randRange(1.0, 2.5),
        size: _randRange(3, 7),
      );
    });
  }

  /// Update particle positions. Call at 30fps.
  void update() {
    if (sparkles.isEmpty) return;
    const dt = 1.0 / 30.0;
    sparkles = sparkles.where((s) {
      s.life += dt;
      if (s.life >= s.maxLife) return false;
      s.x += s.vx;
      s.y += s.vy;
      s.vy += 0.0002; // light gravity
      s.size *= 0.995;
      return true;
    }).toList();
  }

  void clear() {
    sparkles.clear();
  }

  double _randRange(double lo, double hi) =>
      lo + _random.nextDouble() * (hi - lo);
}
