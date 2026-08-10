import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/models/candle.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders the time axis: a horizontal baseline beneath the plot area with
/// dynamically spaced timestamp labels that adapt their granularity to the
/// current zoom level (via `FinancialChartConfig.timeLabelFormatter`), and
/// skip any label that would overlap the previous one.
class TimeAxisRenderer implements ChartRenderer {
  /// Creates a time axis renderer.
  const TimeAxisRenderer();

  static const int _targetLabelCount = 5;

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    if (!context.config.showTimeAxis) return;

    final List<Candle> candles = context.visibleCandles;
    final Rect plotArea = context.plotArea;
    final double axisTop = plotArea.bottom;
    final Color lineColor = context.theme.axis.lineColor;
    final Color labelColor = context.theme.axis.labelColor;
    final double fontSize = context.theme.axis.labelFontSize;

    canvas.drawLine(
      Offset(plotArea.left, axisTop),
      Offset(plotArea.right, axisTop),
      Paint()..color = lineColor,
    );

    if (candles.isEmpty) return;

    final int step = math.max(1, (candles.length / _targetLabelCount).round());
    final Duration approximateLabelSpan = candles.length >= 2
        ? (candles.last.timestamp.difference(candles.first.timestamp) ~/
                  candles.length) *
              step
        : const Duration(days: 1);

    final coordinateSystem = context.coordinateSystem;
    double? previousLabelRight;
    for (int i = 0; i < candles.length; i += step) {
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      if (x < plotArea.left || x > plotArea.right) continue;

      final String text = context.config.timeLabelFormatter.formatAxisLabel(
        candles[i].timestamp,
        approximateLabelSpan,
      );
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: labelColor, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double labelLeft = x - textPainter.width / 2;
      if (previousLabelRight != null && labelLeft < previousLabelRight + 4) {
        continue;
      }
      textPainter.paint(canvas, Offset(labelLeft, axisTop + 6));
      previousLabelRight = labelLeft + textPainter.width;
    }
  }
}
