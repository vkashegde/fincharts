import 'dart:math' as math;

import 'package:fincharts/fincharts.dart';

/// Generates deterministic, realistic-looking synthetic OHLCV data for the
/// example app.
///
/// This lives in the example app only — `fincharts` itself never generates
/// or fetches data; applications are always responsible for their own
/// market data. Price follows a smooth, bounded multi-cycle wave (rather
/// than an unbounded random walk, which can drift or compound into an
/// unrealistic-looking one-way trend over hundreds of candles) with small
/// per-candle noise layered on top, so the demo consistently shows both
/// bullish and bearish stretches. A fixed [seed] keeps the noise (and
/// therefore on-screen behavior) stable across runs.
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
  for (int i = 0; i < count; i++) {
    final double t = i.toDouble();
    final double wave =
        math.sin(t / 45) * 0.55 +
        math.sin(t / 17 + 1.3) * 0.25 +
        math.sin(t / 90 + 0.6) * 0.35;
    final double target = startPrice * (1 + wave * 0.15);
    // Pull the price toward the smooth target rather than jumping to it,
    // then layer small per-candle noise so consecutive candles vary.
    final double pulled = price + (target - price) * 0.16;
    final double noisyClose =
        pulled + pulled * (random.nextDouble() - 0.5) * 0.012;
    final double open = price;
    final double close = math.max(1, noisyClose);

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

/// Produces the next simulated tick for [previous]: a small random-walk
/// nudge to its close (widening high/low as needed) and a volume bump.
///
/// Used by the live demo to mimic a streaming feed updating the
/// currently-forming candle — this is the "same length, only the last
/// candle changes" update shape `FinancialChart` is built to handle
/// efficiently and without disturbing an active crosshair.
Candle nextLiveTick(Candle previous, math.Random random) {
  final double changeFraction = (random.nextDouble() - 0.5) * 0.006;
  double close = previous.close + previous.close * changeFraction;
  if (close < 1) close = 1;
  return previous.copyWith(
    high: close > previous.high ? close : previous.high,
    low: close < previous.low ? close : previous.low,
    close: close,
    volume: previous.volume + random.nextInt(400),
  );
}

/// Starts a new simulated candle following [previous], opening at its
/// close — used by the live demo to mimic a bar closing and the next one
/// beginning to form. This is the "`data.length` grows by one" update
/// shape; `FinancialChartController` keeps the viewport pinned to the
/// latest candle across it when the user was already scrolled there.
Candle nextLiveCandle(Candle previous, DateTime timestamp) {
  final double open = previous.close;
  return Candle(
    timestamp: timestamp,
    open: open,
    high: open,
    low: open,
    close: open,
    volume: 0,
  );
}
