import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/service/transaction_provider.dart';
import 'package:crypto_tracker/auth/service/auth_provider.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.transactions.isEmpty) {
          return const Center(child: Text('No transactions yet.'));
        }

        return ListView.builder(
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final tx = provider.transactions[index];
            final isBuy = tx.type == TransactionType.buy;
            final color = isBuy ? colorScheme.tertiary : colorScheme.error;
            final icon = isBuy ? Icons.arrow_downward : Icons.arrow_upward;

            return Dismissible(
              key: Key(tx.id.toString()),
              background: Container(color: colorScheme.error),
              onDismissed: (direction) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final userId = authProvider.userId;
                if (userId != null) {
                  provider.deleteTransaction(tx.id!, userId);
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color),
                ),
                title: Text('${tx.cryptoId.toUpperCase()} ${isBuy ? "Buy" : "Sell"}'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(tx.date)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isBuy ? "+" : "-"}${tx.amount} ${tx.cryptoId == 'bitcoin' ? 'BTC' : 'ETH'}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      '\$${tx.pricePerUnit.toStringAsFixed(2)}',
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
