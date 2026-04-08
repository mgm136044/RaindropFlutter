import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raindrop_flutter/core/models/shop_catalog.dart';
import 'package:raindrop_flutter/core/models/shop_item.dart';
import 'package:raindrop_flutter/features/shop/shop_view_model.dart';
import 'package:raindrop_flutter/shared/components/glass_container.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ShopCatalog.categories.isNotEmpty
        ? ShopCatalog.categories.first
        : '기본';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, vm),
              _buildCategoryPicker(context, vm),
              Expanded(child: _buildItemGrid(context, vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ShopViewModel vm) {
    return GlassContainer(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '상점',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText(context),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\u{1FAA3} ${vm.balance}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent(context),
                ),
              ),
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

  Widget _buildCategoryPicker(BuildContext context, ShopViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          ...vm.categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                selectedColor: AppColors.accent(context).withValues(alpha: 0.2),
                onSelected: (_) =>
                    setState(() => _selectedCategory = category),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildItemGrid(BuildContext context, ShopViewModel vm) {
    final items = vm.items(_selectedCategory);
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShopItemCard(
          item: item,
          isPurchased: vm.isPurchased(item),
          canAfford: vm.canAfford(item),
          onPurchase: () => vm.purchase(item),
        );
      },
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isPurchased;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _ShopItemCard({
    required this.item,
    required this.isPurchased,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: isPurchased
            ? Border.all(
                color: AppColors.accent(context).withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            item.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (isPurchased)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '보유 중',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent(context),
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onPurchase : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1FAA3}', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
