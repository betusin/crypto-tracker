import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/widget/category_item.dart';
import 'package:flutter/material.dart';

class CategoryPickerDialog extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final String? selectedCategoryId;
  final VoidCallback onAddCategory;
  final ValueChanged<ExpenseCategory>? onEditCategory;

  const CategoryPickerDialog({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onAddCategory,
    this.onEditCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Category', style: theme.textTheme.titleLarge),
                    Text(
                      'Long press to edit',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddCategory();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                  tooltip: 'Add new category',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(child: SingleChildScrollView(child: _buildCategoryWrap(context))),
            const SizedBox(height: 20),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryWrap(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const spacing = 12.0;
        final availableWidth = maxWidth - (spacing * 2);
        final calculatedWidth = availableWidth / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          alignment: WrapAlignment.start,
          children: categories.map((category) {
            final isSelected = category.id == selectedCategoryId;
            return CategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () => Navigator.pop(context, category.id),
              onLongPress: onEditCategory != null
                  ? () {
                      Navigator.pop(context); // Close the picker
                      onEditCategory!(category);
                    }
                  : null,
              itemWidth: calculatedWidth,
            );
          }).toList(),
        );
      },
    );
  }
}
