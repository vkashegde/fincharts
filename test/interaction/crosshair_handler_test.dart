import 'package:fincharts/fincharts.dart';
import 'package:fincharts/src/interaction/crosshair_handler.dart';
import 'package:fincharts/src/viewport/chart_coordinate_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/sample_candles.dart';

void main() {
  group('resolveCrosshairPosition', () {
    final List<Candle> data = buildSampleCandles(count: 50);
    const Rect plotArea = Rect.fromLTWH(0, 0, 500, 300);
    final ChartCoordinateSystem coordinateSystem = ChartCoordinateSystem(
      plotArea: plotArea,
      viewport: const ChartViewport(startIndex: 0, endIndex: 50),
      priceMin: 0,
      priceMax: 100,
      data: data,
    );

    test('returns null for an empty data set', () {
      final result = resolveCrosshairPosition(
        localPosition: const Offset(100, 50),
        coordinateSystem: coordinateSystem,
        data: const <Candle>[],
      );
      expect(result, isNull);
    });

    test('snaps to the nearest candle index', () {
      final result = resolveCrosshairPosition(
        localPosition: const Offset(0, 50),
        coordinateSystem: coordinateSystem,
        data: data,
      );
      expect(result!.dataIndex, 0);
      expect(result.candle, data[0]);
    });

    test(
      'clamps to the last candle when the pointer is past the right edge',
      () {
        final result = resolveCrosshairPosition(
          localPosition: const Offset(10000, 50),
          coordinateSystem: coordinateSystem,
          data: data,
        );
        expect(result!.dataIndex, data.length - 1);
      },
    );

    test('preserves the raw local position', () {
      const Offset position = Offset(250, 120);
      final result = resolveCrosshairPosition(
        localPosition: position,
        coordinateSystem: coordinateSystem,
        data: data,
      );
      expect(result!.localPosition, position);
    });
  });
}
