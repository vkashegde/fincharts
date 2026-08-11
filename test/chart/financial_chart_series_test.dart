import 'package:fincharts/fincharts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/sample_candles.dart';

Widget _wrap(Widget child, {double width = 400, double height = 300}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(width: width, height: height, child: child),
  );
}

void main() {
  group('FinancialChart with CandleSeries', () {
    testWidgets('renders from an attached CandleSeries', (
      WidgetTester tester,
    ) async {
      final CandleSeries series = CandleSeries(
        buildSampleCandles(count: 40),
      );
      addTearDown(series.dispose);

      await tester.pumpWidget(
        _wrap(FinancialChart(series: series)),
      );
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('repaints when the forming bar is updated', (
      WidgetTester tester,
    ) async {
      final List<Candle> seed = buildSampleCandles(count: 40);
      final CandleSeries series = CandleSeries(seed);
      addTearDown(series.dispose);
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(FinancialChart(series: series, controller: controller)),
      );
      await tester.pump();
      expect(controller.dataLength, 40);

      final Candle last = series.lastOrNull!;
      series.update(
        last.copyWith(
          high: last.high + 5,
          close: last.close + 2,
          volume: last.volume + 100,
        ),
      );
      await tester.pump();

      expect(controller.dataLength, 40);
      expect(tester.takeException(), isNull);
    });

    testWidgets('follows latest when a new bar is appended', (
      WidgetTester tester,
    ) async {
      final List<Candle> seed = buildSampleCandles(count: 40);
      final CandleSeries series = CandleSeries(seed);
      addTearDown(series.dispose);
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          FinancialChart(
            series: series,
            controller: controller,
            config: const FinancialChartConfig(followLatestOnUpdate: true),
          ),
        ),
      );
      await tester.pump();
      expect(controller.viewport.endIndex, 40);

      final Candle last = series.lastOrNull!;
      series.update(
        Candle(
          timestamp: last.timestamp.add(const Duration(minutes: 1)),
          open: last.close,
          high: last.close + 1,
          low: last.close - 1,
          close: last.close + 0.5,
          volume: 100,
        ),
      );
      await tester.pump();

      expect(controller.dataLength, 41);
      expect(controller.viewport.endIndex, 41);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'does not advance viewport when followLatestOnUpdate is false',
      (WidgetTester tester) async {
        final List<Candle> seed = buildSampleCandles(count: 80);
        final CandleSeries series = CandleSeries(seed);
        addTearDown(series.dispose);
        final FinancialChartController controller = FinancialChartController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(
            FinancialChart(
              series: series,
              controller: controller,
              config: const FinancialChartConfig(followLatestOnUpdate: false),
            ),
          ),
        );
        await tester.pump();
        expect(controller.viewport.endIndex, 80);

        final Candle last = series.lastOrNull!;
        series.append(
          Candle(
            timestamp: last.timestamp.add(const Duration(minutes: 1)),
            open: last.close,
            high: last.close + 1,
            low: last.close - 1,
            close: last.close,
            volume: 50,
          ),
        );
        await tester.pump();

        expect(controller.dataLength, 81);
        // Still showing the previous right edge — not pinned to 81.
        expect(controller.viewport.endIndex, 80);
      },
    );
  });
}
