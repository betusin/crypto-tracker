import 'dart:convert';
import 'package:crypto_tracker/cryptocurrency/enum/cryptocureny.dart';
import 'package:http/http.dart' as http;
import 'package:crypto_tracker/common/model/currency.dart';

class PriceService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3/simple/price';

  Future<Map<Cryptocurrency, double>> fetchCurrentPrices({Currency currency = Currency.eur}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?ids=bitcoin,ethereum&vs_currencies=${currency.value}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          Cryptocurrency.bitcoin: (data[Cryptocurrency.bitcoin.value][currency.value] as num).toDouble(),
          Cryptocurrency.ethereum: (data[Cryptocurrency.ethereum.value][currency.value] as num).toDouble(),
        };
      } else {
        throw Exception('Failed to load prices');
      }
    } catch (e) {
      // Return empty map or cached values in real app, but for now throw
      throw Exception('Failed to connect to API: $e');
    }
  }
}
