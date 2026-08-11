import 'package:fincharts/fincharts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/sample_candles.dart';

Widget _wrap(Widget child, {double width = 400, double height = 300}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(width: width, height: height, child: child),
  );
}

/// Pumps [child] wrapped to an exact [width]x[height].
///
/// `tester.pumpWidget` gives the root widget tight constraints matching
/// the full test surface (800x600 by default) — an inner `SizedBox`
/// asking to be *smaller* than a tight parent can't actually shrink, so
/// tests that depend on precise pixel-to-candle-index mapping must shrink
/// the surface itself first.
Future<void> _pumpSizedChart(
  WidgetTester tester,
  Widget child, {
  double width = 400,
  double height = 300,
}) async {
  await tester.binding.setSurfaceSize(Size(width, height));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(child, width: width, height: height));
}

/// Bumps a candle's close price while keeping OHLC invariants valid, to
/// simulate a live tick in tests.
Candle _tick(Candle candle, double delta) {
  final double close = candle.close + delta;
  return candle.copyWith(
    close: close,
    high: close > candle.high ? close : candle.high,
  );
}

void main() {
  final List<Candle> data = buildSampleCandles(count: 80);

  group('FinancialChart', () {
    for (final FinancialChartType type in FinancialChartType.values) {
      testWidgets('renders ${type.name} without error', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_wrap(FinancialChart(data: data, type: type)));
        await tester.pump();

        expect(find.byType(CustomPaint), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('shows the default empty state when data is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const FinancialChart(data: <Candle>[])));
      await tester.pump();

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('uses a custom emptyStateBuilder when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FinancialChart(
            data: const <Candle>[],
            emptyStateBuilder: (BuildContext context) =>
                const Text('Nothing to show'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Nothing to show'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
    });

    testWidgets('reports data issues for malformed input via onDataIssues', (
      WidgetTester tester,
    ) async {
      final DateTime t = DateTime.utc(2024);
      final List<Candle> malformed = <Candle>[
        Candle(
          timestamp: t.add(const Duration(days: 1)),
          open: 10,
          high: 11,
          low: 9,
          close: 10,
          volume: 100,
        ),
        Candle(
          timestamp: t,
          open: 10,
          high: 11,
          low: 9,
          close: 10,
          volume: 100,
        ),
      ];
      List<String>? reportedIssues;

      await tester.pumpWidget(
        _wrap(
          FinancialChart(
            data: malformed,
            onDataIssues: (List<String> issues) => reportedIssues = issues,
          ),
        ),
      );
      await tester.pump();

      expect(reportedIssues, isNotNull);
      expect(
        reportedIssues!.any((String issue) => issue.contains('not sorted')),
        isTrue,
      );
    });

    testWidgets('an attached controller reflects the chart data length', (
      WidgetTester tester,
    ) async {
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(FinancialChart(data: data, controller: controller)),
      );
      await tester.pump();

      expect(controller.dataLength, data.length);
    });

    testWidgets('controller.zoomIn shrinks the viewport and repaints', (
      WidgetTester tester,
    ) async {
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(FinancialChart(data: data, controller: controller)),
      );
      await tester.pump();
      final double spanBefore = controller.viewport.visibleSpan;

      controller.zoomIn();
      await tester.pump();

      expect(controller.viewport.visibleSpan, lessThan(spanBefore));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'mouse-wheel scroll zooms the viewport (desktop/trackpad zoom)',
      (WidgetTester tester) async {
        final FinancialChartController controller = FinancialChartController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(FinancialChart(data: data, controller: controller)),
        );
        await tester.pump();
        final double spanBefore = controller.viewport.visibleSpan;

        final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
        await tester.sendEventToBinding(pointer.hover(const Offset(200, 150)));
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, -300)));
        await tester.pump();

        expect(controller.viewport.visibleSpan, lessThan(spanBefore));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('mouse-wheel scroll does nothing when enableZoom is false', (
      WidgetTester tester,
    ) async {
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          FinancialChart(
            data: data,
            controller: controller,
            config: const FinancialChartConfig(enableZoom: false),
          ),
        ),
      );
      await tester.pump();
      final ChartViewport before = controller.viewport;

      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(const Offset(200, 150)));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -300)));
      await tester.pump();

      expect(controller.viewport, before);
    });

    testWidgets('horizontal drag pans the viewport when enablePan is true', (
      WidgetTester tester,
    ) async {
      final FinancialChartController controller = FinancialChartController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(FinancialChart(data: data, controller: controller)),
      );
      await tester.pump();
      final double startIndexBefore = controller.viewport.startIndex;

      await tester.drag(find.byType(FinancialChart), const Offset(-150, 0));
      await tester.pump();

      expect(controller.viewport.startIndex, isNot(startIndexBefore));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'horizontal drag does not move the viewport when enablePan is false',
      (WidgetTester tester) async {
        final FinancialChartController controller = FinancialChartController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(
            FinancialChart(
              data: data,
              controller: controller,
              config: const FinancialChartConfig(
                enablePan: false,
                enableZoom: false,
              ),
            ),
          ),
        );
        await tester.pump();
        final ChartViewport before = controller.viewport;

        await tester.drag(find.byType(FinancialChart), const Offset(-150, 0));
        await tester.pump();

        expect(controller.viewport, before);
      },
    );

    testWidgets('long-press-drag activates the crosshair without throwing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(FinancialChart(data: data)));
      await tester.pump();

      final TestGesture gesture = await tester.startGesture(
        const Offset(200, 150),
      );
      await tester.pump(const Duration(seconds: 1));
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('rebuilds cleanly when data is replaced with a new list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(FinancialChart(data: data)));
      await tester.pump();

      final List<Candle> moreData = buildSampleCandles(count: 100, seed: 7);
      await tester.pumpWidget(_wrap(FinancialChart(data: moreData)));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    group('live data updates', () {
      const DefaultPriceFormatter formatter = DefaultPriceFormatter();

      testWidgets(
        'an active crosshair is not cleared by an unrelated live tick',
        (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();

          await _pumpSizedChart(tester, FinancialChart(data: data));

          // Hover (mouse) a candle in the middle of the series (not the
          // live tail), so its price is distinguishable from
          // data.last.close. Unlike a touch long-press, a mouse hover has
          // no "up" event to release, so it stays active across the
          // subsequent data update below — matching how a desktop/web user
          // actually watches a live chart.
          final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
          await tester.sendEventToBinding(
            pointer.hover(const Offset(180, 150)),
          );
          await tester.pump();
          final String hoveredValue = tester
              .getSemantics(find.byType(FinancialChart))
              .value;

          // Simulate a live tick: same length, only the last candle changes.
          final List<Candle> ticked = List<Candle>.of(data);
          ticked[ticked.length - 1] = _tick(ticked.last, 500);
          await tester.pumpWidget(_wrap(FinancialChart(data: ticked)));
          await tester.pump();

          final String valueAfterTick = tester
              .getSemantics(find.byType(FinancialChart))
              .value;
          expect(valueAfterTick, hoveredValue);
          expect(
            valueAfterTick,
            isNot(contains(formatter.format(ticked.last.close))),
          );
          handle.dispose();
        },
      );

      testWidgets(
        'hovering the live (last) candle reflects each tick, not a stale snapshot',
        (WidgetTester tester) async {
          final SemanticsHandle handle = tester.ensureSemantics();

          await _pumpSizedChart(tester, FinancialChart(data: data));

          final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
          await tester.sendEventToBinding(
            pointer.hover(const Offset(330, 150)),
          );
          await tester.pump();

          final List<Candle> ticked = List<Candle>.of(data);
          ticked[ticked.length - 1] = _tick(ticked.last, 500);
          await tester.pumpWidget(_wrap(FinancialChart(data: ticked)));
          await tester.pump();

          final String value = tester
              .getSemantics(find.byType(FinancialChart))
              .value;
          expect(value, contains(formatter.format(ticked.last.close)));
          handle.dispose();
        },
      );
    });

    testWidgets(
      'showLivePriceLine renders without error for every chart type',
      (WidgetTester tester) async {
        for (final FinancialChartType type in FinancialChartType.values) {
          await tester.pumpWidget(
            _wrap(
              FinancialChart(
                data: data,
                type: type,
                config: const FinancialChartConfig(showLivePriceLine: true),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      },
    );
  });
}
