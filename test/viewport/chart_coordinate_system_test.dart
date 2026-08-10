import 'package:fincharts/fincharts.dart';
import 'package:fincharts/src/viewport/chart_coordinate_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/sample_candles.dart';

void main() {
  group('ChartCoordinateSystem', () {
    final List<Candle> data = buildSampleCandles(count: 50);
    const Rect plotArea = Rect.fromLTWH(0, 0, 500, 300);
    const ChartViewport viewport = ChartViewport(startIndex: 0, endIndex: 50);

    final ChartCoordinateSystem coordinateSystem = ChartCoordinateSystem(
      plotArea: plotArea,
      viewport: viewport,
      priceMin: 0,
      priceMax: 100,
      data: data,
    );

    test('indexToX and xToIndex round-trip', () {
      for (final double index in <double>[0, 12.5, 25, 49]) {
        final double x = coordinateSystem.indexToX(index);
        expect(coordinateSystem.xToIndex(x), closeTo(index, 1e-9));
      }
    });

    test('priceToY and yToPrice round-trip', () {
      for (final double price in <double>[0, 25, 50, 100]) {
        final double y = coordinateSystem.priceToY(price);
        expect(coordinateSystem.yToPrice(y), closeTo(price, 1e-9));
      }
    });

    test('priceToY maps higher prices to smaller y (inverted axis)', () {
      expect(
        coordinateSystem.priceToY(100),
        lessThan(coordinateSystem.priceToY(0)),
      );
    });

    test(
      'indexToX(0) is the left edge and indexToX(endIndex) is the right edge',
      () {
        expect(coordinateSystem.indexToX(0), plotArea.left);
        expect(coordinateSystem.indexToX(50), plotArea.right);
      },
    );

    test('candleWidth divides the plot width by the visible span', () {
      expect(coordinateSystem.candleWidth, plotArea.width / 50);
    });

    test(
      'timestampToX and xToTimestamp round-trip for an exact candle timestamp',
      () {
        final DateTime timestamp = data[10].timestamp;
        final double x = coordinateSystem.timestampToX(timestamp);
        final DateTime roundTripped = coordinateSystem.xToTimestamp(x);
        expect(roundTripped.difference(timestamp).inSeconds.abs(), lessThan(2));
      },
    );

    test('xToTimestamp clamps to the data set bounds', () {
      expect(
        coordinateSystem.xToTimestamp(plotArea.left - 1000),
        data.first.timestamp,
      );
      expect(
        coordinateSystem.xToTimestamp(plotArea.right + 1000),
        data.last.timestamp,
      );
    });
  });
}
