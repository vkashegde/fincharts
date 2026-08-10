import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartViewport.initial', () {
    test('shows the most recent initialVisibleCandles candles', () {
      final ChartViewport viewport = ChartViewport.initial(
        200,
        initialVisibleCandles: 60,
      );
      expect(viewport.startIndex, 140);
      expect(viewport.endIndex, 200);
      expect(viewport.visibleSpan, 60);
    });

    test(
      'shows the whole data set when it is smaller than initialVisibleCandles',
      () {
        final ChartViewport viewport = ChartViewport.initial(
          10,
          initialVisibleCandles: 60,
        );
        expect(viewport.startIndex, 0);
        expect(viewport.endIndex, 10);
      },
    );

    test('falls back to a 1-wide window for an empty data set', () {
      final ChartViewport viewport = ChartViewport.initial(0);
      expect(viewport.startIndex, 0);
      expect(viewport.endIndex, 1);
    });
  });

  group('ChartViewport.clamp', () {
    test('prevents scrolling before the start of the data', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: -20,
        endIndex: 40,
      );
      final ChartViewport clamped = viewport.clamp(dataLength: 200);
      expect(clamped.startIndex, 0);
      expect(clamped.visibleSpan, 60);
    });

    test('prevents scrolling past the end of the data', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 180,
        endIndex: 240,
      );
      final ChartViewport clamped = viewport.clamp(dataLength: 200);
      expect(clamped.endIndex, 200);
      expect(clamped.visibleSpan, 60);
    });

    test('enforces a minimum visible span (max zoom in)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 100,
        endIndex: 101,
      );
      final ChartViewport clamped = viewport.clamp(
        dataLength: 200,
        minVisibleCandles: 5,
      );
      expect(clamped.visibleSpan, 5);
    });

    test('enforces a maximum visible span (max zoom out)', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 0,
        endIndex: 200,
      );
      final ChartViewport clamped = viewport.clamp(
        dataLength: 200,
        maxVisibleCandles: 50,
      );
      expect(clamped.visibleSpan, 50);
    });

    test('is a no-op for an empty data set', () {
      const ChartViewport viewport = ChartViewport(
        startIndex: 10,
        endIndex: 20,
      );
      final ChartViewport clamped = viewport.clamp(dataLength: 0);
      expect(clamped, viewport);
    });
  });
}
