import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:crypto_tracker/transaction/model/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/transaction/model/transaction_model.dart';
import 'package:crypto_tracker/transaction/service/database_service.dart';
import 'package:crypto_tracker/price/service/price_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  Map<Cryptocurrency, double> _currentPrices = {};
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  Map<Cryptocurrency, double> get currentPrices => _currentPrices;
  bool get isLoading => _isLoading;

  final DatabaseService _dbService = DatabaseService();
  final PriceService _priceService = PriceService();

  TransactionProvider() {
    fetchCurrentPrices();
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _dbService.getTransactions(userId);
    _isLoading = false;
    notifyListeners();
  }

  // TODO(betka): this should not be here, it should be inside the db service and loadTransactions should not be needed
  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbService.addTransaction(transaction);
    await loadTransactions(transaction.userId);
  }

  Future<void> deleteTransaction(String id, String userId) async {
    await _dbService.deleteTransaction(id);
    await loadTransactions(userId);
  }

  Future<void> fetchCurrentPrices() async {
    // try {
    _currentPrices = await _priceService.fetchCurrentPrices();
    notifyListeners();
    // debugPrint('Error fetching prices: $e');
    // }
  }

  double get totalPortfolioValue {
    double total = 0;

    for (final transaction in _transactions) {
      double currentPrice = _currentPrices[transaction.cryptoCurrency] ?? transaction.pricePerUnit;
      if (transaction.type == TransactionType.buy) {
        total += transaction.amount * currentPrice;
      } else {
        total -= transaction.amount * currentPrice;
      }
    }
    return total;
  }

  Map<Cryptocurrency, double> get holdings {
    Map<Cryptocurrency, double> holdings = {};

    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.buy) {
        holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) + transaction.amount;
      } else {
        holdings[transaction.cryptoCurrency] = (holdings[transaction.cryptoCurrency] ?? 0) - transaction.amount;
      }
    }
    return holdings;
  }

  /// Profit calculated as current value of holdings minus cost of holdings
  double get totalProfit {
    // TODO(betka): reuse totalPortfolioValue (for now currentValue is more precise in double)
    double currentValue = 0;
    holdings.forEach((cryptoId, amount) {
      final price = _currentPrices[cryptoId] ?? 0;
      currentValue += amount * price;
    });

    final cost = _transactions.fold(
      0.0,
      (acc, transaction) => acc + (transaction.pricePerUnit * (transaction.type == TransactionType.buy ? 1 : -1)),
    );

    return currentValue - cost;
  }
}
