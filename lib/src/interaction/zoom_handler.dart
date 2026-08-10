import '../viewport/chart_viewport.dart';

/// Computes the viewport that results from a pinch/scale zoom, keeping the
/// candle at [focalIndex] as close as possible to its current relative
/// screen position.
///
/// [scaleFactor] follows Flutter's `ScaleGestureDetector` convention:
/// greater than 1 means the gesture is zooming in (fingers spreading
/// apart), so the visible span shrinks; less than 1 zooms out. A
/// [scaleFactor] of exactly 1 (or non-positive, which cannot occur from a
/// real gesture) is a no-op and returns [viewport] unchanged.
///
/// The result is always clamped to `[0, dataLength]` and to
/// `[minVisibleCandles, maxVisibleCandles]`, which is what enforces the
/// min/max zoom level — exact focal-point preservation is not guaranteed
/// once a clamp boundary is hit, which is expected and matches how bounded
/// scroll/zoom surfaces behave elsewhere in Flutter.
ChartViewport applyZoom({
  required ChartViewport viewport,
  required double scaleFactor,
  required double focalIndex,
  required int dataLength,
  double minVisibleCandles = 5,
  double? maxVisibleCandles,
}) {
  if (scaleFactor <= 0 || scaleFactor == 1) return viewport;

  final double currentSpan = viewport.visibleSpan;
  final double newSpan = currentSpan / scaleFactor;
  final double relativeFocal = currentSpan == 0
      ? 0.5
      : (focalIndex - viewport.startIndex) / currentSpan;

  final double newStart = focalIndex - relativeFocal * newSpan;
  final double newEnd = newStart + newSpan;

  return ChartViewport(startIndex: newStart, endIndex: newEnd).clamp(
    dataLength: dataLength,
    minVisibleCandles: minVisibleCandles,
    maxVisibleCandles: maxVisibleCandles,
  );
}
