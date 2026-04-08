import 'dart:math';
import 'package:flutter/material.dart';

/// CustomPainter that draws the bucket body, metal bands, rim, and handle.
/// Bezier control points match BucketView.swift lines 218-319 exactly.
class BucketPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color strokeColor;
  final Color handleColor;
  final Color bandColor;

  BucketPainter({
    required this.progress,
    required this.fillColor,
    required this.strokeColor,
    required this.handleColor,
    required this.bandColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw bucket fill
    canvas.drawPath(_bucketPath(size), Paint()..color = fillColor);

    // Draw bucket outline
    canvas.drawPath(
      _bucketPath(size),
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Metal bands at 30% and 70%
    _drawBand(canvas, size, 0.30);
    _drawBand(canvas, size, 0.70);

    // Rim
    _drawRim(canvas, size);

    // Handle
    _drawHandle(canvas, size);
  }

  /// Bucket body path — trapezoidal barrel with bulgeFactor curves.
  Path _bucketPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    final topY = height * 0.06;
    final bottomY = height.toDouble();
    final topInset = width * 0.14;
    final bottomInset = width * 0.08;
    final cornerRadius = width * 0.06;
    final bulgeFactor = width * 0.025;
    final midY = (topY + bottomY) / 2;

    final topLeft = Offset(topInset, topY);
    final topRight = Offset(width - topInset, topY);
    final bottomRight = Offset(width - bottomInset, bottomY);
    final bottomLeft = Offset(bottomInset, bottomY);

    path.moveTo(topLeft.dx, topLeft.dy);
    path.lineTo(topRight.dx, topRight.dy);

    // Right side curve (top-right to bottom-right corner)
    path.cubicTo(
      topRight.dx + bulgeFactor,
      topY + (bottomY - topY) * 0.33,
      bottomRight.dx + bulgeFactor * 0.5,
      midY + (bottomY - topY) * 0.2,
      bottomRight.dx - cornerRadius,
      bottomY - cornerRadius,
    );

    // Bottom-right corner
    path.quadraticBezierTo(
      bottomRight.dx,
      bottomRight.dy,
      bottomRight.dx - cornerRadius * 1.5,
      bottomY,
    );

    // Bottom curve
    path.quadraticBezierTo(
      width / 2,
      bottomY + height * 0.025,
      bottomLeft.dx + cornerRadius * 1.5,
      bottomY,
    );

    // Bottom-left corner
    path.quadraticBezierTo(
      bottomLeft.dx,
      bottomLeft.dy,
      bottomLeft.dx + cornerRadius,
      bottomY - cornerRadius,
    );

    // Left side curve (bottom-left back to top-left)
    path.cubicTo(
      bottomLeft.dx - bulgeFactor * 0.5,
      midY + (bottomY - topY) * 0.2,
      topLeft.dx - bulgeFactor,
      topY + (bottomY - topY) * 0.33,
      topLeft.dx,
      topLeft.dy,
    );

    path.close();
    return path;
  }

  /// Metal band at a given vertical fraction.
  void _drawBand(Canvas canvas, Size size, double verticalFraction) {
    final width = size.width;
    final height = size.height;

    final topY = height * 0.06;
    final bottomY = height.toDouble();
    final y = topY + (bottomY - topY) * verticalFraction;

    final topInset = width * 0.14;
    final bottomInset = width * 0.08;
    final xInset = topInset + (bottomInset - topInset) * verticalFraction;
    final bandInset = width * 0.02;

    final path = Path();
    path.moveTo(xInset + bandInset, y);
    path.quadraticBezierTo(
      width / 2,
      y + 2,
      width - xInset - bandInset,
      y,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = bandColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  /// Bucket rim — horizontal line extending past edges.
  void _drawRim(Canvas canvas, Size size) {
    final topY = size.height * 0.06;
    final topInset = size.width * 0.14;
    const rimExtend = 6.0;

    final path = Path();
    path.moveTo(topInset - rimExtend, topY);
    path.lineTo(size.width - topInset + rimExtend, topY);

    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Bucket handle — arc from 195 deg to -15 deg.
  void _drawHandle(Canvas canvas, Size size) {
    final handleWidth = size.width * 0.52;
    final handleHeight = size.height * 0.32;
    final centerX = size.width / 2;
    final centerY = -size.height * 0.30 + size.height * 0.06;

    final path = Path();
    path.addArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY + handleHeight),
        width: handleWidth,
        height: handleHeight * 2,
      ),
      _degToRad(195),
      _degToRad(-15) - _degToRad(195) < 0
          ? (2 * pi + _degToRad(-15) - _degToRad(195))
          : (_degToRad(-15) - _degToRad(195)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = handleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  double _degToRad(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(BucketPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fillColor != oldDelegate.fillColor ||
        strokeColor != oldDelegate.strokeColor;
  }
}
