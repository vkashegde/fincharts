import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/enums/candle_direction.dart';
import '../core/models/candle.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders traditional OHLC bars: a vertical high→low line with a left tick
/// at the open price and a right tick at the close price.
///
/// Deliberately independent of [CandlestickRenderer] — both consume the
/// same [Candle] data, but OHLC has no notion of a filled "body", so it is
/// implemented as its own renderer rather than a variant of the
/// candlestick one.
class OhlcRenderer implements ChartRenderer {
  /// Creates an OHLC renderer.
  const OhlcRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final List<Candle> candles = context.visibleCandles;
    if (candles.isEmpty) return;

    final coordinateSystem = context.coordinateSystem;
    final double candleWidth = coordinateSystem.candleWidth;
    final double tickLength = math.max(2, candleWidth * 0.4);
    final double strokeWidth = math.max(1, candleWidth * 0.16);
    final CandleStyle style = context.theme.candle;

    final Paint bullishPaint = Paint()
      ..color = style.bullishColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Paint bearishPaint = Paint()
      ..color = style.bearishColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Paint dojiPaint = Paint()
      ..color = style.dojiColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < candles.length; i++) {
      final Candle candle = candles[i];
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      final double openY = coordinateSystem.priceToY(candle.open);
      final double closeY = coordinateSystem.priceToY(candle.close);
      final double highY = coordinateSystem.priceToY(candle.high);
      final double lowY = coordinateSystem.priceToY(candle.low);

      final Paint paint = switch (candle.direction) {
        CandleDirection.bullish => bullishPaint,
        CandleDirection.bearish => bearishPaint,
        CandleDirection.doji => dojiPaint,
      };

      canvas.drawLine(Offset(x, highY), Offset(x, lowY), paint);
      canvas.drawLine(Offset(x - tickLength, openY), Offset(x, openY), paint);
      canvas.drawLine(Offset(x, closeY), Offset(x + tickLength, closeY), paint);
    }
  }
}
