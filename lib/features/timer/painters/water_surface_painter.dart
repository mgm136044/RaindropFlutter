import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the composite 3-wave water surface inside the bucket.
/// Matches BucketView.swift lines 108-167.
class WaterSurfacePainter extends CustomPainter {
  final double progress;
  final double waveOffset;
  final double intensity;
  final double tiltAngle;
  final Color gradientTop;
  final Color gradientBottom;
  final double phaseShift;
  final double layerOpacity;
  final bool isHighlight;
  final Path? clipPath;

  WaterSurfacePainter({
    required this.progress,
    required this.waveOffset,
    required this.intensity,
    required this.tiltAngle,
    required this.gradientTop,
    required this.gradientBottom,
    this.phaseShift = 0,
    this.layerOpacity = 1.0,
    this.isHighlight = false,
    this.clipPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress < 0.01 && !isHighlight) return;

    final width = size.width;
    final height = size.height;
    final waterTop = height - (height * 0.80 * clampedProgress);
    final hasWave = clampedProgress >= 0.05;
    final ic = intensity.clamp(0.0, 1.0);

    // Wave parameters
    final primaryAmp = hasWave ? (4.0 + ic * 4.0) : 0.0;
    final primaryWL = width / 1.5;
    final secondaryAmp = hasWave ? (1.5 + ic * 2.0) : 0.0;
    final secondaryWL = width / 3.0;
    final tertiaryAmp = hasWave ? (0.5 + ic * 1.0) : 0.0;
    final tertiaryWL = width / 8.0;

    // Tilt slosh
    final slopeFactor = (-tiltAngle / 8.0).clamp(-1.0, 1.0);
    final maxSlosh =
        height * 0.06 * min(clampedProgress + 0.2, 1.0);

    if (clipPath != null) {
      canvas.save();
      canvas.clipPath(clipPath!);
    }

    if (isHighlight) {
      // Surface highlight line
      if (clampedProgress <= 0.05) {
        if (clipPath != null) canvas.restore();
        return;
      }
      final path = Path();
      var started = false;
      for (double x = 0; x <= width; x += 2) {
        final primary =
            sin(((x / primaryWL) + waveOffset) * 2 * pi) * primaryAmp;
        final secondary =
            sin(((x / secondaryWL) + waveOffset * 1.3) * 2 * pi) *
                secondaryAmp;
        final normalizedX = (x / width) - 0.5;
        final slosh = normalizedX * slopeFactor * maxSlosh * 2;
        final y = waterTop + primary + secondary + slosh - 1;

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else {
      // Filled water shape
      final path = Path();
      path.moveTo(0, waterTop);

      for (double x = 0; x <= width; x += 2) {
        final primary =
            sin(((x / primaryWL) + waveOffset + phaseShift) * 2 * pi) *
                primaryAmp;
        final secondary =
            sin(((x / secondaryWL) + waveOffset * 1.3 + phaseShift) *
                    2 *
                    pi) *
                secondaryAmp;
        final tertiary =
            sin(((x / tertiaryWL) + waveOffset * 2.1) * 2 * pi) *
                tertiaryAmp;
        final normalizedX = (x / width) - 0.5;
        final slosh = normalizedX * slopeFactor * maxSlosh * 2;

        final y = waterTop + primary + secondary + tertiary + slosh;
        path.lineTo(x, y);
      }

      path.lineTo(width, height);
      path.lineTo(0, height);
      path.close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientTop.withValues(alpha: gradientTop.a * layerOpacity),
          gradientBottom.withValues(alpha: gradientBottom.a * layerOpacity),
        ],
      );

      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, waterTop, width, height - waterTop),
          ),
      );
    }

    if (clipPath != null) canvas.restore();
  }

  @override
  bool shouldRepaint(WaterSurfacePainter oldDelegate) {
    return progress != oldDelegate.progress ||
        waveOffset != oldDelegate.waveOffset ||
        intensity != oldDelegate.intensity ||
        tiltAngle != oldDelegate.tiltAngle;
  }
}

/// Generates the bucket-shaped clip path (scaled to 0.86) used for water masking.
Path bucketClipPath(Size size, {double scale = 0.86}) {
  final offsetX = size.width * (1 - scale) / 2;
  final offsetY = size.height * (1 - scale) / 2;
  final w = size.width * scale;
  final h = size.height * scale;

  final topY = h * 0.06;
  final bottomY = h;
  final topInset = w * 0.14;
  final bottomInset = w * 0.08;
  final cornerRadius = w * 0.06;
  final bulgeFactor = w * 0.025;
  final midY = (topY + bottomY) / 2;

  final path = Path();
  path.moveTo(offsetX + topInset, offsetY + topY);
  path.lineTo(offsetX + w - topInset, offsetY + topY);

  path.cubicTo(
    offsetX + w - topInset + bulgeFactor,
    offsetY + topY + (bottomY - topY) * 0.33,
    offsetX + w - bottomInset + bulgeFactor * 0.5,
    offsetY + midY + (bottomY - topY) * 0.2,
    offsetX + w - bottomInset - cornerRadius,
    offsetY + bottomY - cornerRadius,
  );

  path.quadraticBezierTo(
    offsetX + w - bottomInset,
    offsetY + bottomY,
    offsetX + w - bottomInset - cornerRadius * 1.5,
    offsetY + bottomY,
  );

  path.quadraticBezierTo(
    offsetX + w / 2,
    offsetY + bottomY + h * 0.025,
    offsetX + bottomInset + cornerRadius * 1.5,
    offsetY + bottomY,
  );

  path.quadraticBezierTo(
    offsetX + bottomInset,
    offsetY + bottomY,
    offsetX + bottomInset + cornerRadius,
    offsetY + bottomY - cornerRadius,
  );

  path.cubicTo(
    offsetX + bottomInset - bulgeFactor * 0.5,
    offsetY + midY + (bottomY - topY) * 0.2,
    offsetX + topInset - bulgeFactor,
    offsetY + topY + (bottomY - topY) * 0.33,
    offsetX + topInset,
    offsetY + topY,
  );

  path.close();
  return path;
}
