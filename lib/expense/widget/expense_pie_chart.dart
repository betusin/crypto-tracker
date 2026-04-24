import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> categorizedExpenses;

  const ExpensePieChart({super.key, required this.categorizedExpenses});

  @override
  Widget build(BuildContext context) {
    if (categorizedExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No expenses in the last 30 days', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final total = categorizedExpenses.values.fold(0.0, (sum, val) => sum + val);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Premium colors for slices
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      Colors.indigo,
      Colors.teal,
      Colors.orange,
    ];

    final sections = categorizedExpenses.entries.indexed.map((entry) {
      final idx = entry.$1;
      final category = entry.$2.key;
      final value = entry.$2.value;
      final percentage = (value / total) * 100;

      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(CategoryIconMapper.getIcon(category.iconName), size: 16, color: colors[idx % colors.length]),
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();

    return Column(
      children: [
        const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: categorizedExpenses.entries.indexed.map((entry) {
            final idx = entry.$1;
            final category = entry.$2.key;
            final value = entry.$2.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('${category.name}: ${value.toStringAsFixed(0)}', style: theme.textTheme.bodySmall),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
