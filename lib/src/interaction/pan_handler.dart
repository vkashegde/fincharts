import '../viewport/chart_viewport.dart';

/// Computes the viewport that results from a horizontal pan.
///
/// [deltaIndices] is expressed in data-index units (pixel delta already
/// divided by the current candle width by the caller), not pixels — this
/// keeps the function testable without a widget tree or a real gesture.
///
/// A positive [deltaIndices] (dragging right) reveals earlier data, mirroring
/// how dragging the content of a page to the right reveals what's to its
/// left — so the viewport's start/end indices move backward.
///
/// The result is always clamped to `[0, dataLength]` and to
/// `[minVisibleCandles, maxVisibleCandles]` so panning can never scroll past
/// the ends of the data set or change the zoom level.
ChartViewport applyPan({
  required ChartViewport viewport,
  required double deltaIndices,
  required int dataLength,
  double minVisibleCandles = 5,
  double? maxVisibleCandles,
}) {
  final ChartViewport shifted = ChartViewport(
    startIndex: viewport.startIndex - deltaIndices,
    endIndex: viewport.endIndex - deltaIndices,
  );
  return shifted.clamp(
    dataLength: dataLength,
    minVisibleCandles: minVisibleCandles,
    maxVisibleCandles: maxVisibleCandles,
  );
}
