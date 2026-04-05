import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double? itemWidth;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.itemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Roughly calculate width to fit 3 per row (with spacing)
    // In a dialog, typical width is around 280-320dp on mobile.
    // 3 items * 80dp = 240dp + spacings.
    final width = itemWidth ?? 84;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer.withAlpha(50) : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.grey.withAlpha(80),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceVariant.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CategoryIconMapper.getIcon(category.iconName),
                  color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
