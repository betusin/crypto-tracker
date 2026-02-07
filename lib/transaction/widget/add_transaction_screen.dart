import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/service/transaction_provider.dart';
import 'package:crypto_tracker/auth/service/auth_provider.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.buy;
  Cryptocurrency _selectedCryptoCurrency = Cryptocurrency.bitcoin;
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

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
      // TODO(betka): use auth service injection instead of provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final transaction = TransactionModel(
        // TODO(betka): generate ID
        id: '1',
        userId: userId,
        type: _type,
        cryptoCurrency: _selectedCryptoCurrency,
        amount: double.parse(_amountController.text),
        pricePerUnit: double.parse(_priceController.text),
        date: _selectedDate,
      );

      Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
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
              ElevatedButton(onPressed: _saveTransaction, child: const Text('Save Transaction')),
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
      initialValue: Cryptocurrency.bitcoin,
      decoration: const InputDecoration(labelText: 'Cryptocurrency'),
      items: Cryptocurrency.values
          .map((crypto) => DropdownMenuItem(value: crypto, child: Text('${crypto.value} (${crypto.symbol})')))
          .toList(),
      onChanged: (Cryptocurrency? newValue) =>
          newValue == null ? null : setState(() => _selectedCryptoCurrency = newValue),
    );
  }

  Widget _buildTransactionTypeRadios() {
    return RadioGroup(
      groupValue: _type,
      onChanged: (TransactionType? value) => value == null ? null : _setTransactionType(value),
      child: Row(children: TransactionType.values.map(_buildTransactionRadio).toList()),
    );
  }

  void _setTransactionType(TransactionType value) => setState(() => _type = value);

  Widget _buildTransactionRadio(TransactionType transactionType) {
    return Expanded(
      child: ListTile(
        // TODO(betka): use capitalize extension
        title: Text(transactionType.name),
        leading: Radio<TransactionType>(toggleable: true, value: transactionType),
        onTap: () => _setTransactionType(transactionType),
      ),
    );
  }
}
