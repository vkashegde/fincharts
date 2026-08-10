import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/enums/candle_direction.dart';
import '../core/models/candle.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders open/high/low/close candles as bodies (open→close) with wicks
/// (high→low).
///
/// Bullish candles (`close > open`), bearish candles (`close < open`), and
/// doji candles (`close == open`) are each drawn with their own color from
/// [ChartRenderContext.theme]. Candle and wick width scale with
/// [ChartCoordinateSystem.candleWidth], so bodies stay proportionate at
/// every zoom level.
class CandlestickRenderer implements ChartRenderer {
  /// Creates a candlestick renderer.
  const CandlestickRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final List<Candle> candles = context.visibleCandles;
    if (candles.isEmpty) return;

    final coordinateSystem = context.coordinateSystem;
    final double candleWidth = coordinateSystem.candleWidth;
    final double bodyWidth = math.max(1, candleWidth * 0.7);
    final double wickWidth = math.max(1, candleWidth * 0.14);
    final CandleStyle style = context.theme.candle;

    final Paint bullishBody = Paint()..color = style.bullishColor;
    final Paint bearishBody = Paint()..color = style.bearishColor;
    final Paint dojiBody = Paint()..color = style.dojiColor;
    final Paint bullishWick = Paint()
      ..color = style.bullishWickColor
      ..strokeWidth = wickWidth;
    final Paint bearishWick = Paint()
      ..color = style.bearishWickColor
      ..strokeWidth = wickWidth;

    for (int i = 0; i < candles.length; i++) {
      final Candle candle = candles[i];
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      final double openY = coordinateSystem.priceToY(candle.open);
      final double closeY = coordinateSystem.priceToY(candle.close);
      final double highY = coordinateSystem.priceToY(candle.high);
      final double lowY = coordinateSystem.priceToY(candle.low);

      final CandleDirection direction = candle.direction;
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        direction == CandleDirection.bearish ? bearishWick : bullishWick,
      );

      final Paint bodyPaint = switch (direction) {
        CandleDirection.bullish => bullishBody,
        CandleDirection.bearish => bearishBody,
        CandleDirection.doji => dojiBody,
      };
      final double top = math.min(openY, closeY);
      final double height = math.max(1, (openY - closeY).abs());
      canvas.drawRect(
        Rect.fromLTWH(x - bodyWidth / 2, top, bodyWidth, height),
        bodyPaint,
      );
    }
  }
}
