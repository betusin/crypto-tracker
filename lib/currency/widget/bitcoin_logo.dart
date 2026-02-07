import 'package:flutter/material.dart';

class BitcoinLogo extends StatelessWidget {
  const BitcoinLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Icon(Icons.currency_bitcoin, size: 80, color: colorScheme.primary),
    );
  }
}
