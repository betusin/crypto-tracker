import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_tracker/transaction/service/transaction_provider.dart';
import 'package:crypto_tracker/common/widget/summary_card.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

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
              SummaryCard(title: 'Total Portfolio Value', value: '€${totalValue.toStringAsFixed(2)}'),
              STANDARD_GAP,
              // TODO(betka): total profit should be calculated from transactions minus paid amount
              SummaryCard(
                title: 'Total Profit / Loss',
                value: '${isProfitPositive ? "+" : ""}€${totalProfit.toStringAsFixed(2)}',
                valueColor: isProfitPositive ? colorScheme.tertiary : colorScheme.error,
              ),
              // TODO(betka): display current prices of cryptocurrencies
              MEDIUM_GAP,
              const Text('Your Holdings:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SMALL_GAP,
              ...provider.holdings.entries.map((entry) {
                final cryptoId = entry.key;
                final amount = entry.value;
                final currentPrice = provider.currentPrices[cryptoId] ?? 0;
                final valueInEur = amount * currentPrice;

                // Only show if amount is not 0 (or very close to 0)
                if (amount.abs() < 0.000001) return const SizedBox.shrink();

                return ListTile(
                  title: Text(cryptoId.value.toUpperCase()),
                  subtitle: Text('${amount.toStringAsFixed(4)} ${cryptoId.symbol}'),
                  trailing: Text('€${valueInEur.toStringAsFixed(2)}'),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
