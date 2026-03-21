import 'dart:convert';
import 'package:http/http.dart' as http;

class FiatCurrencyService {
  static const String _frankfurterUrl = 'https://api.frankfurter.dev/v1/latest';

  Future<double> getEurToCzkRate() async {
    try {
      final response = await http.get(Uri.parse('$_frankfurterUrl?base=EUR&symbols=CZK'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['rates']['CZK'] as num).toDouble();
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      // Fallback rate if offline or API changes
      return 24.45; // Approximation at 21.3.2026
    }
  }
}
