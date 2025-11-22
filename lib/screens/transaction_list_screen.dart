import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            final color = isBuy ? Colors.green : Colors.red;
            final icon = isBuy ? Icons.arrow_downward : Icons.arrow_upward;

            return Dismissible(
              key: Key(tx.id.toString()),
              background: Container(color: Colors.red),
              onDismissed: (direction) {
                provider.deleteTransaction(tx.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '\$${tx.pricePerUnit.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
