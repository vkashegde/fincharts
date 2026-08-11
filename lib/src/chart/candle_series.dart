import 'package:flutter/foundation.dart';

import '../core/models/candle.dart';
import 'financial_chart_state.dart';

/// Owns a candle series and notifies listeners on incremental live updates.
///
/// Use this when bars arrive over time (WebSocket ticks, polling, simulated
/// feeds). Pass the series to [FinancialChart.series] so the chart listens
/// and repaints without requiring the host to rebuild with a new `List`
/// identity on every tick.
///
/// ### Typical live-bar flow
///
/// ```dart
/// final series = CandleSeries(historicalBars);
///
/// // Forming bar: same timestamp as the last candle → replaces it.
/// series.update(formingBar);
///
/// // New period opened: newer timestamp → appends.
/// series.update(nextBar);
/// ```
///
/// [update] is the ergonomic entry point for most feeds. Prefer [setData]
/// only for full history reloads (symbol change, timeframe change).
///
/// Like [FinancialChartController], this is a plain [ChangeNotifier] and
/// does not require a particular state-management package.
class CandleSeries extends ChangeNotifier {
  /// Creates a series, optionally seeded with [initial] candles.
  ///
  /// [initial] is normalized once via [normalizeCandleData] (sorted,
  /// deduplicated, non-finite values dropped).
  CandleSeries([List<Candle> initial = const <Candle>[]]) {
    if (initial.isNotEmpty) {
      final NormalizedCandleData result = normalizeCandleData(initial);
      _candles = List<Candle>.of(result.candles);
      _issues = result.issues;
      _version = 1;
    }
  }

  List<Candle> _candles = <Candle>[];
  List<String> _issues = const <String>[];
  int _version = 0;

  /// Monotonic revision bumped on every mutating call.
  ///
  /// [FinancialChart] uses this so [CustomPainter.shouldRepaint] detects
  /// in-place last-bar updates even when the list reference is unchanged.
  int get version => _version;

  /// The current candles, ascending by timestamp.
  ///
  /// Treat as read-only — mutate only through [setData], [update],
  /// [updateLast], [append], or [clear].
  List<Candle> get candles => _candles;

  /// Issues from the most recent [setData] (or construction), if any.
  List<String> get issues => _issues;

  /// Number of candles currently held.
  int get length => _candles.length;

  /// Whether the series has no candles.
  bool get isEmpty => _candles.isEmpty;

  /// Whether the series has at least one candle.
  bool get isNotEmpty => _candles.isNotEmpty;

  /// The most recent candle, or `null` when empty.
  Candle? get lastOrNull => _candles.isEmpty ? null : _candles.last;

  /// Replaces the entire series with a normalized copy of [raw].
  void setData(List<Candle> raw) {
    final NormalizedCandleData result = normalizeCandleData(raw);
    _candles = List<Candle>.of(result.candles);
    _issues = result.issues;
    _bumpAndNotify();
  }

  /// Upserts [candle] for live feeds.
  ///
  /// - Empty series → becomes the first candle.
  /// - Same timestamp as the last candle → replaces the forming bar (O(1)).
  /// - Newer timestamp → appends (O(1) amortized).
  /// - Older / out-of-order timestamp → ignored; returns `false`.
  ///
  /// Non-finite OHLC/volume values are rejected. Negative volume is clamped
  /// to zero. Returns whether the series changed.
  bool update(Candle candle) {
    final Candle? sanitized = _sanitizeIncremental(candle);
    if (sanitized == null) return false;

    if (_candles.isEmpty) {
      _candles.add(sanitized);
      _bumpAndNotify();
      return true;
    }

    final Candle last = _candles.last;
    if (sanitized.timestamp.isAtSameMomentAs(last.timestamp)) {
      _candles[_candles.length - 1] = sanitized;
      _bumpAndNotify();
      return true;
    }
    if (sanitized.timestamp.isAfter(last.timestamp)) {
      _candles.add(sanitized);
      _bumpAndNotify();
      return true;
    }
    return false;
  }

  /// Replaces the last candle. No-ops (returns `false`) when empty, when
  /// [candle] fails sanitization, or when its timestamp differs from the
  /// current last candle's timestamp.
  bool updateLast(Candle candle) {
    if (_candles.isEmpty) return false;
    final Candle? sanitized = _sanitizeIncremental(candle);
    if (sanitized == null) return false;
    if (!sanitized.timestamp.isAtSameMomentAs(_candles.last.timestamp)) {
      return false;
    }
    _candles[_candles.length - 1] = sanitized;
    _bumpAndNotify();
    return true;
  }

  /// Appends [candle] when its timestamp is strictly after the last candle
  /// (or the series is empty). Returns whether the series changed.
  bool append(Candle candle) {
    final Candle? sanitized = _sanitizeIncremental(candle);
    if (sanitized == null) return false;

    if (_candles.isEmpty) {
      _candles.add(sanitized);
      _bumpAndNotify();
      return true;
    }
    if (!sanitized.timestamp.isAfter(_candles.last.timestamp)) {
      return false;
    }
    _candles.add(sanitized);
    _bumpAndNotify();
    return true;
  }

  /// Removes all candles.
  void clear() {
    if (_candles.isEmpty) return;
    _candles = <Candle>[];
    _issues = const <String>[];
    _bumpAndNotify();
  }

  void _bumpAndNotify() {
    _version++;
    notifyListeners();
  }

  /// Validates a single candle for the incremental path. Returns `null` if
  /// the candle cannot be plotted (non-finite values).
  static Candle? _sanitizeIncremental(Candle candle) {
    if (!candle.open.isFinite ||
        !candle.high.isFinite ||
        !candle.low.isFinite ||
        !candle.close.isFinite ||
        !candle.volume.isFinite) {
      return null;
    }
    if (candle.volume < 0) {
      return candle.copyWith(volume: 0);
    }
    return candle;
  }
}
