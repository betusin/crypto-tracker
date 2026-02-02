import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/model/currency.dart';

class PriceService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3/simple/price';

  Future<double> fetchPrice(String cryptoId, {Currency currency = Currency.eur}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?ids=$cryptoId&vs_currencies=${currency.value}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[cryptoId][currency.value] as num).toDouble();
      } else {
        throw Exception('Failed to load price');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<Map<String, double>> fetchCurrentPrices({Currency currency = Currency.eur}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?ids=bitcoin,ethereum&vs_currencies=${currency.value}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'bitcoin': (data['bitcoin'][currency.value] as num).toDouble(),
          'ethereum': (data['ethereum'][currency.value] as num).toDouble(),
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
