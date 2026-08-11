import 'package:flutter/painting.dart';

import '../core/enums/candle_direction.dart';
import '../core/enums/financial_chart_type.dart';
import '../core/models/candle.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders the "this is live" affordance: a dashed horizontal line at the
/// latest candle's closing price plus a filled price tag on the price
/// axis, colored to match the candle's direction.
///
/// Anchored to [ChartRenderContext.latestCandle] — the last candle in the
/// full data set — rather than anything in [ChartRenderContext.visibleCandles],
/// so it stays visible even while the viewport is scrolled back into
/// history, matching how real-time trading charts behave. Colors are
/// intentionally reused from [ChartRenderContext.theme]'s candle and
/// crosshair styling rather than introducing a dedicated style object, so
/// the live price tag always matches the candle palette already in use.
class LivePriceLineRenderer implements ChartRenderer {
  /// Creates a live price line renderer.
  const LivePriceLineRenderer();

  static const double _dashWidth = 4;
  static const double _dashGap = 3;

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    if (!context.config.showLivePriceLine) return;
    if (context.chartType == FinancialChartType.volume) return;

    final Candle? latest = context.latestCandle;
    if (latest == null) return;

    final coordinateSystem = context.coordinateSystem;
    final Rect plotArea = context.plotArea;
    final double y = coordinateSystem.priceToY(latest.close);
    if (y < plotArea.top || y > plotArea.bottom) return;

    final Color color = switch (latest.direction) {
      CandleDirection.bullish => context.theme.candle.bullishColor,
      CandleDirection.bearish => context.theme.candle.bearishColor,
      CandleDirection.doji => context.theme.candle.dojiColor,
    };

    _drawDashedLine(
      canvas,
      Offset(plotArea.left, y),
      Offset(plotArea.right, y),
      color,
    );

    if (context.config.showPriceAxis) {
      _drawPriceTag(canvas, context, y, latest.close, color);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final double totalDistance = end.dx - start.dx;
    double covered = 0;
    while (covered < totalDistance) {
      final double segmentEnd = covered + _dashWidth > totalDistance
          ? totalDistance
          : covered + _dashWidth;
      canvas.drawLine(
        Offset(start.dx + covered, start.dy),
        Offset(start.dx + segmentEnd, start.dy),
        paint,
      );
      covered += _dashWidth + _dashGap;
    }
  }

  void _drawPriceTag(
    Canvas canvas,
    ChartRenderContext context,
    double y,
    double price,
    Color color,
  ) {
    final String text = context.config.priceFormatter.format(price);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: context.theme.crosshair.labelTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const double paddingX = 5;
    const double paddingY = 3;
    final Rect tag = Rect.fromLTWH(
      context.plotArea.right,
      y - textPainter.height / 2 - paddingY,
      textPainter.width + paddingX * 2,
      textPainter.height + paddingY * 2,
    );
    canvas.drawRect(tag, Paint()..color = color);
    textPainter.paint(canvas, Offset(tag.left + paddingX, tag.top + paddingY));
  }
}
