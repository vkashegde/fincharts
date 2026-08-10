import '../models/candle.dart';

/// Selects which OHLC field of a [Candle] a single-value series (such as
/// [FinancialChartType.line] or [FinancialChartType.area]) should plot.
enum PriceField {
  /// Plots [Candle.open].
  open,

  /// Plots [Candle.high].
  high,

  /// Plots [Candle.low].
  low,

  /// Plots [Candle.close].
  close;

  /// Reads the value of this field from [candle].
  double valueOf(Candle candle) {
    switch (this) {
      case PriceField.open:
        return candle.open;
      case PriceField.high:
        return candle.high;
      case PriceField.low:
        return candle.low;
      case PriceField.close:
        return candle.close;
    }
  }
}
