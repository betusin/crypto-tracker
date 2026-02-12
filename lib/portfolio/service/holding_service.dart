import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:crypto_tracker/price/service/current_price_controller.dart';
import 'package:crypto_tracker/portfolio/model/portfolio_summary.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:crypto_tracker/transaction/service/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class HoldingService {
  final TransactionService _transactionService;
  final CurrentPriceController _currentPriceController;

  HoldingService(this._transactionService, this._currentPriceController);

  Stream<Map<Cryptocurrency, double>> holdingsByCryprocurrencyStream() {
    return _transactionService.observeTransactionsForCurrentUser().map((transactions) {
      Map<Cryptocurrency, double> holdings = {};

      for (final transaction in transactions) {
        final amount = transaction.type == TransactionType.buy ? transaction.amount : -transaction.amount;
        holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) + amount;
      }
      return holdings;
    });
  }

  Stream<PortfolioSummary> portfolioSummaryStream() {
    return Rx.combineLatest2(
      _transactionService.observeTransactionsForCurrentUser(),
      _currentPriceController.observeCurrentPrices(),
      (transactions, currentPrices) {
        double totalProfit = 0;
        double totalPortfolioValue = 0;
        Map<Cryptocurrency, double> holdings = {};

        for (final transaction in transactions) {
          final currentPrice = currentPrices[transaction.cryptoCurrency] ?? 0;

          final sign = (transaction.type == TransactionType.buy ? 1 : -1);
          final amount = transaction.amount * sign;
          final valueInFiat = amount * currentPrice;
          final profit = valueInFiat - (transaction.priceInEur * sign);

          totalProfit += profit;
          totalPortfolioValue += valueInFiat;
          holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) + amount;
        }

        return PortfolioSummary(
          holdings: holdings,
          currentPrices: currentPrices,
          totalProfit: totalProfit,
          totalPortfolioValue: totalPortfolioValue,
        );
      },
    );
  }
}
