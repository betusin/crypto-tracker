enum Currency {
  usd('usd', '\$'),
  eur('eur', '€');

  const Currency(this.value, this.symbol);

  final String value;
  final String symbol;

  String get displayName => value.toUpperCase();

  static Currency fromValue(String value) {
    return Currency.values.firstWhere((currency) => currency.value == value.toLowerCase(), orElse: () => Currency.eur);
  }
}
