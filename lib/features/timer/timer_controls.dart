import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:raindrop_flutter/shared/components/primary_button.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

/// Timer controls — compact (circle icons) and full (text buttons) modes.
/// Matches TimerControlsView.swift.
class TimerControls extends StatelessWidget {
  final bool canStart;
  final bool canPause;
  final bool canResume;
  final bool canStop;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final bool isCompact;

  const TimerControls({
    super.key,
    required this.canStart,
    required this.canPause,
    required this.canResume,
    required this.canStop,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.accent(context);
    final dangerColor = AppColors.danger(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Row(
        key: ValueKey('$canStart-$canPause-$canResume-$canStop-$isCompact'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canStart)
            isCompact
                ? _CompactButton(
                    icon: Icons.play_arrow_rounded,
                    color: accentColor,
                    onPressed: onStart,
                  )
                : PrimaryButton(
                    label: '집중 시작',
                    onPressed: onStart,
                    color: accentColor,
                  ),
          if (canPause) ...[
            if (canStart) SizedBox(width: isCompact ? 16 : 12),
            isCompact
                ? _CompactButton(
                    icon: Icons.pause_rounded,
                    color: accentColor,
                    onPressed: onPause,
                  )
                : PrimaryButton(
                    label: '일시정지',
                    onPressed: onPause,
                    color: accentColor,
                  ),
          ],
          if (canResume) ...[
            isCompact
                ? _CompactButton(
                    icon: Icons.play_arrow_rounded,
                    color: accentColor,
                    onPressed: onResume,
                  )
                : PrimaryButton(
                    label: '재개',
                    onPressed: onResume,
                    color: accentColor,
                  ),
          ],
          if (canStop) ...[
            SizedBox(width: isCompact ? 16 : 12),
            isCompact
                ? _CompactButton(
                    icon: Icons.stop_rounded,
                    color: dangerColor,
                    onPressed: onStop,
                  )
                : PrimaryButton(
                    label: '집중 종료',
                    onPressed: onStop,
                    color: dangerColor,
                  ),
          ],
        ],
      ),
    );
  }
}

class _CompactButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CompactButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_CompactButton> createState() => _CompactButtonState();
}

class _CompactButtonState extends State<_CompactButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
