import 'package:flutter/painting.dart';

import '../core/utilities/nice_scale.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders the price axis: a vertical baseline to the right of the plot
/// area with "nice" price labels, at dynamic precision (via
/// `FinancialChartConfig.priceFormatter`), skipping any label that would
/// overlap the previous one.
class PriceAxisRenderer implements ChartRenderer {
  /// Creates a price axis renderer.
  const PriceAxisRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    if (!context.config.showPriceAxis) return;

    final Rect plotArea = context.plotArea;
    final double axisLeft = plotArea.right;
    final double axisRight = plotArea.right + context.config.priceAxisWidth;
    final Color lineColor = context.theme.axis.lineColor;
    final Color labelColor = context.theme.axis.labelColor;
    final double fontSize = context.theme.axis.labelFontSize;

    canvas.drawLine(
      Offset(axisLeft, plotArea.top),
      Offset(axisLeft, plotArea.bottom),
      Paint()..color = lineColor,
    );

    final coordinateSystem = context.coordinateSystem;
    final NiceScale scale = NiceScale(
      coordinateSystem.priceMin,
      coordinateSystem.priceMax,
    );

    // Ticks are ascending by price; iterate highest-first so labels are
    // visited top-to-bottom (ascending y) for consistent overlap avoidance.
    double? previousLabelBottom;
    for (final double price in scale.ticks.reversed) {
      final double y = coordinateSystem.priceToY(price);
      if (y < plotArea.top || y > plotArea.bottom) continue;

      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: context.config.priceFormatter.format(price),
          style: TextStyle(color: labelColor, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: axisRight - axisLeft - 8);

      final double labelTop = y - textPainter.height / 2;
      if (previousLabelBottom != null && labelTop < previousLabelBottom + 2) {
        continue;
      }
      textPainter.paint(canvas, Offset(axisLeft + 6, labelTop));
      previousLabelBottom = labelTop + textPainter.height;
    }
  }
}
