import 'package:flutter/painting.dart';

import '../core/enums/price_field.dart';
import '../core/models/candle.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders a single price series — by default [Candle.close], configurable
/// via [FinancialChartConfig.priceField] — as a continuous line.
///
/// Builds one [Path] across the visible candles rather than issuing a draw
/// call per point, so cost scales with the number of points on a single
/// `drawPath` call rather than with per-point widget or canvas-call
/// overhead.
class LineRenderer implements ChartRenderer {
  /// Creates a line renderer.
  const LineRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final List<Candle> candles = context.visibleCandles;
    if (candles.isEmpty) return;

    final coordinateSystem = context.coordinateSystem;
    final PriceField field = context.config.priceField;
    final LineSeriesStyle style = context.theme.line;

    final Path path = Path();
    for (int i = 0; i < candles.length; i++) {
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      final double y = coordinateSystem.priceToY(field.valueOf(candles[i]));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint paint = Paint()
      ..color = style.color
      ..strokeWidth = style.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }
}
