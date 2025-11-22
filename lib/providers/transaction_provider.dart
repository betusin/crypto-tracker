import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../services/price_service.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  Map<String, double> _currentPrices = {};
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  Map<String, double> get currentPrices => _currentPrices;
  bool get isLoading => _isLoading;

  final DatabaseService _dbService = DatabaseService();
  final PriceService _priceService = PriceService();

  TransactionProvider() {
    loadTransactions();
    fetchCurrentPrices();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _dbService.getTransactions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbService.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbService.deleteTransaction(id);
    await loadTransactions();
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
    for (var tx in _transactions) {
      double currentPrice = _currentPrices[tx.cryptoId] ?? tx.pricePerUnit;
      if (tx.type == TransactionType.buy) {
        total += tx.amount * currentPrice;
      } else {
        total -= tx.amount * currentPrice;
      }
    }
    return total;
  }

  // Simple calculation: (Current Value) - (Net Invested)
  // Net Invested = (Buy Amount * Buy Price) - (Sell Amount * Sell Price)
  double get totalProfit {
    double currentValue = 0;

    // Group by crypto to calculate holdings
    Map<String, double> holdings = {};

    for (var tx in _transactions) {
      if (tx.type == TransactionType.buy) {
        holdings[tx.cryptoId] = (holdings[tx.cryptoId] ?? 0) + tx.amount;
      } else {
        holdings[tx.cryptoId] = (holdings[tx.cryptoId] ?? 0) - tx.amount;
      }
    }

    // Calculate current value of holdings
    holdings.forEach((cryptoId, amount) {
      double price = _currentPrices[cryptoId] ?? 0;
      currentValue += amount * price;
    });

    // Calculate Net Cost (Invested - Sold)
    double netCost = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.buy) {
        netCost += tx.amount * tx.pricePerUnit;
      } else {
        netCost -= tx.amount * tx.pricePerUnit;
      }
    }

    return currentValue - netCost;
  }
}
