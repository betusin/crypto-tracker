import 'package:crypto_tracker/common/widget/handling_stream_builder.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:crypto_tracker/price/service/current_price_controller.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/transaction/service/holding_service.dart';
import 'package:crypto_tracker/common/widget/summary_card.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';

class DashboardScreen extends StatelessWidget {
  final _holdingService = getIt<HoldingService>();
  final _currentPriceController = getIt<CurrentPriceController>();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => _currentPriceController.fetchCurrentPrices(),
      child: HandlingStreamBuilder(
        stream: _holdingService.holdingsDataStream(),
        builder: (context, data) {
          final (holdings, currentPrices, totalPortfolioValue, totalProfit) = data;
          final isProfitPositive = totalProfit >= 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SummaryCard(title: 'Total Portfolio Value', value: '€${totalPortfolioValue.toStringAsFixed(2)}'),
              STANDARD_GAP,
              SummaryCard(
                title: 'Total Profit / Loss',
                value: '${isProfitPositive ? "+" : ""}€${totalProfit.toStringAsFixed(2)}',
                valueColor: isProfitPositive ? colorScheme.tertiary : colorScheme.error,
              ),
              // TODO(betka): display current prices of cryptocurrencies - maybe selector for which crypto to display
              MEDIUM_GAP,
              const Text('Your Holdings:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SMALL_GAP,
              ...holdings.entries.map((entry) {
                final cryptoCurrency = entry.key;
                final amount = entry.value;
                final currentPrice = currentPrices[cryptoCurrency] ?? 0;
                final valueInEur = amount * currentPrice;

                // Only show if amount is not 0 (or very close to 0)
                if (amount.abs() < 0.000001) return const SizedBox.shrink();

                return ListTile(
                  title: Text(cryptoCurrency.value.toUpperCase()),
                  subtitle: Text('${amount.toStringAsFixed(4)} ${cryptoCurrency.symbol}'),
                  trailing: Text('€${valueInEur.toStringAsFixed(2)}'),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
