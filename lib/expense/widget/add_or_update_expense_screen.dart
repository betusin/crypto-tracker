import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/currency/model/fiat_currency.dart';
import 'package:crypto_tracker/currency/service/fiat_currency_service.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/expense/model/expense.dart';
import 'package:crypto_tracker/expense/model/expense_category.dart';
import 'package:crypto_tracker/expense/service/expense_service.dart';
import 'package:crypto_tracker/expense/widget/category_icon_picker.dart';
import 'package:crypto_tracker/expense/widget/category_picker_dialog.dart';
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
    int selectedIcon = 0xe148; // Icons.category.codePoint

    final result = await showDialog<ExpenseCategory>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: catController,
                  decoration: const InputDecoration(labelText: 'Category Name', hintText: 'e.g. Entertainment'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),
                const Text('Pick an Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                CategoryIconPicker(
                  selectedIconCodePoint: selectedIcon,
                  onIconSelected: (code) => setDialogState(() => selectedIcon = code),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (catController.text.isNotEmpty) {
                  Navigator.pop(
                    context,
                    ExpenseCategory(
                      id: const Uuid().v4(),
                      userId: _signedInUserProvider.currentUser!.uid,
                      name: catController.text,
                      iconCodePoint: selectedIcon,
                      isCustom: true,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      await _categoryRepo.add(result);
      setState(() => _selectedCategoryId = result.id);
    }
  }

  void _showCategoryPicker(List<ExpenseCategory> categories) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CategoryPickerDialog(
        categories: categories,
        selectedCategoryId: _selectedCategoryId,
        onAddCategory: _addCategory,
      ),
    );

    if (result != null) {
      setState(() => _selectedCategoryId = result);
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
                        final selectedCategory = categories.firstWhere(
                          (c) => c.id == _selectedCategoryId,
                          orElse: () => ExpenseCategory(
                            id: '',
                            userId: '',
                            name: 'Select Category',
                            iconCodePoint: 0xe148, // Icons.category
                          ),
                        );

                        return InkWell(
                          onTap: () => _showCategoryPicker(categories),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withAlpha(150)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    IconData(selectedCategory.iconCodePoint, fontFamily: 'MaterialIcons'),
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Category',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                      ),
                                      Text(
                                        selectedCategory.name,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight:
                                                  _selectedCategoryId != null ? FontWeight.bold : FontWeight.normal,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
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
