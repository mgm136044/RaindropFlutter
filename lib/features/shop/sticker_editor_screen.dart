import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/models/shop_catalog.dart';
import 'package:raindrop_flutter/core/models/shop_item.dart';
import 'package:raindrop_flutter/core/models/shop_state.dart';
import 'package:raindrop_flutter/features/shop/shop_view_model.dart';
import 'package:raindrop_flutter/features/timer/painters/bucket_painter.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class StickerEditorScreen extends StatefulWidget {
  final BucketSkin skin;
  final bool useCustomWaterColor;

  const StickerEditorScreen({
    super.key,
    required this.skin,
    this.useCustomWaterColor = false,
  });

  @override
  State<StickerEditorScreen> createState() => _StickerEditorScreenState();
}

class _StickerEditorScreenState extends State<StickerEditorScreen> {
  static const _bucketPreviewWidth = 220.0;
  static const _bucketPreviewHeight = 200.0;
  double _wobbleAngle = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Row(
                  children: [
                    // Left: Bucket preview with stickers
                    Expanded(child: _buildBucketPreview(context, vm)),
                    const VerticalDivider(width: 1),
                    // Right: Palette + Placed list
                    SizedBox(
                      width: 220,
                      child: Column(
                        children: [
                          Expanded(child: _buildStickerPalette(context, vm)),
                          const Divider(height: 1),
                          Expanded(
                              child: _buildPlacedStickerList(context, vm)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '스티커 편집',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('완료',
                  style: TextStyle(color: AppColors.accent(context))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketPreview(BuildContext context, ShopViewModel vm) {
    return GestureDetector(
      onTap: () {
        setState(() => _wobbleAngle = 6);
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) setState(() => _wobbleAngle = 0);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientTop(context),
              AppColors.backgroundGradientBottom(context),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedRotation(
                turns: _wobbleAngle / 360,
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: _bucketPreviewWidth,
                  height: _bucketPreviewHeight,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: BucketPainter(
                          progress: 0.5,
                          fillColor: widget.skin.bucketFill,
                          strokeColor: widget.skin.bucketStroke,
                          handleColor: widget.skin.bucketHandle,
                          bandColor: widget.skin.bandColor,
                        ),
                        size: const Size(
                            _bucketPreviewWidth, _bucketPreviewHeight),
                      ),
                      ...vm.shopState.placements.map((placement) {
                        final item = ShopCatalog.item(placement.itemID);
                        if (item == null) return const SizedBox.shrink();
                        return _DraggableStickerView(
                          emoji: item.emoji,
                          relativeX: placement.relativeX,
                          relativeY: placement.relativeY,
                          containerWidth: _bucketPreviewWidth,
                          containerHeight: _bucketPreviewHeight,
                          onPositionChanged: (newX, newY) {
                            vm.updatePlacementPosition(
                                placement.id, newX, newY);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Text(
                '스티커를 드래그하여 위치를 조정하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText(context).withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerPalette(BuildContext context, ShopViewModel vm) {
    final purchased =
        ShopCatalog.allItems.where((item) => vm.isPurchased(item)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Text(
            '스티커 추가',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText(context),
            ),
          ),
        ),
        if (purchased.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '구매한 스티커가 없습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.tertiaryText(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '상점에서 스티커를 구매해보세요',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: purchased.length,
                itemBuilder: (context, index) {
                  final item = purchased[index];
                  return InkWell(
                    onTap: () => _addStickerToCenter(vm, item),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.panelBackground(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(item.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlacedStickerList(BuildContext context, ShopViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Row(
            children: [
              Text(
                '배치된 스티커',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText(context),
                ),
              ),
              const Spacer(),
              if (vm.shopState.placements.isNotEmpty)
                InkWell(
                  onTap: () => vm.removeAllPlacements(),
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.danger(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (vm.shopState.placements.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                '배치된 스티커가 없습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.tertiaryText(context),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: vm.shopState.placements.length,
              itemBuilder: (context, index) {
                final placement = vm.shopState.placements[index];
                final item = ShopCatalog.item(placement.itemID);
                if (item == null) return const SizedBox.shrink();

                return ListTile(
                  dense: true,
                  leading:
                      Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete,
                        size: 14, color: AppColors.danger(context)),
                    onPressed: () => vm.removePlacement(placement.id),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _addStickerToCenter(ShopViewModel vm, ShopItem item) {
    final rng = Random();
    final placement = StickerPlacement(
      itemID: item.id,
      relativeX: 0.3 + rng.nextDouble() * 0.4,
      relativeY: 0.3 + rng.nextDouble() * 0.4,
    );
    vm.addPlacement(placement);
  }
}

class _DraggableStickerView extends StatefulWidget {
  final String emoji;
  final double relativeX;
  final double relativeY;
  final double containerWidth;
  final double containerHeight;
  final void Function(double newX, double newY) onPositionChanged;

  const _DraggableStickerView({
    required this.emoji,
    required this.relativeX,
    required this.relativeY,
    required this.containerWidth,
    required this.containerHeight,
    required this.onPositionChanged,
  });

  @override
  State<_DraggableStickerView> createState() => _DraggableStickerViewState();
}

class _DraggableStickerViewState extends State<_DraggableStickerView> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final x = widget.relativeX * widget.containerWidth + _dragOffset.dx;
    final y = widget.relativeY * widget.containerHeight + _dragOffset.dy;

    return Positioned(
      left: x - 13, // half of font size 26
      top: y - 13,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        },
        onPanEnd: (_) {
          final newX = widget.relativeX +
              _dragOffset.dx / widget.containerWidth;
          final newY = widget.relativeY +
              _dragOffset.dy / widget.containerHeight;
          widget.onPositionChanged(newX, newY);
          setState(() => _dragOffset = Offset.zero);
        },
        child: Text(
          widget.emoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}
