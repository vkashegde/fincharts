import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// The visible window into a candle series, expressed as fractional data
/// indices rather than pixel offsets.
///
/// Using fractional indices (rather than, say, a start timestamp and a
/// pixels-per-candle ratio) keeps panning and zooming resolution-independent
/// and makes "keep the candle under the user's finger stationary" zoom math
/// simple: the same index maps to the same relative position regardless of
/// the widget's current pixel size.
///
/// `ChartViewport` itself only stores the window and knows how to clamp
/// itself against a data length — the actual pan/zoom arithmetic lives in
/// the pure functions in `pan_handler.dart` and `zoom_handler.dart` so it
/// can be unit-tested without a widget tree.
@immutable
class ChartViewport {
  /// Creates a viewport spanning `[startIndex, endIndex)`.
  const ChartViewport({required this.startIndex, required this.endIndex})
    : assert(
        endIndex > startIndex,
        'endIndex ($endIndex) must be greater than startIndex ($startIndex)',
      );

  /// Creates the default initial viewport for a data set of [dataLength]
  /// candles: the most recent [initialVisibleCandles] candles (or all of
  /// them, if there are fewer).
  factory ChartViewport.initial(
    int dataLength, {
    double initialVisibleCandles = 60,
  }) {
    if (dataLength <= 0) return const ChartViewport(startIndex: 0, endIndex: 1);
    final double end = dataLength.toDouble();
    final double visible = math.min(initialVisibleCandles, end);
    final double start = math.max(0, end - visible);
    return ChartViewport(startIndex: start, endIndex: end);
  }

  /// The fractional index of the first visible candle (inclusive).
  final double startIndex;

  /// The fractional index of the last visible candle (exclusive).
  final double endIndex;

  /// The number of candle-widths currently visible.
  double get visibleSpan => endIndex - startIndex;

  /// Returns a copy of this viewport clamped so that:
  /// - it shows at least [minVisibleCandles] and at most [maxVisibleCandles]
  ///   (or the full data length, if smaller),
  /// - it never scrolls past the start or end of the data.
  ChartViewport clamp({
    required int dataLength,
    double minVisibleCandles = 5,
    double? maxVisibleCandles,
  }) {
    if (dataLength <= 0) return this;
    final double dataLen = dataLength.toDouble();
    final double upperBound = math.max(
      minVisibleCandles,
      math.min(maxVisibleCandles ?? dataLen, dataLen),
    );
    final double span = visibleSpan.clamp(minVisibleCandles, upperBound);

    double start = startIndex;
    double end = start + span;
    if (end > dataLen) {
      end = dataLen;
      start = end - span;
    }
    if (start < 0) {
      start = 0;
      end = math.min(dataLen, start + span);
    }
    return ChartViewport(startIndex: start, endIndex: end);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartViewport &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => Object.hash(startIndex, endIndex);

  @override
  String toString() =>
      'ChartViewport(startIndex: $startIndex, endIndex: $endIndex)';
}
