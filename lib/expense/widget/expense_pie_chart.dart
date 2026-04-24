import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<ExpenseCategory, double> categorizedExpenses;

  const ExpensePieChart({super.key, required this.categorizedExpenses});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? _touchedIndex;
  Offset? _touchedPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.categorizedExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No expenses in the last 30 days', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final total = widget.categorizedExpenses.values.fold(0.0, (sum, val) => sum + val);
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

    final entries = widget.categorizedExpenses.entries.toList();

    final sections = entries.indexed.map((entry) {
      final idx = entry.$1;
      final category = entry.$2.key;
      final value = entry.$2.value;
      final percentage = (value / total) * 100;
      final isTouched = idx == _touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;

      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
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
        const Text('Spending by Category (last month)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = null;
                            _touchedPosition = null;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          _touchedPosition = event.localPosition;
                        });
                      },
                    ),
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              if (_touchedIndex != null &&
                  _touchedPosition != null &&
                  _touchedIndex! >= 0 &&
                  _touchedIndex! < entries.length)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: _touchedPosition!.dx,
                  top: _touchedPosition!.dy - 50,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1.0),
                    child: Container(
                      key: ValueKey(_touchedIndex),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entries[_touchedIndex!].key.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${entries[_touchedIndex!].value.toStringAsFixed(0)} Kč',
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.surface.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
