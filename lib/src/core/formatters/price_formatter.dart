/// Formats a raw price value into a human-readable string for axis labels,
/// tooltips, and crosshair readouts.
///
/// The chart itself has no notion of currency — implementations decide
/// decimal precision, grouping, and any currency prefix/suffix.
abstract interface class PriceFormatter {
  /// Formats [price] into a display string.
  String format(double price);
}

/// The default [PriceFormatter].
///
/// Precision adapts to the magnitude of the value being formatted (values
/// under 1.0 get an extra decimal digit so small-denomination instruments
/// such as penny stocks or fractional crypto remain legible), and the
/// integer part is grouped with thousands separators. An optional
/// [currencySymbol] (e.g. `'₹'`, `'\$'`) is prefixed when non-empty — the
/// package never hard-codes one.
class DefaultPriceFormatter implements PriceFormatter {
  /// Creates a default price formatter.
  ///
  /// If [decimalDigits] is null, precision is chosen adaptively based on
  /// the magnitude of the value being formatted.
  const DefaultPriceFormatter({this.currencySymbol = '', this.decimalDigits});

  /// An optional prefix such as `'₹'` or `'\$'`. Empty by default.
  final String currencySymbol;

  /// A fixed number of decimal digits, or null to adapt to magnitude.
  final int? decimalDigits;

  @override
  String format(double price) {
    final int digits = decimalDigits ?? _adaptiveDecimalDigits(price);
    final String fixed = price.toStringAsFixed(digits);
    final List<String> parts = fixed.split('.');
    final String groupedInteger = _groupThousands(parts[0]);
    final String result = parts.length > 1
        ? '$groupedInteger.${parts[1]}'
        : groupedInteger;
    return '$currencySymbol$result';
  }

  static int _adaptiveDecimalDigits(double price) {
    final double magnitude = price.abs();
    if (magnitude == 0 || magnitude >= 1) return 2;
    return 3;
  }

  static String _groupThousands(String digits) {
    final bool negative = digits.startsWith('-');
    final String unsigned = negative ? digits.substring(1) : digits;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < unsigned.length; i++) {
      if (i > 0 && (unsigned.length - i) % 3 == 0) buffer.write(',');
      buffer.write(unsigned[i]);
    }
    return negative ? '-$buffer' : buffer.toString();
  }
}
