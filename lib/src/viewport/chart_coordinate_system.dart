import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../core/models/candle.dart';
import 'chart_viewport.dart';

/// Converts between data space (candle index / price / timestamp) and
/// screen space (pixel offsets within the chart's plot area).
///
/// All coordinate math for every renderer, gesture handler, and axis lives
/// here — nowhere else in the package computes a pixel offset from a price
/// or index directly. Instances are cheap value objects (a handful of
/// doubles plus a reference to the current data list) rebuilt once per
/// paint; they perform no allocation beyond themselves.
@immutable
class ChartCoordinateSystem {
  /// Creates a coordinate system.
  ///
  /// [data] must be the full (unsliced) candle list sorted ascending by
  /// timestamp — it's used only for timestamp/index conversions via binary
  /// search, which is O(log n) and safe to call from gesture handlers.
  const ChartCoordinateSystem({
    required this.plotArea,
    required this.viewport,
    required this.priceMin,
    required this.priceMax,
    required this.data,
  });

  /// The pixel rectangle candles are plotted within (excludes axes).
  final Rect plotArea;

  /// The current visible data-index window.
  final ChartViewport viewport;

  /// The minimum price mapped to the bottom of [plotArea].
  final double priceMin;

  /// The maximum price mapped to the top of [plotArea].
  final double priceMax;

  /// The full candle data set, sorted ascending by timestamp.
  final List<Candle> data;

  /// Converts a fractional candle index to an x pixel offset.
  double indexToX(double index) {
    final double span = viewport.visibleSpan;
    if (span == 0) return plotArea.left;
    final double t = (index - viewport.startIndex) / span;
    return plotArea.left + t * plotArea.width;
  }

  /// Converts an x pixel offset to a fractional candle index.
  double xToIndex(double x) {
    if (plotArea.width == 0) return viewport.startIndex;
    final double t = (x - plotArea.left) / plotArea.width;
    return viewport.startIndex + t * viewport.visibleSpan;
  }

  /// Converts a price to a y pixel offset (higher prices map to smaller y).
  double priceToY(double price) {
    final double span = priceMax - priceMin;
    if (span == 0) return plotArea.center.dy;
    final double t = (price - priceMin) / span;
    return plotArea.bottom - t * plotArea.height;
  }

  /// Converts a y pixel offset to a price.
  double yToPrice(double y) {
    if (plotArea.height == 0) return priceMin;
    final double t = (plotArea.bottom - y) / plotArea.height;
    return priceMin + t * (priceMax - priceMin);
  }

  /// Converts a timestamp to an x pixel offset, interpolating between the
  /// two nearest candles if it falls between them.
  double timestampToX(DateTime timestamp) =>
      indexToX(_indexForTimestamp(timestamp));

  /// Converts an x pixel offset to the timestamp implied by the candle
  /// index at that offset, interpolating between neighboring candles.
  DateTime xToTimestamp(double x) => _timestampForIndex(xToIndex(x));

  /// The width in pixels of a single candle slot at the current zoom level.
  double get candleWidth {
    final double span = viewport.visibleSpan;
    return span == 0 ? 0 : plotArea.width / span;
  }

  double _indexForTimestamp(DateTime timestamp) {
    if (data.isEmpty) return 0;
    final int ms = timestamp.millisecondsSinceEpoch;
    final int lastIndex = data.length - 1;
    if (ms <= data[0].timestamp.millisecondsSinceEpoch) return 0;
    if (ms >= data[lastIndex].timestamp.millisecondsSinceEpoch) {
      return lastIndex.toDouble();
    }

    int lo = 0;
    int hi = lastIndex;
    while (hi - lo > 1) {
      final int mid = (lo + hi) >> 1;
      if (data[mid].timestamp.millisecondsSinceEpoch <= ms) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final int loMs = data[lo].timestamp.millisecondsSinceEpoch;
    final int hiMs = data[hi].timestamp.millisecondsSinceEpoch;
    if (hiMs == loMs) return lo.toDouble();
    return lo + (ms - loMs) / (hiMs - loMs);
  }

  DateTime _timestampForIndex(double index) {
    if (data.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    final int lastIndex = data.length - 1;
    // Clamp before interpolating so an out-of-range index (e.g. a pointer
    // far outside the plot area) resolves to the nearest bound instead of
    // extrapolating wildly past it.
    final double clampedIndex = index.clamp(0, lastIndex.toDouble());
    final int lower = clampedIndex.floor().clamp(0, lastIndex);
    final int upper = (lower + 1).clamp(0, lastIndex);
    if (lower == upper) return data[lower].timestamp;
    final double frac = clampedIndex - lower;
    final int loMs = data[lower].timestamp.millisecondsSinceEpoch;
    final int hiMs = data[upper].timestamp.millisecondsSinceEpoch;
    final int ms = (loMs + (hiMs - loMs) * frac).round();
    return DateTime.fromMillisecondsSinceEpoch(
      ms,
      isUtc: data[lower].timestamp.isUtc,
    );
  }
}
