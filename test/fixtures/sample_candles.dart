import 'dart:math' as math;

import 'package:fincharts/fincharts.dart';

/// Deterministic, offline synthetic OHLCV data for tests.
///
/// Uses a fixed random seed so output (and any golden images derived from
/// it) is stable across runs and machines.
List<Candle> buildSampleCandles({
  int count = 120,
  DateTime? start,
  double startPrice = 100,
  int seed = 42,
}) {
  final DateTime startTime = start ?? DateTime.utc(2024);
  final math.Random random = math.Random(seed);
  final List<Candle> candles = <Candle>[];

  double price = startPrice;
  for (int i = 0; i < count; i++) {
    final double open = price;
    final double changeFraction = (random.nextDouble() - 0.5) * 0.04;
    double close = open + open * changeFraction;
    if (close < 1) close = 1;

    final double bodyHigh = math.max(open, close);
    final double bodyLow = math.min(open, close);
    final double wickFraction = open * 0.015;
    final double high = bodyHigh + random.nextDouble() * wickFraction;
    final double low = math.max(
      0.01,
      bodyLow - random.nextDouble() * wickFraction,
    );
    final double volume = 1000 + random.nextInt(9000).toDouble();

    candles.add(
      Candle(
        timestamp: startTime.add(Duration(days: i)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ),
    );
    price = close;
  }
  return candles;
}
