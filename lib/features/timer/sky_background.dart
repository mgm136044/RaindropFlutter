import 'package:flutter/material.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// Dynamic sky background with 4 states (dawn/gathering/storm/clearing)
/// that transitions based on timer progress. Matches SkyBackgroundView.swift.
class SkyBackground extends StatelessWidget {
  final double progress;
  final bool isRunning;
  final bool isOverflowing;

  const SkyBackground({
    super.key,
    required this.progress,
    required this.isRunning,
    required this.isOverflowing,
  });

  Color _skyTop(BuildContext context) {
    if (isOverflowing) return AppColors.skyClearingTop(context);
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.2) {
      return Color.lerp(AppColors.skyDawnTop(context),
          AppColors.skyGatheringTop(context), p / 0.2)!;
    } else if (p < 0.5) {
      return Color.lerp(AppColors.skyGatheringTop(context),
          AppColors.skyStormTop(context), (p - 0.2) / 0.3)!;
    } else {
      return AppColors.skyStormTop(context);
    }
  }

  Color _skyBottom(BuildContext context) {
    if (isOverflowing) return AppColors.skyClearingBottom(context);
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.2) {
      return Color.lerp(AppColors.skyDawnBottom(context),
          AppColors.skyGatheringBottom(context), p / 0.2)!;
    } else if (p < 0.5) {
      return Color.lerp(AppColors.skyGatheringBottom(context),
          AppColors.skyStormBottom(context), (p - 0.2) / 0.3)!;
    } else {
      return AppColors.skyStormBottom(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topColor = isRunning
        ? _skyTop(context)
        : AppColors.backgroundGradientTop(context);
    final bottomColor = isRunning
        ? _skyBottom(context)
        : AppColors.backgroundGradientBottom(context);

    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [topColor, bottomColor],
        ),
      ),
    );
  }
}
