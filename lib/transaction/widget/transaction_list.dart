import 'package:crypto_tracker/common/extension/string_extension.dart';
import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:crypto_tracker/transaction/service/transaction_service.dart';
import 'package:crypto_tracker/transaction/widget/add_or_update_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final _transactionRepository = getIt<FirestoreRepository<TransactionModel>>();
  final _transactionService = getIt<TransactionService>();

  TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return HandlingStreamBuilder(
      stream: _transactionService.observeTransactionsForCurrentUser(),
      builder: (context, transactions) {
        if (transactions.isEmpty) {
          return const Center(child: Text('No transactions yet.'));
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildDismissibleItem(context, transaction);
          },
        );
      },
    );
  }

  Widget _buildDismissibleItem(BuildContext context, TransactionModel transaction) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(transaction.id.toString()),
      background: Container(color: colorScheme.error),
      onDismissed: (direction) {
        _transactionRepository.delete(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      },
      child: _buildItem(context, colorScheme, transaction),
    );
  }

  void _editTransaction(BuildContext context, TransactionModel transaction) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddOrUpdateTransactionScreen(transaction: transaction)));
  }

  Widget _buildItem(BuildContext context, ColorScheme colorScheme, TransactionModel transaction) {
    final isBuy = transaction.type == TransactionType.buy;
    final color = isBuy ? colorScheme.secondary : colorScheme.error;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(isBuy ? Icons.arrow_downward : Icons.arrow_upward, color: color),
      ),
      title: Text('${transaction.cryptoCurrency.value.capitalize()} ${isBuy ? "Buy" : "Sell"}'),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(transaction.date)),
      onTap: () => _editTransaction(context, transaction),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isBuy ? "+" : "-"}${transaction.amount} ${transaction.cryptoCurrency.symbol}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
          Text(
            '€${transaction.priceInEur.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
