import 'package:flutter/painting.dart';

import '../core/models/candle.dart';
import '../core/models/crosshair_position.dart';
import '../viewport/chart_coordinate_system.dart';

/// Resolves a raw pointer position within the plot area to the nearest
/// candle, producing a [CrosshairPosition].
///
/// Returns null when [data] is empty (nothing to snap to). The nearest
/// candle is found in O(1) via [ChartCoordinateSystem.xToIndex] followed by
/// rounding — no scan over the data set is required.
CrosshairPosition? resolveCrosshairPosition({
  required Offset localPosition,
  required ChartCoordinateSystem coordinateSystem,
  required List<Candle> data,
}) {
  if (data.isEmpty) return null;

  final double rawIndex = coordinateSystem.xToIndex(localPosition.dx);
  final int nearestIndex = rawIndex.round().clamp(0, data.length - 1);

  return CrosshairPosition(
    dataIndex: nearestIndex,
    candle: data[nearestIndex],
    localPosition: localPosition,
  );
}
