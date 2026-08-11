import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialChartController', () {
    test('returns a default viewport before attaching', () {
      final FinancialChartController controller = FinancialChartController();
      expect(controller.viewport.visibleSpan, 1);
    });

    test('zoomIn shrinks the visible span and notifies listeners', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(dataLength: 200, minVisibleCandles: 5);
      final double spanBefore = controller.viewport.visibleSpan;

      int notifications = 0;
      controller.addListener(() => notifications++);
      controller.zoomIn();

      expect(controller.viewport.visibleSpan, lessThan(spanBefore));
      expect(notifications, 1);
    });

    test('zoomOut grows the visible span', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(dataLength: 200, minVisibleCandles: 5);
      final double spanBefore = controller.viewport.visibleSpan;

      controller.zoomOut();

      expect(controller.viewport.visibleSpan, greaterThan(spanBefore));
    });

    test('fitContent shows the entire data set', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(dataLength: 200, minVisibleCandles: 5);

      controller.fitContent();

      expect(controller.viewport.startIndex, 0);
      expect(controller.viewport.endIndex, 200);
    });

    test('scrollToLatest moves the viewport to the most recent candles', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(
        dataLength: 200,
        minVisibleCandles: 5,
        initialVisibleCandles: 60,
      );
      controller.fitContent();

      controller.scrollToLatest();

      expect(controller.viewport.endIndex, 200);
      expect(controller.viewport.visibleSpan, closeTo(200, 1e-9));
    });

    test('scrollToLatest respects an explicit visibleCandles override', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(dataLength: 200, minVisibleCandles: 5);

      controller.scrollToLatest(visibleCandles: 20);

      expect(controller.viewport.endIndex, 200);
      expect(controller.viewport.visibleSpan, 20);
    });

    test('resetViewport restores the initial viewport', () {
      final FinancialChartController controller = FinancialChartController();
      controller.syncWithChart(
        dataLength: 200,
        minVisibleCandles: 5,
        initialVisibleCandles: 60,
      );
      controller.fitContent();

      controller.resetViewport();

      expect(controller.viewport.endIndex, 200);
      expect(controller.viewport.visibleSpan, 60);
    });

    test(
      'syncWithChart preserves "scrolled to latest" when new data arrives',
      () {
        final FinancialChartController controller = FinancialChartController();
        controller.syncWithChart(
          dataLength: 100,
          minVisibleCandles: 5,
          initialVisibleCandles: 60,
        );
        expect(controller.viewport.endIndex, 100);

        controller.syncWithChart(dataLength: 110, minVisibleCandles: 5);

        expect(controller.viewport.endIndex, 110);
        expect(controller.viewport.visibleSpan, closeTo(60, 1e-9));
      },
    );

    test(
      'syncWithChart does not follow latest when followLatestOnUpdate is false',
      () {
        final FinancialChartController controller = FinancialChartController();
        controller.syncWithChart(
          dataLength: 100,
          minVisibleCandles: 5,
          initialVisibleCandles: 60,
          followLatestOnUpdate: false,
        );
        expect(controller.viewport.endIndex, 100);

        controller.syncWithChart(
          dataLength: 110,
          minVisibleCandles: 5,
          followLatestOnUpdate: false,
        );

        expect(controller.viewport.endIndex, 100);
        expect(controller.viewport.visibleSpan, closeTo(60, 1e-9));
      },
    );

    test(
      'syncWithChart preserves the scrolled-back position when not at the latest candle',
      () {
        final FinancialChartController controller = FinancialChartController();
        controller.syncWithChart(
          dataLength: 100,
          minVisibleCandles: 5,
          initialVisibleCandles: 60,
        );
        controller.applyGestureViewport(
          const ChartViewport(startIndex: 0, endIndex: 60),
        );

        controller.syncWithChart(dataLength: 110, minVisibleCandles: 5);

        expect(controller.viewport.startIndex, 0);
        expect(controller.viewport.endIndex, 60);
      },
    );
  });
}
