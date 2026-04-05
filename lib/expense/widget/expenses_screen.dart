import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/category_icon_mapper.dart';
import 'package:crypto_tracker/expense/service/expense_service.dart';
import 'package:crypto_tracker/expense/widget/add_or_update_expense_screen.dart';
import 'package:crypto_tracker/expense/widget/category_picker_dialog.dart';
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

  DateTime? _selectedDate;
  String? _selectedCategoryId;

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
                _selectedDate == null
                    ? 'All Dates'
                    : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
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
                  label: Text(_selectedCategoryId == null ? 'All Categories' : 'Filtered'),
                );
              }
            ),
          ),
          if (_selectedDate != null || _selectedCategoryId != null) ...[
            SMALL_GAP,
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => setState(() {
                _selectedDate = null;
                _selectedCategoryId = null;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickCategory(List<ExpenseCategory> categories) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CategoryPickerDialog(
        categories: categories,
        selectedCategoryId: _selectedCategoryId,
        onAddCategory: () {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddOrUpdateExpenseScreen()));
        },
      ),
    );

    if (result != null) {
      setState(() => _selectedCategoryId = result);
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
        if (_selectedDate != null) {
          expenses = expenses
              .where(
                (e) =>
                    e.date.year == _selectedDate!.year &&
                    e.date.month == _selectedDate!.month &&
                    e.date.day == _selectedDate!.day,
              )
              .toList();
        }
        if (_selectedCategoryId != null) {
          expenses = expenses.where((e) => e.categoryId == _selectedCategoryId).toList();
        }

        expenses.sort((a, b) => b.date.compareTo(a.date));

        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses found.'));
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            final category = categoryMap[expense.categoryId];

            return ListTile(
              onTap: () => _onEditExpense(expense),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  CategoryIconMapper.getIcon(category?.iconName ?? 'category'),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(expense.title),
              subtitle: Text(
                '${category?.name ?? "Unknown"} • ${_selectedDate == null ? "${expense.date.day}.${expense.date.month}.${expense.date.year}" : ""}',
              ),
              trailing: Text(
                '${expense.amount.toStringAsFixed(2)} ${expense.currency.displayName}\n(≈ ${expense.amountInCzk.toStringAsFixed(2)} CZK)',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onLongPress: () => _expenseRepository.delete(expense.id),
            );
          },
        );
      },
    );
  }

  void _onEditExpense(Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddOrUpdateExpenseScreen(expense: expense)));
  }
}
