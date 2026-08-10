import 'dart:math' as math;

import 'package:fincharts/fincharts.dart';

/// Generates deterministic, realistic-looking synthetic OHLCV data for the
/// example app.
///
/// This lives in the example app only — `fincharts` itself never generates
/// or fetches data; applications are always responsible for their own
/// market data. A fixed [seed] keeps the output (and therefore on-screen
/// behavior) stable across runs.
List<Candle> generateDemoCandles({
  int count = 300,
  DateTime? start,
  double startPrice = 24000,
  Duration interval = const Duration(hours: 1),
  int seed = 7,
}) {
  final DateTime startTime = start ?? DateTime.now().subtract(interval * count);
  final math.Random random = math.Random(seed);
  final List<Candle> candles = <Candle>[];

  double price = startPrice;
  double trend = 0;
  for (int i = 0; i < count; i++) {
    // A slowly wandering trend keeps the walk from looking like pure static
    // noise, closer to how real price series move in runs.
    trend = (trend + (random.nextDouble() - 0.5) * 0.002).clamp(-0.01, 0.01);

    final double open = price;
    final double changeFraction = trend + (random.nextDouble() - 0.5) * 0.01;
    double close = open + open * changeFraction;
    if (close < 1) close = 1;

    final double bodyHigh = math.max(open, close);
    final double bodyLow = math.min(open, close);
    final double wick = open * 0.004;
    final double high = bodyHigh + random.nextDouble() * wick;
    final double low = math.max(0.01, bodyLow - random.nextDouble() * wick);
    final double volume = 50000 + random.nextInt(150000).toDouble();

    candles.add(
      Candle(
        timestamp: startTime.add(interval * i),
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
