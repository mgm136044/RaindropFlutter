import 'package:flutter/material.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// Widget-based cloud layer with 3-5 AnimatedContainers using RadialGradient.
/// 8-second horizontal drift. Matches CloudView.swift.
class CloudView extends StatefulWidget {
  final bool isVisible;
  final double intensity;

  const CloudView({
    super.key,
    required this.isVisible,
    this.intensity = 0.5,
  });

  @override
  State<CloudView> createState() => _CloudViewState();
}

class _CloudViewState extends State<CloudView>
    with SingleTickerProviderStateMixin {
  double _cloudOffset = 0;
  double _cloudOpacity = 0;

  double get _baseOpacity => 0.3 + widget.intensity.clamp(0.0, 1.0) * 0.5;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _cloudOpacity = 1.0;
      _startDrift();
    }
  }

  @override
  void didUpdateWidget(CloudView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      setState(() {
        if (widget.isVisible) {
          _cloudOpacity = 1.0;
          _startDrift();
        } else {
          _cloudOpacity = 0;
          _cloudOffset = 0;
        }
      });
    }
  }

  void _startDrift() {
    // Toggle offset to trigger AnimatedContainer drift
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && widget.isVisible) {
        setState(() => _cloudOffset = 10);
      }
    });
  }

  Widget _buildCloud({
    required double width,
    required double height,
    required double opacity40,
    required double opacity12,
    required double offsetX,
    required double offsetY,
    required double driftFactor,
    required Color cloudColor,
  }) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 8),
      curve: Curves.easeInOut,
      left: (260 - width) / 2 + offsetX + _cloudOffset * driftFactor,
      top: (70 - height) / 2 + offsetY,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.elliptical(width / 2, height / 2),
          ),
          gradient: RadialGradient(
            colors: [
              cloudColor.withValues(alpha: opacity40),
              cloudColor.withValues(alpha: opacity12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cloudColor = AppColors.cloudColor(context);
    final showExtra = widget.intensity > 0.5;
    final extraOpacity =
        ((widget.intensity - 0.5) * 2).clamp(0.0, 1.0);

    return AnimatedOpacity(
      duration: Duration(milliseconds: widget.isVisible ? 1500 : 1000),
      opacity: _cloudOpacity * _baseOpacity,
      child: SizedBox(
        width: 260,
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main cloud
            _buildCloud(
              width: 200,
              height: 50,
              opacity40: 0.40,
              opacity12: 0.12,
              offsetX: 0,
              offsetY: 0,
              driftFactor: 1.0,
              cloudColor: cloudColor,
            ),
            // Left cloud
            _buildCloud(
              width: 120,
              height: 35,
              opacity40: 0.30,
              opacity12: 0.08,
              offsetX: -60,
              offsetY: 5,
              driftFactor: 0.7,
              cloudColor: cloudColor,
            ),
            // Right cloud
            _buildCloud(
              width: 100,
              height: 30,
              opacity40: 0.25,
              opacity12: 0.06,
              offsetX: 50,
              offsetY: 3,
              driftFactor: 0.5,
              cloudColor: cloudColor,
            ),
            // Extra clouds at high intensity
            if (showExtra) ...[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: extraOpacity,
                child: _buildCloudWidget(
                  width: 90,
                  height: 28,
                  opacity40: 0.20,
                  opacity12: 0.05,
                  offsetX: -100 + _cloudOffset * 0.4,
                  offsetY: -8,
                  cloudColor: cloudColor,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: extraOpacity,
                child: _buildCloudWidget(
                  width: 80,
                  height: 25,
                  opacity40: 0.18,
                  opacity12: 0.04,
                  offsetX: 100 + _cloudOffset * 0.3,
                  offsetY: -5,
                  cloudColor: cloudColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloudWidget({
    required double width,
    required double height,
    required double opacity40,
    required double opacity12,
    required double offsetX,
    required double offsetY,
    required Color cloudColor,
  }) {
    return Positioned(
      left: (260 - width) / 2 + offsetX,
      top: (70 - height) / 2 + offsetY,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(
            Radius.elliptical(width / 2, height / 2),
          ),
          gradient: RadialGradient(
            colors: [
              cloudColor.withValues(alpha: opacity40),
              cloudColor.withValues(alpha: opacity12),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}
