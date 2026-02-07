import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:crypto_tracker/price/service/current_price_controller.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:crypto_tracker/transaction/service/transaction_service.dart';
import 'package:rxdart/rxdart.dart';

class HoldingService {
  final TransactionService _transactionService;
  final CurrentPriceController _currentPriceController;

  HoldingService(this._transactionService, this._currentPriceController);

  /// Returns Stream of current holdings grouped by Cryptocurrency
  Stream<Map<Cryptocurrency, double>> holdingsStream() {
    return _transactionService.observeTransactionsForCurrentUser().map((transactions) {
      Map<Cryptocurrency, double> holdings = {};

      for (final transaction in transactions) {
        final amount = transaction.type == TransactionType.buy ? transaction.amount : -transaction.amount;
        holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) + amount;
      }
      return holdings;
    });
  }

  /// Returns Stream of current holdings and prices grouped by Cryptocurrency, total profit and total portfolio value
  Stream<
    (
      Map<Cryptocurrency, double> holdings,
      Map<Cryptocurrency, double> currentPrices,
      double totalProfit,
      double totalPortfolioValue,
    )
  >
  holdingsDataStream() {
    return Rx.combineLatest2(
      _transactionService.observeTransactionsForCurrentUser(),
      _currentPriceController.observeCurrentPrices(),
      (transactions, currentPrices) {
        double totalProfit = 0;
        double totalPortfolioValue = 0;
        Map<Cryptocurrency, double> holdings = {};

        for (final transaction in transactions) {
          final price = currentPrices[transaction.cryptoCurrency] ?? 0;

          final perUnitPrice = transaction.pricePerUnit;
          final amount = transaction.type == TransactionType.buy ? transaction.amount : -transaction.amount;
          final value = amount * price;
          final profit = value - perUnitPrice;

          totalProfit += profit;
          totalPortfolioValue += value;
          holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) + amount;
        }

        return (holdings, currentPrices, totalProfit, totalPortfolioValue);
      },
    );
  }
}
