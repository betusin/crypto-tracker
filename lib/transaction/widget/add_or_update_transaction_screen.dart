import 'package:crypto_tracker/auth/service/signed_in_user_provider.dart';
import 'package:crypto_tracker/common/extension/string_extension.dart';
import 'package:crypto_tracker/common/util/id_generator.dart';
import 'package:crypto_tracker/common/widget/page_wrapper.dart';
import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

class AddOrUpdateTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddOrUpdateTransactionScreen({super.key, this.transaction});

  @override
  State<AddOrUpdateTransactionScreen> createState() => _AddOrUpdateTransactionScreenState();
}

class _AddOrUpdateTransactionScreenState extends State<AddOrUpdateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _signedInUserProvider = getIt<SignedInUserProvider>();
  final _transactionRepository = getIt<FirestoreRepository<TransactionModel>>();

  late final TextEditingController _amountController;
  late final TextEditingController _priceController;

  late TransactionType _type;
  late Cryptocurrency _selectedCryptoCurrency;
  late DateTime _selectedDate;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction?.amount.toString());
    _priceController = TextEditingController(text: widget.transaction?.pricePerUnit.toString());
    _type = widget.transaction?.type ?? TransactionType.buy;
    _selectedCryptoCurrency = widget.transaction?.cryptoCurrency ?? Cryptocurrency.bitcoin;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final userId = _signedInUserProvider.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final transaction = TransactionModel(
        id: widget.transaction?.id ?? generateId(),
        userId: userId,
        type: _type,
        cryptoCurrency: _selectedCryptoCurrency,
        amount: double.parse(_amountController.text),
        pricePerUnit: double.parse(_priceController.text),
        date: _selectedDate,
      );

      if (_isEditing) {
        _transactionRepository.set(transaction.id, transaction.toJson());
      } else {
        _transactionRepository.add(transaction);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: _isEditing ? 'Update Transaction' : 'Add Transaction',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTransactionTypeRadios(),
              _buildCryptoSelector(),
              _buildAmountField(),
              _buildPriceField(),
              _buildDateSelector(context),
              MEDIUM_GAP,
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SMALL_GAP_SIZE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}', style: TextTheme.of(context).bodyLarge),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(labelText: 'Price per Unit (EUR)'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        // TODO(betka): extract to a reusable validator and reuse here and below, it could also be a DoubleFormField or similar
        if (value == null || value.isEmpty) {
          return 'Please enter a price';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(labelText: 'Amount (${_selectedCryptoCurrency.symbol})'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildCryptoSelector() {
    return DropdownButtonFormField<Cryptocurrency>(
      initialValue: _selectedCryptoCurrency,
      decoration: const InputDecoration(labelText: 'Cryptocurrency'),
      items: Cryptocurrency.values
          .map(
            (crypto) => DropdownMenuItem(value: crypto, child: Text('${crypto.value.capitalize()} (${crypto.symbol})')),
          )
          .toList(),
      onChanged: (Cryptocurrency? newValue) =>
          newValue == null ? null : setState(() => _selectedCryptoCurrency = newValue),
    );
  }

  Widget _buildTransactionTypeRadios() {
    return RadioGroup<TransactionType>(
      groupValue: _type,
      onChanged: (TransactionType? value) => value == null ? null : _setTransactionType(value),
      child: Row(children: TransactionType.values.map(_buildTransactionRadio).toList()),
    );
  }

  void _setTransactionType(TransactionType value) => setState(() => _type = value);

  Widget _buildTransactionRadio(TransactionType transactionType) {
    return Expanded(
      child: ListTile(
        title: Text(transactionType.name.capitalize()),
        leading: Radio<TransactionType>(toggleable: true, value: transactionType),
        onTap: () => _setTransactionType(transactionType),
      ),
    );
  }
}
