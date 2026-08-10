import 'package:flutter/foundation.dart';

import '../enums/candle_direction.dart';

/// A single OHLCV market data point.
///
/// [timestamp] identifies the candle's opening time. [open], [high], [low],
/// and [close] represent price values for the period, and [volume]
/// represents traded volume for the period.
///
/// ### Validation strategy
///
/// `Candle` is a hot-path value created for every data point in a series
/// that may contain tens of thousands of entries, so its constructor must
/// stay allocation-free and branch-free in release builds. It therefore
/// validates its invariants (finite values, non-negative volume, and a
/// consistent high/low relative to open/close) using `assert()` only —
/// these checks run in debug mode to catch integration bugs early, and are
/// compiled out entirely in profile/release builds.
///
/// This means `Candle` itself does **not** protect a release build against
/// malformed data supplied by a host application (e.g. ticks from a flaky
/// broker feed). That responsibility belongs to the data boundary: code
/// that receives untrusted data — such as `FinancialChart`'s internal state
/// — is expected to sanitize it once, when the data set changes, rather
/// than validating it on every candle on every frame. See
/// `FinancialChart`'s documentation for the exact normalization rules it
/// applies (dropping non-finite candles, clamping negative volume,
/// deduplicating timestamps, and sorting).
@immutable
class Candle {
  /// Creates a candle.
  ///
  /// In debug builds, asserts that all values are finite, [volume] is
  /// non-negative, and [high]/[low] are consistent with [open] and [close].
  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  }) : assert(
         open.isFinite &&
             high.isFinite &&
             low.isFinite &&
             close.isFinite &&
             volume.isFinite,
         'Candle values must be finite (no NaN/Infinity): '
         'open=$open, high=$high, low=$low, close=$close, volume=$volume',
       ),
       assert(volume >= 0, 'Candle.volume must not be negative: $volume'),
       assert(
         high >= open && high >= close && high >= low,
         'Candle.high must be >= open, close, and low '
         '(open=$open, high=$high, low=$low, close=$close)',
       ),
       assert(
         low <= open && low <= close && low <= high,
         'Candle.low must be <= open, close, and high '
         '(open=$open, high=$high, low=$low, close=$close)',
       );

  /// The candle's opening timestamp.
  final DateTime timestamp;

  /// The opening price.
  final double open;

  /// The highest traded price during the period.
  final double high;

  /// The lowest traded price during the period.
  final double low;

  /// The closing price.
  final double close;

  /// The traded volume during the period.
  final double volume;

  /// Whether [close] is greater than, less than, or equal to [open].
  CandleDirection get direction {
    if (close > open) return CandleDirection.bullish;
    if (close < open) return CandleDirection.bearish;
    return CandleDirection.doji;
  }

  /// Returns a copy of this candle with the given fields replaced.
  Candle copyWith({
    DateTime? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return Candle(
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Candle &&
        other.timestamp == timestamp &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close &&
        other.volume == volume;
  }

  @override
  int get hashCode => Object.hash(timestamp, open, high, low, close, volume);

  @override
  String toString() {
    return 'Candle(timestamp: $timestamp, open: $open, high: $high, '
        'low: $low, close: $close, volume: $volume)';
  }
}
