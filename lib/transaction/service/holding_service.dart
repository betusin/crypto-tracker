import 'package:crypto_tracker/common/extension/iterable_extension.dart';
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

  // TODO(betka): refactor these, so they take holdings as parameter or create a method that returns all the needed values for Dashboard screen

  Stream<Map<Cryptocurrency, double>> holdingsValueByCryptoStream() {
    return Rx.combineLatest2(holdingsStream(), _currentPriceController.observeCurrentPrices(), (
      holdings,
      currentPrices,
    ) {
      return holdings.map((cryptoId, amount) {
        final price = currentPrices[cryptoId] ?? 0;
        return MapEntry(cryptoId, amount * price);
      });
    });
  }

  Stream<double> totalPortfolioValueStream() {
    return holdingsValueByCryptoStream().sumByValue;
  }

  Stream<Map<Cryptocurrency, double>> totalProfitStreamByCrypto() {
    return Rx.combineLatest2(
      _transactionService.observeTransactionsForCurrentUser(),
      _currentPriceController.observeCurrentPrices(),
      (transactions, currentPrices) {
        Map<Cryptocurrency, double> totalProfit = {};

        for (final transaction in transactions) {
          final price = currentPrices[transaction.cryptoCurrency] ?? 0;

          final perUnitPrice = transaction.pricePerUnit;
          final amount = transaction.type == TransactionType.buy ? transaction.amount : -transaction.amount;
          final profit = (amount * price) - perUnitPrice;

          totalProfit[transaction.cryptoCurrency] = (totalProfit[transaction.cryptoCurrency] ?? 0) + profit;
        }

        return totalProfit;
      },
    );
  }

  Stream<double> totalProfitStream() {
    return totalProfitStreamByCrypto().sumByValue;
  }
}

extension on Stream<Map<Cryptocurrency, double>> {
  Stream<double> get sumByValue => map((holdings) => holdings.values.sum);
}
