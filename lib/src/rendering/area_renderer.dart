import 'package:flutter/painting.dart';

import '../core/enums/price_field.dart';
import '../core/models/candle.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders a single price series as a filled area beneath its line, using a
/// top-to-bottom gradient that fades to transparent so the fill stays
/// visually subtle and appropriate for financial dashboards.
class AreaRenderer implements ChartRenderer {
  /// Creates an area renderer.
  const AreaRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final List<Candle> candles = context.visibleCandles;
    if (candles.isEmpty) return;

    final coordinateSystem = context.coordinateSystem;
    final PriceField field = context.config.priceField;
    final AreaSeriesStyle style = context.theme.area;

    final Path linePath = Path();
    final List<Offset> points = <Offset>[];
    for (int i = 0; i < candles.length; i++) {
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      final double y = coordinateSystem.priceToY(field.valueOf(candles[i]));
      points.add(Offset(x, y));
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    final Path fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, context.plotArea.bottom)
      ..lineTo(points.first.dx, context.plotArea.bottom)
      ..close();

    final Shader fillShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[style.topFillColor, style.bottomFillColor],
    ).createShader(context.plotArea);
    canvas.drawPath(fillPath, Paint()..shader = fillShader);

    final Paint linePaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);
  }
}
