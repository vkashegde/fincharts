import 'package:flutter/foundation.dart';

import '../core/models/candle.dart';
import 'chart_viewport.dart';

/// A concrete, integer slice of a candle list resolved from a fractional
/// [ChartViewport].
///
/// This is the boundary between the resolution-independent viewport and the
/// renderers: renderers only ever see [slice], never the full data set, so
/// painting cost stays proportional to what's on screen regardless of how
/// large the underlying data set is.
@immutable
class VisibleRange {
  const VisibleRange._({required this.startIndex, required this.endIndex});

  /// Resolves [viewport] against a data set of [dataLength] candles.
  factory VisibleRange.resolve(ChartViewport viewport, int dataLength) {
    if (dataLength <= 0) {
      return const VisibleRange._(startIndex: 0, endIndex: 0);
    }
    final int start = viewport.startIndex.floor().clamp(0, dataLength);
    final int end = viewport.endIndex.ceil().clamp(0, dataLength);
    return VisibleRange._(
      startIndex: start,
      endIndex: end < start ? start : end,
    );
  }

  /// The first visible index (inclusive).
  final int startIndex;

  /// The last visible index (exclusive).
  final int endIndex;

  /// The number of visible candles.
  int get length => endIndex - startIndex;

  /// Whether there are no visible candles (e.g. an empty data set).
  bool get isEmpty => length <= 0;

  /// Returns the visible slice of [data]. This is an O(length) copy of just
  /// the visible portion, never the full list.
  List<Candle> slice(List<Candle> data) {
    if (isEmpty) return const <Candle>[];
    return data.sublist(startIndex, endIndex);
  }
}
