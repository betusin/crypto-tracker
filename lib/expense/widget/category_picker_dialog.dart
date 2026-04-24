import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/widget/category_item.dart';
import 'package:flutter/material.dart';

class CategoryPickerDialog extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final String? selectedCategoryId;
  final Set<String>? selectedCategoryIds;
  final bool multiSelect;
  final VoidCallback onAddCategory;
  final ValueChanged<ExpenseCategory>? onEditCategory;

  const CategoryPickerDialog({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.selectedCategoryIds,
    this.multiSelect = false,
    required this.onAddCategory,
    this.onEditCategory,
  });

  @override
  State<CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<CategoryPickerDialog> {
  late Set<String> _currentSelection;

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      _currentSelection = Set.from(widget.selectedCategoryIds ?? {});
    } else {
      _currentSelection = widget.selectedCategoryId != null ? {widget.selectedCategoryId!} : {};
    }
  }

  void _toggleCategory(String id) {
    if (widget.multiSelect) {
      setState(() {
        if (_currentSelection.contains(id)) {
          _currentSelection.remove(id);
        } else {
          _currentSelection.add(id);
        }
      });
    } else {
      Navigator.pop(context, id);
    }
  }

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
                    widget.onAddCategory();
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
            if (widget.multiSelect)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _currentSelection),
                    child: const Text('Apply'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ),
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
          children: widget.categories.map((category) {
            final isSelected = _currentSelection.contains(category.id);
            return CategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () => _toggleCategory(category.id),
              onLongPress: widget.onEditCategory != null
                  ? () {
                      Navigator.pop(context); // Close the picker
                      widget.onEditCategory!(category);
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
