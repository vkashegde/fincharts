import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'candle.dart';

/// The resolved location of an active crosshair/hover interaction.
///
/// Produced by `crosshair_handler.dart` from a raw pointer position, and
/// consumed by `CrosshairRenderer` to draw guide lines, axis labels, and
/// the OHLCV tooltip. Keeping this as a plain data class (rather than
/// threading raw pixel offsets through the renderer) is what lets the
/// crosshair work identically across every chart type without any
/// renderer-specific coupling.
@immutable
class CrosshairPosition {
  /// Creates a crosshair position.
  const CrosshairPosition({
    required this.dataIndex,
    required this.candle,
    required this.localPosition,
  });

  /// The absolute index (into the full, unsliced data set) of the nearest
  /// candle to the pointer.
  final int dataIndex;

  /// The candle at [dataIndex].
  final Candle candle;

  /// The raw pointer position, in the coordinate space of the chart's
  /// plot area. Used for the horizontal guide line when
  /// `CrosshairConfig.snapToCandle` is false.
  final Offset localPosition;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrosshairPosition &&
        other.dataIndex == dataIndex &&
        other.candle == candle &&
        other.localPosition == localPosition;
  }

  @override
  int get hashCode => Object.hash(dataIndex, candle, localPosition);
}
