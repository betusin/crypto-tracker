import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

class CategoryPickerDialog extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final String? selectedCategoryId;
  final VoidCallback onAddCategory;

  const CategoryPickerDialog({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
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
                Text('Select Category', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onAddCategory();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: 'Add new category',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == selectedCategoryId;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.grey.withAlpha(50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
                          color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                      onTap: () => Navigator.pop(context, category.id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
