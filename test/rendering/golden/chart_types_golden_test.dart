import 'package:fincharts/fincharts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/sample_candles.dart';

/// Golden coverage for the five Week-1 chart types, painted from a fixed
/// seeded fixture at a fixed size and theme.
///
/// Axes, crosshair, and tooltip are disabled here deliberately: they render
/// text via [TextPainter], and font rasterization differs enough across
/// platforms/Flutter versions to make text-bearing goldens flaky across
/// machines. Disabling them keeps this suite focused on what a golden test
/// is actually good at catching — regressions in candle/bar/line/area
/// geometry — without false failures from unrelated font rendering. Axis
/// and crosshair *behavior* (not pixel output) is covered by the widget
/// and unit tests instead.
void main() {
  final List<Candle> data = buildSampleCandles(count: 60);

  const FinancialChartConfig config = FinancialChartConfig(
    showPriceAxis: false,
    showTimeAxis: false,
    crosshair: CrosshairConfig(enabled: false),
  );

  Future<void> pumpGolden(WidgetTester tester, FinancialChartType type) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: SizedBox(
            width: 400,
            height: 240,
            child: FinancialChart(
              data: data,
              type: type,
              config: config,
              theme: FinancialChartThemeData.dark(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final FinancialChartType type in FinancialChartType.values) {
    testWidgets('${type.name} chart matches its golden image', (
      WidgetTester tester,
    ) async {
      await pumpGolden(tester, type);
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/${type.name}.png'),
      );
    });
  }
}
