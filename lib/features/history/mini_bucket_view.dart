import 'package:flutter/material.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// A small static bucket widget (~40x40) used in weekly density view.
/// Shows fill level and wobbles on tap if tappable.
class MiniBucketView extends StatefulWidget {
  final double fillRatio;
  final BucketSkin skin;
  final bool tappable;

  const MiniBucketView({
    super.key,
    required this.fillRatio,
    required this.skin,
    this.tappable = false,
  });

  @override
  State<MiniBucketView> createState() => _MiniBucketViewState();
}

class _MiniBucketViewState extends State<MiniBucketView>
    with SingleTickerProviderStateMixin {
  double _wobbleAngle = 0;

  void _onTap() {
    if (!widget.tappable) return;
    setState(() => _wobbleAngle = 6);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _wobbleAngle = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedRotation(
        turns: _wobbleAngle / 360,
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.bottomCenter,
        child: CustomPaint(
          painter: _MiniBucketPainter(
            fillRatio: widget.fillRatio,
            skin: widget.skin,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Simplified bucket painter for mini view: bucket outline + water fill.
class _MiniBucketPainter extends CustomPainter {
  final double fillRatio;
  final BucketSkin skin;

  _MiniBucketPainter({required this.fillRatio, required this.skin});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Simple trapezoid bucket shape
    final topInset = w * 0.14;
    final bottomInset = w * 0.08;
    final topY = h * 0.06;
    final bottomY = h * 0.94;

    final bucketPath = Path()
      ..moveTo(topInset, topY)
      ..lineTo(w - topInset, topY)
      ..lineTo(w - bottomInset, bottomY)
      ..lineTo(bottomInset, bottomY)
      ..close();

    // Fill background
    canvas.drawPath(
      bucketPath,
      Paint()..color = skin.bucketFill.withValues(alpha: 0.5),
    );

    // Water fill
    if (fillRatio > 0) {
      final waterTop = bottomY - (bottomY - topY) * fillRatio * 0.86;
      final waterInsetTop =
          topInset + (bottomInset - topInset) * (1 - fillRatio * 0.86);
      final waterPath = Path()
        ..moveTo(waterInsetTop, waterTop)
        ..lineTo(w - waterInsetTop, waterTop)
        ..lineTo(w - bottomInset, bottomY)
        ..lineTo(bottomInset, bottomY)
        ..close();

      canvas.save();
      canvas.clipPath(bucketPath);
      canvas.drawPath(
        waterPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.waterGradientTopColor.withValues(alpha: 0.7),
              AppColors.waterGradientBottomColor.withValues(alpha: 0.9),
            ],
          ).createShader(Rect.fromLTWH(0, waterTop, w, bottomY - waterTop)),
      );
      canvas.restore();
    }

    // Bucket stroke
    canvas.drawPath(
      bucketPath,
      Paint()
        ..color = skin.bucketStroke.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_MiniBucketPainter oldDelegate) =>
      fillRatio != oldDelegate.fillRatio || skin != oldDelegate.skin;
}
