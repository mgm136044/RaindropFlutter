import 'dart:math';
import 'package:flutter/material.dart';

/// A single rain drop particle.
class RainParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  RainParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

/// CustomPainter that draws capsule-shaped rain particles with gradient.
/// Matches RainParticleView.swift particle system at 30fps.
class RainParticlePainter extends CustomPainter {
  final List<RainParticle> particles;
  final Color dropGradientTop;
  final Color dropGradientBottom;
  final double waterLevel;

  RainParticlePainter({
    required this.particles,
    required this.dropGradientTop,
    required this.dropGradientBottom,
    required this.waterLevel,
  });

  /// rainStopY: normalized y where rain should stop (water surface).
  double get rainStopY {
    final bucketTopInScene = 56.0 / 360.0;
    final bucketFractionInRain = 320.0 / 360.0;
    final waterSurfaceInBucket = 1.0 - 0.80 * waterLevel.clamp(0.0, 1.0);
    return bucketTopInScene + bucketFractionInRain * waterSurfaceInBucket;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stopPixelY = rainStopY * size.height;

    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      if (y >= stopPixelY) continue;

      final dropSize = particle.size;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - dropSize / 2,
          y - dropSize * 1.5,
          dropSize,
          dropSize * 3,
        ),
        Radius.circular(dropSize / 2),
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          dropGradientTop.withValues(alpha: particle.opacity),
          dropGradientBottom.withValues(alpha: particle.opacity * 0.8),
        ],
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..shader = gradient.createShader(rect.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(RainParticlePainter oldDelegate) => true;
}

/// Manages the rain particle system with a Ticker.
class RainParticleSystem {
  final Random _random = Random();
  List<RainParticle> particles = [];
  double intensity;
  double waterLevel;

  RainParticleSystem({this.intensity = 0.5, this.waterLevel = 0});

  int get _desiredCount =>
      (8 + (80 - 8) * intensity.clamp(0.0, 1.0)).toInt();

  double get _speedLo => 0.004 + (0.012 - 0.004) * intensity;
  double get _speedHi => 0.010 + (0.025 - 0.010) * intensity;
  double get _sizeLo => 1.5 + (3.0 - 1.5) * intensity;
  double get _sizeHi => 3.0 + (7.0 - 3.0) * intensity;
  double get _opacityLo => 0.15 + (0.4 - 0.15) * intensity;
  double get _opacityHi => 0.4 + (0.9 - 0.4) * intensity;

  double get rainStopY {
    final bucketTopInScene = 56.0 / 360.0;
    final bucketFractionInRain = 320.0 / 360.0;
    final waterSurfaceInBucket = 1.0 - 0.80 * waterLevel.clamp(0.0, 1.0);
    return bucketTopInScene + bucketFractionInRain * waterSurfaceInBucket;
  }

  RainParticle _makeParticle({double yLo = -0.3, double yHi = 1.0}) {
    return RainParticle(
      x: _randRange(0.05, 0.95),
      y: _randRange(yLo, yHi),
      speed: _randRange(_speedLo, _speedHi),
      size: _randRange(_sizeLo, _sizeHi),
      opacity: _randRange(_opacityLo, _opacityHi),
    );
  }

  void initialize() {
    particles = List.generate(_desiredCount, (_) => _makeParticle());
  }

  void update() {
    final target = _desiredCount;

    // Adjust particle count gradually
    if (particles.length < target) {
      final toAdd = min(target - particles.length, 3);
      for (var i = 0; i < toAdd; i++) {
        particles.add(_makeParticle(yLo: -0.3, yHi: -0.05));
      }
    } else if (particles.length > target) {
      final toRemove = min(particles.length - target, 2);
      particles.removeRange(particles.length - toRemove, particles.length);
    }

    final stopY = rainStopY;
    for (var i = 0; i < particles.length; i++) {
      particles[i].y += particles[i].speed;
      if (particles[i].y > stopY || particles[i].y > 1.1) {
        particles[i] = _makeParticle(yLo: -0.2, yHi: -0.05);
      }
    }
  }

  void clear() {
    particles.clear();
  }

  double _randRange(double lo, double hi) =>
      lo + _random.nextDouble() * (hi - lo);
}
