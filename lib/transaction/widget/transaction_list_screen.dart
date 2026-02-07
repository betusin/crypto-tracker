import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/database/service/firestore_repository.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:crypto_tracker/transaction/service/transaction_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends StatelessWidget {
  final _transactionRepository = getIt<FirestoreRepository<TransactionModel>>();
  final _transactionService = getIt<TransactionService>();

  TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            final isBuy = transaction.type == TransactionType.buy;
            final color = isBuy ? colorScheme.tertiary : colorScheme.error;
            final icon = isBuy ? Icons.arrow_downward : Icons.arrow_upward;

            return Dismissible(
              key: Key(transaction.id.toString()),
              background: Container(color: colorScheme.error),
              onDismissed: (direction) {
                _transactionRepository.delete(transaction.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color),
                ),
                title: Text('${transaction.cryptoCurrency.value.toUpperCase()} ${isBuy ? "Buy" : "Sell"}'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(transaction.date)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isBuy ? "+" : "-"}${transaction.amount} ${transaction.cryptoCurrency.symbol}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      '\$${transaction.pricePerUnit.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
