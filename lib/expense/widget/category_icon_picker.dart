import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:flutter/material.dart';

class CategoryIconPicker extends StatelessWidget {
  final String? selectedIconName;
  final ValueChanged<String> onIconSelected;

  const CategoryIconPicker({
    super.key,
    this.selectedIconName,
    required this.onIconSelected,
  });

  static const List<String> _availableIcons = [
    'lunch_dining',
    'restaurant',
    'directions_car',
    'home',
    'medical_services',
    'groups',
    'shopping_bag',
    'fitness_center',
    'category',
    'attach_money',
    'flight',
    'movie',
    'local_gas_station',
    'lightbulb',
    'school',
    'pets',
    'card_giftcard',
    'brush',
    'devices',
    'theater_comedy',
    'health_and_safety',
    'local_hospital',
    'celebration',
    'nightlife',
    'local_bar',
    'liquor',
    'coffee',
    'shopping_cart',
    'payment',
    'receipt_long',
    'savings',
    'electric_bolt',
    'water_drop',
    'commute',
    'work',
    'build',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.map((name) {
        final isSelected = selectedIconName == name;
        return InkWell(
          onTap: () => onIconSelected(name),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withAlpha(128),
              ),
            ),
            child: Tooltip(
              message: name,
              child: Icon(
                CategoryIconMapper.getIcon(name),
                color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
