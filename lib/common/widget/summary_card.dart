import 'package:flutter/material.dart';
import '../constants/shared_ui_constants.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.title, required this.value, this.valueColor});

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
            SMALL_GAP,
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
