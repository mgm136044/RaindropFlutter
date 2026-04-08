import 'dart:math';
import 'package:flutter/material.dart';
import 'package:raindrop_flutter/core/models/shop_catalog.dart';
import 'package:raindrop_flutter/core/models/shop_state.dart';

/// Read-only sticker overlay on bucket with wobble tap animation.
/// Uses AnimationController with SpringSimulation for wobble + tilt.
/// Matches BucketWithStickersView / StickerPlacementView.swift.
class StickerPlacementView extends StatefulWidget {
  final double progress;
  final List<StickerPlacement> placements;
  final Widget child;

  const StickerPlacementView({
    super.key,
    required this.progress,
    required this.placements,
    required this.child,
  });

  @override
  State<StickerPlacementView> createState() => _StickerPlacementViewState();
}

class _StickerPlacementViewState extends State<StickerPlacementView>
    with SingleTickerProviderStateMixin {
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _wobbleAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.elasticOut),
    );
  }

  void _triggerWobble() {
    _wobbleAnimation = Tween<double>(begin: 6.0, end: 0.0).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.elasticOut),
    );
    _wobbleController.forward(from: 0);
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerWobble,
      child: AnimatedBuilder(
        animation: _wobbleAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _wobbleAnimation.value * pi / 180,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                widget.child,
                ...widget.placements.map((placement) {
                  return Positioned(
                    left: placement.relativeX * constraints.maxWidth - 13,
                    top: placement.relativeY * constraints.maxHeight - 13,
                    child: IgnorePointer(
                      child: Text(
                        _emojiForItem(placement.itemID),
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  String _emojiForItem(String itemID) {
    return ShopCatalog.item(itemID)?.emoji ?? '\u{2B50}';
  }
}
