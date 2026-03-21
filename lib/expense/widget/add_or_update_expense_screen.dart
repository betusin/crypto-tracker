import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/currency/model/fiat_currency.dart';
import 'package:crypto_tracker/currency/service/fiat_currency_service.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/expense_service.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddOrUpdateExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddOrUpdateExpenseScreen({super.key, this.expense});

  @override
  State<AddOrUpdateExpenseScreen> createState() => _AddOrUpdateExpenseScreenState();
}

class _AddOrUpdateExpenseScreenState extends State<AddOrUpdateExpenseScreen> {
  final _expenseService = getIt<ExpenseService>();
  final _expenseRepo = getIt<FirestoreRepository<Expense>>();
  final _categoryRepo = getIt<FirestoreRepository<ExpenseCategory>>();
  final _fiatCurrencyService = getIt<FiatCurrencyService>();
  final _signedInUserProvider = getIt<SignedInUserProvider>();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  FiatCurrency _selectedCurrency = FiatCurrency.czk;
  String? _selectedCategoryId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _expenseService.seedDefaultCategoriesIfEmpty();

    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _selectedDate = widget.expense!.date;
      _selectedCurrency = widget.expense!.currency;
      _selectedCategoryId = widget.expense!.categoryId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text;
      final amount = double.parse(_amountController.text);

      double amountInCzk = amount;
      if (_selectedCurrency == FiatCurrency.eur) {
        final rate = await _fiatCurrencyService.getEurToCzkRate();
        amountInCzk = amount * rate;
      }

      final expense = Expense(
        id: widget.expense?.id ?? const Uuid().v4(),
        userId: _signedInUserProvider.currentUser!.uid,
        title: title,
        categoryId: _selectedCategoryId!,
        amount: amount,
        currency: _selectedCurrency,
        amountInCzk: amountInCzk,
        date: _selectedDate,
      );

      if (widget.expense == null) {
        await _expenseRepo.add(expense);
      } else {
        await _expenseRepo.update(expense.id, expense.toJson());
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final catController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, catController.text), child: const Text('Add')),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final newCat = ExpenseCategory(
        id: const Uuid().v4(),
        userId: _signedInUserProvider.currentUser!.uid,
        name: name,
        isCustom: true,
      );
      await _categoryRepo.add(newCat);
      setState(() => _selectedCategoryId = newCat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Add Expense' : 'Update Expense')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => v!.isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(labelText: 'Amount'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => v!.isEmpty || double.tryParse(v) == null ? 'Enter valid amount' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<FiatCurrency>(
                          value: _selectedCurrency,
                          items: FiatCurrency.values.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c.displayName));
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCurrency = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<ExpenseCategory>>(
                      stream: _expenseService.observeCategoriesForCurrentUser(),
                      builder: (context, snapshot) {
                        final categories = snapshot.data ?? [];
                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategoryId,
                                hint: const Text('Select Category'),
                                items: categories.map((c) {
                                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedCategoryId = v),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addCategory,
                              tooltip: 'Add new category',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
