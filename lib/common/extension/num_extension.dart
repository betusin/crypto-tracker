extension NumFormatting on num {
  /// Formats a number with spaces as thousand separators.
  /// Example: 12345.67 -> "12 345.67"
  String formatWithSpaces([int fractionDigits = 0]) {
    final str = toStringAsFixed(fractionDigits);
    final parts = str.split('.');

    // Add a space separator every 3 digits purely on the integer side
    parts[0] = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ' ');

    return parts.join('.');
  }
}
