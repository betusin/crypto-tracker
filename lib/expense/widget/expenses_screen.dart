import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:crypto_tracker/expense/service/expense_service.dart';
import 'package:crypto_tracker/expense/widget/add_or_update_expense_screen.dart';
import 'package:crypto_tracker/expense/widget/category_picker_dialog.dart';
import 'package:crypto_tracker/common/extension/num_extension.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _expenseService = getIt<ExpenseService>();
  final _expenseRepository = getIt<FirestoreRepository<Expense>>();

  DateTimeRange? _selectedDateRange;
  Set<String> _selectedCategoryIds = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildExpenseList()),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _selectedDateRange == null
                    ? 'All Dates'
                    : '${_selectedDateRange!.start.day}.${_selectedDateRange!.start.month}. - ${_selectedDateRange!.end.day}.${_selectedDateRange!.end.month}.',
              ),
            ),
          ),
          SMALL_GAP,
          Expanded(
            child: StreamBuilder<List<ExpenseCategory>>(
              stream: _expenseService.observeCategoriesForCurrentUser(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];

                return OutlinedButton.icon(
                  onPressed: () => _pickCategory(categories),
                  icon: const Icon(Icons.category),
                  label: Text(
                    _selectedCategoryIds.isEmpty ? 'All Categories' : 'Filtered (${_selectedCategoryIds.length})',
                  ),
                );
              },
            ),
          ),
          if (_selectedDateRange != null || _selectedCategoryIds.isNotEmpty) ...[
            SMALL_GAP,
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _selectedDateRange = null;
                _selectedCategoryIds.clear();
              }),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() => _selectedDateRange = range);
    }
  }

  Future<void> _pickCategory(List<ExpenseCategory> categories) async {
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => CategoryPickerDialog(
        categories: categories,
        selectedCategoryIds: _selectedCategoryIds,
        multiSelect: true,
        onAddCategory: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddOrUpdateExpenseScreen()));
        },
      ),
    );

    if (result != null) {
      setState(() => _selectedCategoryIds = result);
    }
  }

  Widget _buildExpenseList() {
    return HandlingStreamBuilder<Map<String, dynamic>>(
      stream: Rx.combineLatest2(
        _expenseService.observeExpensesForCurrentUser(),
        _expenseService.observeCategoriesForCurrentUser(),
        (expenses, categories) => {'expenses': expenses, 'categories': categories},
      ),
      builder: (context, data) {
        List<Expense> expenses = data['expenses'] as List<Expense>;
        final categories = data['categories'] as List<ExpenseCategory>;
        final categoryMap = {for (var c in categories) c.id: c};

        // Apply filters
        if (_selectedDateRange != null) {
          final start = _selectedDateRange!.start;
          final end = _selectedDateRange!.end;
          final startDay = DateTime(start.year, start.month, start.day);
          final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

          expenses = expenses.where((e) {
            return e.date.isAfter(startDay.subtract(const Duration(seconds: 1))) &&
                e.date.isBefore(endDay.add(const Duration(seconds: 1)));
          }).toList();
        }
        if (_selectedCategoryIds.isNotEmpty) {
          expenses = expenses.where((e) => _selectedCategoryIds.contains(e.categoryId)).toList();
        }

        expenses.sort((a, b) => b.date.compareTo(a.date));

        final totalSpent = expenses.fold(0.0, (sum, expense) => sum + expense.amountInCzk);

        final totalWidget = Padding(
          padding: const EdgeInsets.only(right: STANDARD_GAP_SIZE),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total Spent: ${totalSpent.formatWithSpaces(0)} Kč',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );

        if (expenses.isEmpty) {
          return Column(
            children: [
              totalWidget,
              const Expanded(child: Center(child: Text('No expenses found.'))),
            ],
          );
        }

        final List<Widget> listItems = [];
        DateTime? currentDate;

        for (final expense in expenses) {
          final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
          if (currentDate != expenseDate) {
            currentDate = expenseDate;
            listItems.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(SMALL_GAP_SIZE, SMALL_GAP_SIZE, SMALL_GAP_SIZE, SMALL_GAP_SIZE / 2),
                child: Text(
                  '${currentDate.day}.${currentDate.month}.${currentDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            );
          }

          final category = categoryMap[expense.categoryId];

          listItems.add(
            ListTile(
              onTap: () => _onEditExpense(expense),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  CategoryIconMapper.getIcon(category?.iconName ?? 'category'),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(expense.title),
              subtitle: Text(category?.name ?? "Unknown"),
              trailing: Text(
                '${expense.amount.formatWithSpaces(2)} ${expense.currency.displayName}\n(≈ ${expense.amountInCzk.formatWithSpaces(2)} CZK)',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onLongPress: () => _expenseRepository.delete(expense.id),
            ),
          );
        }

        listItems.add(STANDARD_GAP);
        listItems.add(STANDARD_GAP);
        listItems.add(STANDARD_GAP);
        listItems.add(STANDARD_GAP);

        return Column(
          children: [
            totalWidget,
            Expanded(child: ListView(children: listItems)),
          ],
        );
      },
    );
  }

  void _onEditExpense(Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddOrUpdateExpenseScreen(expense: expense)));
  }
}
