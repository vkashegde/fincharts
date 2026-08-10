import 'package:fincharts/fincharts.dart';
import 'package:fincharts/src/interaction/zoom_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyZoom', () {
    test('scaleFactor > 1 shrinks the visible span (zoom in)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 0,
        endIndex: 100,
      );
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 2,
        focalIndex: 50,
        dataLength: 200,
      );
      expect(result.visibleSpan, closeTo(50, 1e-9));
    });

    test('scaleFactor < 1 grows the visible span (zoom out)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 50,
        endIndex: 100,
      );
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 0.5,
        focalIndex: 75,
        dataLength: 200,
      );
      expect(result.visibleSpan, closeTo(100, 1e-9));
    });

    test('keeps the focal index at the same relative position', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 0,
        endIndex: 100,
      );
      const double focalIndex = 25; // 25% through the viewport
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 2,
        focalIndex: focalIndex,
        dataLength: 200,
      );
      final double relativeBefore =
          (focalIndex - viewport.startIndex) / viewport.visibleSpan;
      final double relativeAfter =
          (focalIndex - result.startIndex) / result.visibleSpan;
      expect(relativeAfter, closeTo(relativeBefore, 1e-9));
    });

    test('scaleFactor of exactly 1 is a no-op', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 10,
        endIndex: 70,
      );
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 1,
        focalIndex: 40,
        dataLength: 200,
      );
      expect(result, viewport);
    });

    test('clamps to the minimum visible span (max zoom in)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 0,
        endIndex: 100,
      );
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 1000,
        focalIndex: 50,
        dataLength: 200,
        minVisibleCandles: 5,
      );
      expect(result.visibleSpan, 5);
    });

    test('clamps to the maximum visible span (max zoom out)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 80,
        endIndex: 100,
      );
      final ChartViewport result = applyZoom(
        viewport: viewport,
        scaleFactor: 0.001,
        focalIndex: 90,
        dataLength: 200,
        maxVisibleCandles: 50,
      );
      expect(result.visibleSpan, 50);
    });
  });
}
