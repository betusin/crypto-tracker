import 'package:flutter/material.dart';

class CategoryIconMapper {
  static const Map<String, IconData> _iconMap = {
    'lunch_dining': Icons.lunch_dining,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'groups': Icons.groups,
    'shopping_bag': Icons.shopping_bag,
    'fitness_center': Icons.fitness_center,
    'category': Icons.category,
    'attach_money': Icons.attach_money,
    'flight': Icons.flight,
    'movie': Icons.movie,
    'local_gas_station': Icons.local_gas_station,
    'lightbulb': Icons.lightbulb,
    'school': Icons.school,
    'pets': Icons.pets,
    'card_giftcard': Icons.card_giftcard,
    'brush': Icons.brush,
    'devices': Icons.devices,
    'theater_comedy': Icons.theater_comedy,
    'health_and_safety': Icons.health_and_safety,
    'local_hospital': Icons.local_hospital,
    'celebration': Icons.celebration,
    'nightlife': Icons.nightlife,
    'local_bar': Icons.local_bar,
    'liquor': Icons.liquor,
    'coffee': Icons.coffee,
    'shopping_cart': Icons.shopping_cart,
    'payment': Icons.payment,
    'receipt_long': Icons.receipt_long,
    'savings': Icons.savings,
    'electric_bolt': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
    'commute': Icons.commute,
    'work': Icons.work,
    'build': Icons.build,
  };

  static IconData getIcon(String name) {
    return _iconMap[name] ?? Icons.category;
  }

  static String getName(IconData icon) {
    return _iconMap.entries
        .firstWhere((e) => e.value == icon, orElse: () => const MapEntry('category', Icons.category))
        .key;
  }
}
