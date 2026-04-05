import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/service/expense_service.dart';
import 'package:crypto_tracker/expense/widget/add_or_update_expense_screen.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';

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
            child: OutlinedButton.icon(
              onPressed: _pickCategory,
              icon: const Icon(Icons.category),
              label: Text(_selectedCategoryId == null ? 'All Categories' : 'Filtered'),
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

  Future<void> _pickCategory() async {
    // A simple dialog to clear category or select from a list.
    // For simplicity, we just clear it or let the user know they can add one.
    // In a full implementation, you'd show a list of categories here.
    setState(() => _selectedCategoryId = null);
  }

  Widget _buildExpenseList() {
    return HandlingStreamBuilder<List<Expense>>(
      stream: _expenseService.observeExpensesForCurrentUser(),
      builder: (context, expenses) {
        // TODO(betka): move filtering to service
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
            return ListTile(
              onTap: () => _onEditExpense(expense),
              title: Text(expense.title),
              subtitle: Text('${expense.date.day}.${expense.date.month}.${expense.date.year}'),
              trailing: Text(
                '${expense.amount.toStringAsFixed(2)} ${expense.currency.displayName}\n(≈ ${expense.amountInCzk.toStringAsFixed(2)} CZK)',
                textAlign: TextAlign.end,
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
