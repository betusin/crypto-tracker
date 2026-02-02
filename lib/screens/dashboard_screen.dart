import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                      Text(
                        'Total Portfolio Value',
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                      Text('Total Profit / Loss', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 10),
                      Text(
                        '${isProfitPositive ? "+" : ""}\$${totalProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isProfitPositive ? colorScheme.tertiary : colorScheme.error,
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
              const Text('Your Holdings:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...provider.holdings.entries.map((entry) {
                final cryptoId = entry.key;
                final amount = entry.value;
                final currentPrice = provider.currentPrices[cryptoId] ?? 0;
                final valueInUsd = amount * currentPrice;

                // Only show if amount is not 0 (or very close to 0)
                if (amount.abs() < 0.000001) return const SizedBox.shrink();

                return ListTile(
                  title: Text(cryptoId.toUpperCase()),
                  subtitle: Text('${amount.toStringAsFixed(4)} ${cryptoId == 'bitcoin' ? 'BTC' : 'ETH'}'),
                  trailing: Text('\$${valueInUsd.toStringAsFixed(2)}'),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
