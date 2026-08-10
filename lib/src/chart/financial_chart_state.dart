import 'package:flutter/foundation.dart';

import '../core/models/candle.dart';

/// The result of [normalizeCandleData]: a data set safe to render, plus a
/// human-readable log of any corrections that were applied.
@immutable
class NormalizedCandleData {
  /// Creates a normalization result.
  const NormalizedCandleData({required this.candles, required this.issues});

  /// The sanitized candle list — ascending by timestamp, no non-finite
  /// values, no negative volume, no duplicate timestamps.
  final List<Candle> candles;

  /// Human-readable descriptions of any correction applied, in the order
  /// they were applied. Empty when the input needed no correction.
  final List<String> issues;
}

/// Sanitizes a raw candle list supplied by a host application into
/// something safe to hand to the rendering pipeline.
///
/// `Candle` itself only validates its invariants via `assert()` (see its
/// documentation) — it does not protect a release build from malformed
/// data. This function is where that protection actually happens, once per
/// data-set change rather than on every frame:
///
/// - Candles with a non-finite (NaN/Infinity) OHLC or volume value are
///   dropped — they cannot be meaningfully plotted.
/// - Negative volume is clamped to zero rather than dropping the candle —
///   the price data is still usable even if volume was corrupted.
/// - The list is sorted ascending by timestamp if it wasn't already.
/// - Duplicate timestamps are deduplicated, keeping the later entry (the
///   common case is a corrected/updated bar re-sent with the same
///   timestamp).
///
/// Called once whenever `FinancialChart.data`'s identity changes, not on
/// every paint — cost is O(n) in the size of the incoming list.
NormalizedCandleData normalizeCandleData(List<Candle> raw) {
  if (raw.isEmpty) {
    return const NormalizedCandleData(candles: <Candle>[], issues: <String>[]);
  }

  final List<String> issues = <String>[];
  final List<Candle> finite = <Candle>[];
  for (final Candle candle in raw) {
    if (!candle.open.isFinite ||
        !candle.high.isFinite ||
        !candle.low.isFinite ||
        !candle.close.isFinite ||
        !candle.volume.isFinite) {
      issues.add(
        'Dropped candle at ${candle.timestamp}: contains a non-finite value.',
      );
      continue;
    }
    if (candle.volume < 0) {
      finite.add(candle.copyWith(volume: 0));
      issues.add('Clamped negative volume to 0 at ${candle.timestamp}.');
    } else {
      finite.add(candle);
    }
  }
  if (finite.isEmpty) {
    return NormalizedCandleData(candles: const <Candle>[], issues: issues);
  }

  bool isSorted = true;
  for (int i = 1; i < finite.length; i++) {
    if (finite[i].timestamp.isBefore(finite[i - 1].timestamp)) {
      isSorted = false;
      break;
    }
  }
  List<Candle> sorted = finite;
  if (!isSorted) {
    sorted = List<Candle>.of(finite)
      ..sort((Candle a, Candle b) => a.timestamp.compareTo(b.timestamp));
    issues.add(
      'Input candles were not sorted by timestamp; sorted defensively.',
    );
  }

  final List<Candle> deduplicated = <Candle>[];
  for (final Candle candle in sorted) {
    if (deduplicated.isNotEmpty &&
        deduplicated.last.timestamp == candle.timestamp) {
      deduplicated[deduplicated.length - 1] = candle;
      issues.add(
        'Duplicate timestamp ${candle.timestamp}; kept the later entry.',
      );
    } else {
      deduplicated.add(candle);
    }
  }

  return NormalizedCandleData(candles: deduplicated, issues: issues);
}
