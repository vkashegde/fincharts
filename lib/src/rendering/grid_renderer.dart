import 'package:flutter/painting.dart';

import '../core/utilities/nice_scale.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders horizontal gridlines at "nice" price values and evenly spaced
/// vertical gridlines, using [ChartRenderContext.theme]'s grid color.
class GridRenderer implements ChartRenderer {
  /// Creates a grid renderer.
  const GridRenderer();

  static const int _verticalLineCount = 6;

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    if (!context.config.showGrid) return;

    final Rect plotArea = context.plotArea;
    final Paint paint = Paint()
      ..color = context.theme.grid.lineColor
      ..strokeWidth = context.theme.grid.lineWidth;

    final coordinateSystem = context.coordinateSystem;
    final NiceScale scale = NiceScale(
      coordinateSystem.priceMin,
      coordinateSystem.priceMax,
    );
    for (final double price in scale.ticks) {
      final double y = coordinateSystem.priceToY(price);
      if (y < plotArea.top - 1 || y > plotArea.bottom + 1) continue;
      canvas.drawLine(
        Offset(plotArea.left, y),
        Offset(plotArea.right, y),
        paint,
      );
    }

    for (int i = 0; i <= _verticalLineCount; i++) {
      final double x = plotArea.left + plotArea.width * i / _verticalLineCount;
      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        paint,
      );
    }
  }
}
