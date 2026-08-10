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
}
