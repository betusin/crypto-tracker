import 'package:crypto_tracker/common/service/refetch_service.dart';
import 'package:crypto_tracker/currency/model/cryptocureny.dart';
import 'package:flutter/material.dart';

class CurrentPriceController {
  final Refetcher<Map<Cryptocurrency, double>> _refetcher;

  CurrentPriceController(this._refetcher);

  Stream<Map<Cryptocurrency, double>> observeCurrentPrices() =>
      _refetcher.stream.handleError((error) => debugPrint('Error: $error'));

  Future<void> fetchCurrentPrices() => _refetcher.refetch();
}
