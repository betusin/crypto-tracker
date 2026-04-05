import 'package:flutter/material.dart';

class CategoryIconPicker extends StatelessWidget {
  final int? selectedIconCodePoint;
  final ValueChanged<int> onIconSelected;

  const CategoryIconPicker({
    super.key,
    this.selectedIconCodePoint,
    required this.onIconSelected,
  });

  static const List<int> _availableIcons = [
    0xe390, // lunch_dining
    0xe56c, // restaurant
    0xe1d7, // directions_car
    0xe318, // home
    0xf10d, // medical_services
    0xf07a, // groups
    0xf37d, // shopping_bag
    0xe281, // fitness_center
    0xe148, // category
    0xe227, // attach_money
    0xe532, // flight
    0xe44d, // movie
    0xe517, // local_gas_station
    0xe3e0, // lightbulb
    0xe25a, // school
    0xe556, // pets
    0xe032, // card_giftcard
    0xe84e, // brush
    0xe616, // devices
    0xeb3f, // theater_comedy
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.map((codePoint) {
        final isSelected = selectedIconCodePoint == codePoint;
        return InkWell(
          onTap: () => onIconSelected(codePoint),
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
            child: Icon(
              IconData(codePoint, fontFamily: 'MaterialIcons'),
              color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
