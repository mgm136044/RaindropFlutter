import 'dart:math';
import 'package:flutter/material.dart';

/// A single splash particle.
class SplashParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;

  SplashParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
  });
}

/// CustomPainter that draws water splash particles at the water surface.
/// Simplified version of WaterSplashView.swift.
class WaterSplashPainter extends CustomPainter {
  final List<SplashParticle> splashes;
  final double waterLevel;
  final Color splashColor;

  WaterSplashPainter({
    required this.splashes,
    required this.waterLevel,
    required this.splashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final waterY = size.height * (1.0 - waterLevel * 0.80);

    for (final splash in splashes) {
      final alpha = (1.0 - splash.life / splash.maxLife).clamp(0.0, 1.0);
      final x = splash.x * size.width;
      final y = waterY + splash.y;

      canvas.drawCircle(
        Offset(x, y),
        splash.size / 2,
        Paint()..color = splashColor.withValues(alpha: alpha * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(WaterSplashPainter oldDelegate) => true;
}

/// Manages the water splash particle system.
class WaterSplashSystem {
  final Random _random = Random();
  List<SplashParticle> splashes = [];
  int _frameCount = 0;
  double intensity;

  WaterSplashSystem({this.intensity = 0.5});

  int get _spawnRate =>
      (2 + intensity.clamp(0.0, 1.0) * 8).toInt();

  void update({required bool isActive, required double waterLevel}) {
    if (!isActive || waterLevel <= 0.05) {
      splashes.clear();
      return;
    }

    _frameCount++;

    // Spawn new splashes
    final interval = max(30 ~/ _spawnRate, 1);
    if (_frameCount % interval == 0) {
      splashes.add(SplashParticle(
        x: _randRange(0.15, 0.85),
        y: 0,
        vx: _randRange(-0.3, 0.3),
        vy: _randRange(-4.0, -1.5),
        life: 0,
        maxLife: _randRange(0.3, 0.6),
        size: _randRange(1.5, 3.5),
      ));
    }

    // Update existing
    const dt = 1.0 / 30.0;
    splashes = splashes.where((s) {
      s.life += dt;
      if (s.life >= s.maxLife) return false;
      s.x += s.vx * dt * 0.02;
      s.y += s.vy;
      s.vy += 12 * dt; // gravity
      return true;
    }).toList();
  }

  void clear() {
    splashes.clear();
    _frameCount = 0;
  }

  double _randRange(double lo, double hi) =>
      lo + _random.nextDouble() * (hi - lo);
}
