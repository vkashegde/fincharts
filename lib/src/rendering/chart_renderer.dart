import 'package:flutter/painting.dart';

import 'chart_render_context.dart';

/// A single pipeline stage that paints onto the chart's canvas.
///
/// Every visual layer — background, grid, a chart type's series, the
/// volume pane, the crosshair, and each axis — is a `ChartRenderer`.
/// Implementations are stateless and receive everything they need through
/// [ChartRenderContext], which is what allows [FinancialChartPainter] to
/// resolve which renderer paints the main series via a lookup table
/// instead of a `switch` statement scattered through the codebase, and
/// allows future chart types to be added as a new implementation plus one
/// registration, without touching existing renderers.
abstract interface class ChartRenderer {
  /// Paints this stage's contribution to the current frame onto [canvas]
  /// using [context].
  void paint(Canvas canvas, ChartRenderContext context);
}
