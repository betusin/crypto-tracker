import 'package:crypto_tracker/currency/model/cryptocureny.dart';

class PortfolioSummary {
  final Map<Cryptocurrency, double> holdings;
  final Map<Cryptocurrency, double> currentPrices;
  final double totalProfit;
  final double totalPortfolioValue;

  PortfolioSummary({
    required this.holdings,
    required this.currentPrices,
    required this.totalProfit,
    required this.totalPortfolioValue,
  });
}
