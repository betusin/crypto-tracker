import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final totalValue = provider.totalPortfolioValue;
        final totalProfit = provider.totalProfit;
        final isProfitPositive = totalProfit >= 0;

        return RefreshIndicator(
          onRefresh: () => provider.fetchCurrentPrices(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Portfolio Value',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Profit / Loss',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${isProfitPositive ? "+" : ""}\$${totalProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isProfitPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => provider.fetchCurrentPrices(),
                icon: const Icon(Icons.refresh),
                label: const Text('Update Prices'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Current Prices:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...provider.currentPrices.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key.toUpperCase()),
                  trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
