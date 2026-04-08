import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/utils/app_constants.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';
import 'package:raindrop_flutter/features/timer/sky_background.dart';
import 'package:raindrop_flutter/features/timer/timer_controls.dart';
import 'package:raindrop_flutter/features/timer/timer_scene_view.dart';
import 'package:raindrop_flutter/features/timer/timer_view_model.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// Main timer screen -- Stack layout with 6 layers matching SwiftUI ZStack.
/// Korean UI strings throughout.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _motivationIndex = 0;
  Timer? _messageTimer;

  static const _runningMessages = [
    '물방울이 떨어지는 중',
    '좋아요, 집중하고 있어요!',
    '지금 이 순간에 몰입하세요',
    '양동이가 차오르고 있어요',
    '한 방울 한 방울 쌓이는 중',
    '멋져요, 계속 이대로!',
    '집중의 흐름을 유지하세요',
    '당신의 노력이 물이 됩니다',
  ];

  static const _idleMessages = [
    '숨 고르고 다시 시작',
    '준비되면 집중을 시작하세요',
    '오늘도 양동이를 채워볼까요?',
    '한 방울의 시작이 큰 변화를 만들어요',
  ];

  @override
  void initState() {
    super.initState();
    _messageTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _pickRandomMessage();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  void _pickRandomMessage() {
    final vm = context.read<TimerViewModel>();
    final count =
        vm.isRunning ? _runningMessages.length : _idleMessages.length;
    var next = Random().nextInt(count);
    if (next == _motivationIndex % count && count > 1) {
      next = (next + 1) % count;
    }
    setState(() => _motivationIndex = next);
  }

  String _currentMotivationMessage(TimerViewModel vm) {
    if (vm.isRunning) {
      return _runningMessages[_motivationIndex % _runningMessages.length];
    }
    return _idleMessages[_motivationIndex % _idleMessages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, vm, _) {
        return Stack(
          children: [
            // Layer 0: Dynamic sky background
            Positioned.fill(
              child: SkyBackground(
                progress: vm.currentProgress,
                isRunning: vm.isRunning,
                isOverflowing: vm.isOverflowing,
              ),
            ),

            // Layer 1: Scene (cloud + rain + bucket)
            Center(
              child: TimerSceneView(
                viewModel: vm,
                skin: BucketSkin.wood,
                useCustomWaterColor: false,
                dropGradientTop: AppColors.dropGradientTop(context),
                dropGradientBottom: AppColors.dropGradientBottom(context),
              ),
            ),

            // Layer 2: Header overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildHeader(context, vm),
            ),

            // Layer 3: Motivation text
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _currentMotivationMessage(vm),
                  key: ValueKey(_motivationIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ),
            ),

            // Layer 4: Bottom controls + info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimerInfoCapsule(context, vm),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: vm.isRunning ? 0.7 : 1.0,
                    child: TimerControls(
                      canStart: vm.canStart,
                      canPause: vm.canPause,
                      canResume: vm.canResume,
                      canStop: vm.canStop,
                      onStart: () {
                        vm.resetCompletionStateIfNeeded();
                        vm.start();
                        _pickRandomMessage();
                      },
                      onPause: vm.pause,
                      onResume: vm.resume,
                      onStop: vm.stop,
                      isCompact: vm.isRunning,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Layer 5: Error & completion banner
            if (vm.latestError != null || vm.lastCompletedSession != null)
              Positioned(
                bottom: 0,
                left: 32,
                right: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (vm.latestError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          vm.latestError!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.danger(context),
                          ),
                        ),
                      ),
                    if (vm.lastCompletedSession != null)
                      _buildCompletionBanner(context, vm),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TimerViewModel vm) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RainDrop',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleText(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText(context)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _headerIconButton(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      onPressed: () {
                        // TODO: Shop sheet
                      },
                    ),
                    const SizedBox(width: 8),
                    _headerIconButton(
                      context,
                      icon: Icons.settings_outlined,
                      onPressed: () {
                        // TODO: Settings sheet
                      },
                    ),
                    const SizedBox(width: 8),
                    _headerIconButton(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: '히스토리',
                      onPressed: () {
                        // TODO: History sheet
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton(
    BuildContext context, {
    required IconData icon,
    String? label,
    required VoidCallback onPressed,
  }) {
    return GlassContainer(
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryText(context)),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerInfoCapsule(BuildContext context, TimerViewModel vm) {
    return GlassContainer(
      borderRadius: 28,
      backgroundColor: vm.isRunning ? Colors.transparent : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.timerText,
                style: TextStyle(
                  fontSize: vm.isRunning ? 32 : 44,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: AppColors.primaryText(context),
                ),
              ),
              if (vm.cycleText != null) ...[
                const SizedBox(width: 8),
                Text(
                  vm.cycleText!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.goalText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiaryText(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '\u00B7',
                  style: TextStyle(
                    color: AppColors.tertiaryText(context),
                  ),
                ),
              ),
              Text(
                '오늘 ${vm.todayTotalText}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tertiaryText(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBanner(BuildContext context, TimerViewModel vm) {
    final session = vm.lastCompletedSession!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '세션 저장 완료',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.bannerTitle(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (vm.isInfinityMode && vm.lastCycleCount > 0)
                        Text(
                          '+${vm.lastCycleCount}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent(context),
                          ),
                        )
                      else if (!vm.isInfinityMode &&
                          session.durationSeconds >= vm.sessionGoalSeconds)
                        Text(
                          '+1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent(context),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '이번 집중 시간 ${TimeFormatter.clockString(session.durationSeconds)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: vm.resetCompletionStateIfNeeded,
              child: GlassContainer(
                borderRadius: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '닫기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
