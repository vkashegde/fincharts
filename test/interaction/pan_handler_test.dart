import 'package:fincharts/fincharts.dart';
import 'package:fincharts/src/interaction/pan_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('applyPan', () {
    test('a positive delta (dragging right) reveals earlier data', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 100,
        endIndex: 160,
      );
      final ChartViewport result = applyPan(
        viewport: viewport,
        deltaIndices: 10,
        dataLength: 200,
      );
      expect(result.startIndex, 90);
      expect(result.endIndex, 150);
    });

    test('a negative delta (dragging left) reveals later data', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 100,
        endIndex: 160,
      );
      final ChartViewport result = applyPan(
        viewport: viewport,
        deltaIndices: -10,
        dataLength: 200,
      );
      expect(result.startIndex, 110);
      expect(result.endIndex, 170);
    });

    test('preserves the zoom level (visible span) while panning', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 100,
        endIndex: 160,
      );
      final ChartViewport result = applyPan(
        viewport: viewport,
        deltaIndices: 500,
        dataLength: 200,
      );
      expect(result.visibleSpan, viewport.visibleSpan);
    });

    test('clamps at the start of the data set', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 10,
        endIndex: 70,
      );
      final ChartViewport result = applyPan(
        viewport: viewport,
        deltaIndices: 1000,
        dataLength: 200,
      );
      expect(result.startIndex, 0);
      expect(result.visibleSpan, 60);
    });

    test('clamps at the end of the data set', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 130,
        endIndex: 190,
      );
      final ChartViewport result = applyPan(
        viewport: viewport,
        deltaIndices: -1000,
        dataLength: 200,
      );
      expect(result.endIndex, 200);
      expect(result.visibleSpan, 60);
    });
  });
}
