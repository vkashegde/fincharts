import 'package:fincharts_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page shows navigation to the demo and performance pages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FinChartsExampleApp());
    await tester.pump();

    expect(find.text('Chart demo'), findsOneWidget);
    expect(find.text('Performance'), findsOneWidget);
  });

  testWidgets('tapping "Chart demo" opens the chart demo page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FinChartsExampleApp());
    await tester.pump();

    await tester.tap(find.text('Chart demo'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets(
    'tapping "Live demo" opens the live demo page and ticks without error',
    (WidgetTester tester) async {
      await tester.pumpWidget(const FinChartsExampleApp());
      await tester.pump();

      // Not pumpAndSettle: the live badge's pulse animation repeats
      // forever by design, so it never "settles". Pump past the page
      // route transition manually instead.
      await tester.tap(find.text('Live demo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('LIVE'), findsOneWidget);

      // Let a couple of simulated ticks fire.
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pump(const Duration(milliseconds: 750));
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Pause feed'));
      await tester.pump();
      expect(find.text('PAUSED'), findsOneWidget);

      // Navigate back so the page (and its Timer/AnimationController) is
      // disposed before the test ends.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}
