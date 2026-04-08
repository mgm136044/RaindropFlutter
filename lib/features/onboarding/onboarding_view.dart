import 'package:flutter/material.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/models/environment_level.dart';
import 'package:raindrop_flutter/features/timer/painters/bucket_painter.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class OnboardingView extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingView({super.key, required this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentScene = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520,
      height: 450,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundGradientTop(context),
            AppColors.backgroundGradientBottom(context),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Scene indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentScene >= index
                      ? AppColors.accent(context)
                      : AppColors.secondaryText(context).withValues(alpha: 0.3),
                ),
              );
            }),
          ),
          // Scene content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: switch (_currentScene) {
                0 => _OnboardingBucketScene(
                    key: const ValueKey(0),
                    onNext: () => setState(() => _currentScene = 1),
                  ),
                1 => _OnboardingFillScene(
                    key: const ValueKey(1),
                    onNext: () => setState(() => _currentScene = 2),
                  ),
                2 => _OnboardingGrowthScene(
                    key: const ValueKey(2),
                    onComplete: widget.onComplete,
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Scene 1: Bucket appears, raindrop falls, water rises
// =============================================================================

class _OnboardingBucketScene extends StatefulWidget {
  final VoidCallback onNext;

  const _OnboardingBucketScene({super.key, required this.onNext});

  @override
  State<_OnboardingBucketScene> createState() => _OnboardingBucketSceneState();
}

class _OnboardingBucketSceneState extends State<_OnboardingBucketScene>
    with TickerProviderStateMixin {
  int _phase = 0;
  double _bucketProgress = 0;
  double _dropY = -0.3;
  bool _showText = false;
  double _wobbleAngle = 0;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _phase = 1);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _phase = 2;
      _dropY = 0.3;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _phase = 3;
      _bucketProgress = 0.35;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _showText = true);
  }

  void _wobble() {
    setState(() => _wobbleAngle = 6);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _wobbleAngle = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // Bucket + raindrop
        GestureDetector(
          onTap: _wobble,
          child: SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _phase >= 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedRotation(
                    turns: _wobbleAngle / 360,
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 160,
                      height: 150,
                      child: CustomPaint(
                        painter: BucketPainter(
                          progress: _bucketProgress,
                          fillColor: BucketSkin.wood.bucketFill,
                          strokeColor: BucketSkin.wood.bucketStroke,
                          handleColor: BucketSkin.wood.bucketHandle,
                          bandColor: BucketSkin.wood.bandColor,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_phase == 2)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeIn,
                    top: 100 + _dropY * 200,
                    child: Container(
                      width: 8,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.dropGradientTopColor,
                            AppColors.dropGradientBottomColor,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Bottom text + button
        AnimatedOpacity(
          opacity: _showText ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: _showText
              ? Column(
                  children: [
                    Text(
                      '이것이 당신의 하루입니다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent(context),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('다음'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// =============================================================================
// Scene 2: "집중 시작" → bucket fills → coin earned
// =============================================================================

class _OnboardingFillScene extends StatefulWidget {
  final VoidCallback onNext;

  const _OnboardingFillScene({super.key, required this.onNext});

  @override
  State<_OnboardingFillScene> createState() => _OnboardingFillSceneState();
}

class _OnboardingFillSceneState extends State<_OnboardingFillScene> {
  bool _isRunning = false;
  double _progress = 0;
  bool _showCoin = false;
  bool _showText = false;
  double _wobbleAngle = 0;

  void _startFilling() {
    setState(() => _isRunning = true);

    // Animate progress over ~3 seconds
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _progress = 1.0);
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _showCoin = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  void _wobble() {
    setState(() => _wobbleAngle = 6);
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _wobbleAngle = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        GestureDetector(
          onTap: _wobble,
          child: SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rain effect placeholder when running
                if (_isRunning) ...[
                  Positioned(
                    top: 0,
                    child: Icon(
                      Icons.cloud,
                      size: 60,
                      color: AppColors.cloudColor(context).withValues(alpha: 0.5),
                    ),
                  ),
                  // Simple rain drops
                  ...List.generate(6, (i) {
                    return Positioned(
                      top: 40.0 + i * 20,
                      left: 60.0 + i * 15,
                      child: Container(
                        width: 2,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: AppColors.dropGradientBottomColor
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }),
                ],
                AnimatedRotation(
                  turns: _wobbleAngle / 360,
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 160,
                    height: 150,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 3000),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) {
                        return CustomPaint(
                          painter: BucketPainter(
                            progress: value,
                            fillColor: BucketSkin.wood.bucketFill,
                            strokeColor: BucketSkin.wood.bucketStroke,
                            handleColor: BucketSkin.wood.bucketHandle,
                            bandColor: BucketSkin.wood.bandColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Coin animation
                if (_showCoin)
                  Positioned(
                    top: 10,
                    child: AnimatedOpacity(
                      opacity: _showCoin ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        '\u{1FAA3} +1',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent(context),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Bottom UI
        if (!_isRunning && !_showText && _progress == 0)
          ElevatedButton(
            onPressed: _startFilling,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent(context),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              '집중 시작',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        if (_showText)
          Column(
            children: [
              Text(
                '집중이 쌓이면 양동이가 채워집니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText(context),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent(context),
                  foregroundColor: Colors.white,
                ),
                child: const Text('다음'),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// =============================================================================
// Scene 3: Environment evolution emoji parade
// =============================================================================

class _OnboardingGrowthScene extends StatefulWidget {
  final VoidCallback onComplete;

  const _OnboardingGrowthScene({super.key, required this.onComplete});

  @override
  State<_OnboardingGrowthScene> createState() =>
      _OnboardingGrowthSceneState();
}

class _OnboardingGrowthSceneState extends State<_OnboardingGrowthScene> {
  static const _stages = EnvironmentStage.values;
  EnvironmentStage _currentStage = EnvironmentStage.barren;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _animateStages();
  }

  Future<void> _animateStages() async {
    for (var i = 0; i < _stages.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 500 : 800));
      if (!mounted) return;
      setState(() => _currentStage = _stages[i]);
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _showText = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        // Stage indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _stages.map((stage) {
            final isActive = stage.value <= _currentStage.value;
            final isCurrent = stage == _currentStage;
            return AnimatedScale(
              scale: isCurrent ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    stage.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Environment evolution display
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(_currentStage),
            width: 300,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surface(context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStage.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentStage.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentStage.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Bottom text + button
        AnimatedOpacity(
          opacity: _showText ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: _showText
              ? Column(
                  children: [
                    Text(
                      '매일의 집중이 당신만의 세계를 만듭니다',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: widget.onComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent(context),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('시작하기'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
