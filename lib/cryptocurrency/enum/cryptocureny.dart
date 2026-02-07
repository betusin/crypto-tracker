enum Cryptocurrency {
  bitcoin('bitcoin', 'BTC'),
  ethereum('ethereum', 'ETH');

  final String value;
  final String symbol;

  const Cryptocurrency(this.value, this.symbol);
}
