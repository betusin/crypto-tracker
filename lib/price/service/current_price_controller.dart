import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:crypto_tracker/price/service/price_service.dart';
import 'package:rxdart/rxdart.dart';

class CurrentPriceController {
  final PriceService _priceService;

  CurrentPriceController(this._priceService) {
    fetchCurrentPrices();
  }

  final _currentPrices = BehaviorSubject<Map<Cryptocurrency, double>>();

  Stream<Map<Cryptocurrency, double>> observeCurrentPrices() => _currentPrices.stream;

  // TODO(betka): implement it so that it automatically refetches every 30 seconds
  Future<void> fetchCurrentPrices() async {
    _currentPrices.add(await _priceService.fetchCurrentPrices());
  }
}
