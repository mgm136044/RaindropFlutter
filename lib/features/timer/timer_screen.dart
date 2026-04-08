import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'timer_view_model.dart';
import 'timer_controls.dart';
import 'sky_background.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _motivationIndex = 0;

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

  String get _currentMessage {
    final vm = context.read<TimerViewModel>();
    final messages = vm.isRunning ? _runningMessages : _idleMessages;
    return messages[_motivationIndex % messages.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerViewModel>(
      builder: (context, vm, _) {
        return Stack(
          children: [
            // Layer 0: Sky background
            SkyBackground(
              progress: vm.currentProgress,
              isRunning: vm.isRunning,
            ),

            // Layer 1: Bucket scene (placeholder)
            const Center(
              child: Icon(Icons.water_drop, size: 120, color: Colors.blue),
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
              child: Center(
                child: Text(
                  _currentMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

            // Layer 4: Timer + controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Timer capsule
                  _buildTimerCapsule(context, vm),
                  const SizedBox(height: 20),
                  // Controls
                  TimerControls(
                    canStart: vm.canStart,
                    canPause: vm.canPause,
                    canResume: vm.canResume,
                    canStop: vm.canStop,
                    isCompact: vm.isRunning,
                    onStart: () {
                      vm.resetCompletionStateIfNeeded();
                      vm.start();
                    },
                    onPause: vm.pause,
                    onResume: vm.resume,
                    onStop: vm.stop,
                  ),
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
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          child: Row(
            children: [
              Text(
                'RainDrop',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'v2.1.1',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                onPressed: () => _showSheet(context, const ShopScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 18),
                onPressed: () => _showSheet(context, const SettingsScreen()),
              ),
              FilledButton.icon(
                onPressed: () => _showSheet(context, const HistoryScreen()),
                icon: const Icon(Icons.calendar_today, size: 14),
                label: const Text('히스토리', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCapsule(BuildContext context, TimerViewModel vm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: vm.isRunning ? 5 : 20,
          sigmaY: vm.isRunning ? 5 : 20,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(
              alpha: vm.isRunning ? 0.1 : 0.3,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.timerText,
                style: TextStyle(
                  fontSize: vm.isRunning ? 32 : 44,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${vm.goalText} · 오늘 ${vm.todayTotalText}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget screen) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 620,
          height: 580,
          child: screen,
        ),
      ),
    );
  }
}
