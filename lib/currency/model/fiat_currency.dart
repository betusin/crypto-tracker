import 'package:json_annotation/json_annotation.dart';

enum FiatCurrency {
  @JsonValue('eur')
  eur('eur', '€'),
  @JsonValue('czk')
  czk('czk', 'Kč');

  const FiatCurrency(this.value, this.symbol);

  final String value;
  final String symbol;

  String get displayName => value.toUpperCase();

  static FiatCurrency fromValue(String value) {
    return FiatCurrency.values.firstWhere(
      (currency) => currency.value == value.toLowerCase(),
      orElse: () => FiatCurrency.czk,
    );
  }
}
