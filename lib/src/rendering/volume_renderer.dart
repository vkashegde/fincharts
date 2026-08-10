import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/enums/candle_direction.dart';
import '../core/models/candle.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders traded volume as bars, colored by each candle's direction.
///
/// Independent of the main series renderer selection: usable standalone
/// via `FinancialChartType.volume` (in which case [ChartRenderContext.plotArea]
/// is the full plot area), or composited as a bottom sub-pane beneath any
/// other chart type via `FinancialChartConfig.showVolumePane` (in which
/// case [ChartRenderContext.plotArea] is the reserved sub-rectangle). Bar
/// heights are scaled against the maximum volume within the *visible*
/// window, not the whole data set, so the pane stays legible at every zoom
/// level.
class VolumeRenderer implements ChartRenderer {
  /// Creates a volume renderer.
  const VolumeRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final List<Candle> candles = context.visibleCandles;
    if (candles.isEmpty) return;

    double maxVolume = 0;
    for (final Candle candle in candles) {
      if (candle.volume > maxVolume) maxVolume = candle.volume;
    }
    if (maxVolume <= 0) return;

    final coordinateSystem = context.coordinateSystem;
    final double barWidth = math.max(1, coordinateSystem.candleWidth * 0.7);
    final VolumeStyle style = context.theme.volume;
    final Paint bullishPaint = Paint()..color = style.bullishColor;
    final Paint bearishPaint = Paint()..color = style.bearishColor;

    final double bottom = context.plotArea.bottom;
    final double paneHeight = context.plotArea.height;

    for (int i = 0; i < candles.length; i++) {
      final Candle candle = candles[i];
      final int absoluteIndex = context.visibleStartIndex + i;
      final double x = coordinateSystem.indexToX(absoluteIndex + 0.5);
      final double barHeight = math.max(
        1,
        paneHeight * (candle.volume / maxVolume),
      );
      final Paint paint = candle.direction == CandleDirection.bearish
          ? bearishPaint
          : bullishPaint;
      canvas.drawRect(
        Rect.fromLTWH(
          x - barWidth / 2,
          bottom - barHeight,
          barWidth,
          barHeight,
        ),
        paint,
      );
    }
  }
}
