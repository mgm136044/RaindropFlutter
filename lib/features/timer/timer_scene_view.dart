import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/models/shop_state.dart';
import 'package:raindrop_flutter/features/timer/cloud_view.dart';
import 'package:raindrop_flutter/features/timer/painters/bucket_painter.dart';
import 'package:raindrop_flutter/features/timer/painters/overflow_painter.dart';
import 'package:raindrop_flutter/features/timer/painters/rain_particle_painter.dart';
import 'package:raindrop_flutter/features/timer/painters/water_splash_painter.dart';
import 'package:raindrop_flutter/features/timer/painters/water_surface_painter.dart';
import 'package:raindrop_flutter/features/timer/sticker_placement_view.dart';
import 'package:raindrop_flutter/features/timer/timer_view_model.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// Composes: Cloud+Rain, BucketWithStickers, Overflow, Splash.
/// Sizes: rain 260x360, bucket 340x320, padded top 56.
/// Matches TimerSceneView.swift layout.
class TimerSceneView extends StatefulWidget {
  final TimerViewModel viewModel;
  final BucketSkin skin;
  final bool useCustomWaterColor;
  final Color dropGradientTop;
  final Color dropGradientBottom;
  final List<StickerPlacement> placements;
  final Color? waterColorOverrideTop;
  final Color? waterColorOverrideBottom;

  const TimerSceneView({
    super.key,
    required this.viewModel,
    required this.skin,
    required this.useCustomWaterColor,
    required this.dropGradientTop,
    required this.dropGradientBottom,
    this.placements = const [],
    this.waterColorOverrideTop,
    this.waterColorOverrideBottom,
  });

  @override
  State<TimerSceneView> createState() => _TimerSceneViewState();
}

class _TimerSceneViewState extends State<TimerSceneView>
    with TickerProviderStateMixin {
  // Wave animation
  late AnimationController _waveController;

  // 30fps ticker for particle systems
  Ticker? _particleTicker;
  Duration _lastTickTime = Duration.zero;

  // Particle systems
  final RainParticleSystem _rainSystem = RainParticleSystem();
  final WaterSplashSystem _splashSystem = WaterSplashSystem();
  final OverflowSparkleSystem _overflowSystem = OverflowSparkleSystem();

  double _displayProgress = 0;
  bool _wasDraining = false;
  bool _wasCycleDraining = false;
  bool _wasOverflowing = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _particleTicker = createTicker(_onTick);
    _particleTicker!.start();

    _displayProgress = widget.viewModel.currentProgress;
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onTick(Duration elapsed) {
    // Target ~30fps
    if (elapsed - _lastTickTime < const Duration(milliseconds: 33)) return;
    _lastTickTime = elapsed;

    final vm = widget.viewModel;
    _rainSystem.intensity = vm.isRunning ? vm.currentProgress : 0;
    _rainSystem.waterLevel = _displayProgress;
    _splashSystem.intensity = vm.isRunning ? vm.currentProgress : 0;

    if (vm.isRunning && _rainSystem.particles.isEmpty) {
      _rainSystem.initialize();
    } else if (!vm.isRunning && _rainSystem.particles.isNotEmpty) {
      _rainSystem.clear();
    }

    if (vm.isRunning) {
      _rainSystem.update();
    }

    _splashSystem.update(
      isActive: vm.isRunning && _displayProgress > 0.05,
      waterLevel: _displayProgress,
    );

    _overflowSystem.update();

    setState(() {});
  }

  void _onViewModelChanged() {
    final vm = widget.viewModel;

    // Normal progress update
    if (!vm.isDraining && !vm.isCycleDraining) {
      _displayProgress = vm.currentProgress;
    }

    // Draining animation
    if (vm.isDraining && !_wasDraining) {
      _wasDraining = true;
      _animateDrain(() {
        vm.finishDraining();
        _wasDraining = false;
      });
    } else if (!vm.isDraining) {
      _wasDraining = false;
    }

    // Cycle draining animation
    if (vm.isCycleDraining && !_wasCycleDraining) {
      _wasCycleDraining = true;
      _displayProgress = 1.0;
      _animateDrain(() {
        vm.finishCycleDraining();
        _wasCycleDraining = false;
      });
    } else if (!vm.isCycleDraining) {
      _wasCycleDraining = false;
    }

    // Overflow sparkles
    if (vm.isOverflowing && !_wasOverflowing) {
      _overflowSystem.spawnBurst();
    }
    _wasOverflowing = vm.isOverflowing;
  }

  void _animateDrain(VoidCallback onComplete) {
    const drainDuration = Duration(milliseconds: 1200);
    final startProgress = _displayProgress;
    final startTime = DateTime.now();

    void tick() {
      if (!mounted) return;
      final elapsed =
          DateTime.now().difference(startTime).inMilliseconds;
      final t = (elapsed / drainDuration.inMilliseconds).clamp(0.0, 1.0);
      final curved = t * t;
      setState(() {
        _displayProgress = startProgress * (1 - curved);
      });
      if (t < 1.0) {
        Future.delayed(const Duration(milliseconds: 16), tick);
      } else {
        if (mounted) onComplete();
      }
    }

    tick();
  }

  Color get _waterGradientTop {
    if (widget.waterColorOverrideTop != null) {
      return widget.waterColorOverrideTop!;
    }
    if (widget.useCustomWaterColor && widget.skin.hasCustomWaterColor) {
      return widget.skin.customWaterGradientTop;
    }
    return AppColors.waterGradientTopColor;
  }

  Color get _waterGradientBottom {
    if (widget.waterColorOverrideBottom != null) {
      return widget.waterColorOverrideBottom!;
    }
    if (widget.useCustomWaterColor && widget.skin.hasCustomWaterColor) {
      return widget.skin.customWaterGradientBottom;
    }
    return AppColors.waterGradientBottomColor;
  }

  double get _intensity =>
      widget.viewModel.isRunning ? widget.viewModel.currentProgress : 0;

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _waveController.dispose();
    _particleTicker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final waveOffset = _waveController.value;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Cloud + Rain layer
        SizedBox(
          width: 340,
          height: 360,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: -50,
                child: CloudView(
                  isVisible: vm.isRunning,
                  intensity: _intensity,
                ),
              ),
              // Rain particles
              SizedBox(
                width: 260,
                height: 360,
                child: CustomPaint(
                  painter: RainParticlePainter(
                    particles: _rainSystem.particles,
                    dropGradientTop: widget.dropGradientTop,
                    dropGradientBottom: widget.dropGradientBottom,
                    waterLevel: _displayProgress,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bucket + Water + Stickers
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: StickerPlacementView(
            progress: _displayProgress,
            placements: widget.placements,
            child: SizedBox(
              width: 340,
              height: 320,
              child: CustomPaint(
                painter: BucketPainter(
                  progress: _displayProgress,
                  fillColor: widget.skin.bucketFill,
                  strokeColor: widget.skin.bucketStroke,
                  handleColor: widget.skin.bucketHandle,
                  bandColor: widget.skin.bandColor,
                ),
                foregroundPainter: _BucketWaterForegroundPainter(
                  progress: _displayProgress,
                  waveOffset: waveOffset,
                  intensity: _intensity,
                  tiltAngle: 0,
                  waterGradientTop: _waterGradientTop,
                  waterGradientBottom: _waterGradientBottom,
                ),
              ),
            ),
          ),
        ),

        // Overflow celebration
        if (vm.isOverflowing)
          Padding(
            padding: const EdgeInsets.only(top: 56),
            child: SizedBox(
              width: 340,
              height: 320,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: vm.isOverflowing ? 1.0 : 0.0,
                child: CustomPaint(
                  painter: OverflowPainter(
                    sparkles: _overflowSystem.sparkles,
                  ),
                ),
              ),
            ),
          ),

        // Water splash
        if (vm.isRunning && _displayProgress > 0.05)
          Padding(
            padding: const EdgeInsets.only(top: 56),
            child: SizedBox(
              width: 340,
              height: 320,
              child: CustomPaint(
                painter: WaterSplashPainter(
                  splashes: _splashSystem.splashes,
                  waterLevel: _displayProgress,
                  splashColor: widget.dropGradientTop,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Combined foreground painter for water layers inside bucket.
class _BucketWaterForegroundPainter extends CustomPainter {
  final double progress;
  final double waveOffset;
  final double intensity;
  final double tiltAngle;
  final Color waterGradientTop;
  final Color waterGradientBottom;

  _BucketWaterForegroundPainter({
    required this.progress,
    required this.waveOffset,
    required this.intensity,
    required this.tiltAngle,
    required this.waterGradientTop,
    required this.waterGradientBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.01) return;

    final clip = bucketClipPath(size, scale: 0.86);

    // Back layer (phaseShift 0.3, opacity 0.45)
    WaterSurfacePainter(
      progress: progress,
      waveOffset: waveOffset + 0.3,
      intensity: intensity,
      tiltAngle: tiltAngle,
      gradientTop: waterGradientTop,
      gradientBottom: waterGradientBottom,
      phaseShift: 0.3,
      layerOpacity: 0.45,
      clipPath: clip,
    ).paint(canvas, size);

    // Front layer (no shift, full opacity)
    WaterSurfacePainter(
      progress: progress,
      waveOffset: waveOffset,
      intensity: intensity,
      tiltAngle: tiltAngle,
      gradientTop: waterGradientTop,
      gradientBottom: waterGradientBottom,
      clipPath: clip,
    ).paint(canvas, size);

    // Surface highlight
    if (progress > 0.05) {
      WaterSurfacePainter(
        progress: progress,
        waveOffset: waveOffset,
        intensity: intensity,
        tiltAngle: tiltAngle,
        gradientTop: waterGradientTop,
        gradientBottom: waterGradientBottom,
        isHighlight: true,
        clipPath: clip,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(_BucketWaterForegroundPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        waveOffset != oldDelegate.waveOffset ||
        intensity != oldDelegate.intensity;
  }
}
