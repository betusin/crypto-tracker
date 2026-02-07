import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/service/transaction_provider.dart';
import 'package:crypto_tracker/auth/service/auth_provider.dart';
import 'package:crypto_tracker/price/service/price_service.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _type = TransactionType.buy;
  String _cryptoId = 'bitcoin';
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final PriceService _priceService = PriceService();
  bool _isFetchingPrice = false;

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    setState(() {
      _isFetchingPrice = true;
    });
    try {
      final price = await _priceService.fetchPrice(_cryptoId);
      _priceController.text = price.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch price: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingPrice = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
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
        userId: userId,
        type: _type,
        cryptoId: _cryptoId,
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
          child: ListView(
            children: [
              // Transaction Type
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Buy'),
                      value: TransactionType.buy,
                      groupValue: _type,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<TransactionType>(
                      title: const Text('Sell'),
                      value: TransactionType.sell,
                      groupValue: _type,
                      onChanged: (TransactionType? value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Crypto Selection
              DropdownButtonFormField<String>(
                value: _cryptoId,
                decoration: const InputDecoration(labelText: 'Cryptocurrency'),
                items: const [
                  DropdownMenuItem(value: 'bitcoin', child: Text('Bitcoin (BTC)')),
                  DropdownMenuItem(value: 'ethereum', child: Text('Ethereum (ETH)')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _cryptoId = newValue!;
                  });
                },
              ),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
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
              ),

              // Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price per Unit (EUR)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: _isFetchingPrice
                        ? SizedBox(
                            width: MEDIUM_GAP_SIZE,
                            height: MEDIUM_GAP_SIZE,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    onPressed: _isFetchingPrice ? null : _fetchPrice,
                    tooltip: 'Fetch Current Price',
                  ),
                ],
              ),

              // Date
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              MEDIUM_GAP,

              ElevatedButton(onPressed: _saveTransaction, child: const Text('Save Transaction')),
            ],
          ),
        ),
      ),
    );
  }
}
