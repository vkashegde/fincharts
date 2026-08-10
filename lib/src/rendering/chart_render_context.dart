import 'package:flutter/painting.dart';

import '../core/enums/financial_chart_type.dart';
import '../core/models/candle.dart';
import '../core/models/crosshair_position.dart';
import '../chart/financial_chart_config.dart';
import '../theme/financial_chart_theme.dart';
import '../viewport/chart_coordinate_system.dart';

/// Everything a [ChartRenderer] needs to paint a single frame.
///
/// Built once per paint by [FinancialChartPainter] and handed to every
/// pipeline stage. Renderers read from this object only — they never hold
/// state of their own between frames, and never reach outside of it for
/// data, theme, or configuration. This is what keeps renderers pure,
/// stateless, and independently testable.
class ChartRenderContext {
  /// Creates a render context.
  const ChartRenderContext({
    required this.chartType,
    required this.plotArea,
    required this.coordinateSystem,
    required this.visibleCandles,
    required this.visibleStartIndex,
    required this.theme,
    required this.config,
    this.crosshairPosition,
  });

  /// Which chart type is being rendered by the main renderer stage. Axis,
  /// grid, and crosshair stages are shared across all types and read this
  /// only where behavior genuinely differs (e.g. the tooltip always shows
  /// full OHLCV regardless of [chartType]).
  final FinancialChartType chartType;

  /// The pixel rectangle this stage should paint within.
  ///
  /// For the main chart/grid/crosshair stages this is the primary plot
  /// area; for a composited volume pane it is the reserved sub-rectangle
  /// beneath it.
  final Rect plotArea;

  /// The coordinate system for the current viewport and price range.
  final ChartCoordinateSystem coordinateSystem;

  /// The candles currently visible in the viewport (already sliced — never
  /// the full data set).
  final List<Candle> visibleCandles;

  /// The absolute index of `visibleCandles[0]` within the full data set.
  final int visibleStartIndex;

  /// The active theme.
  final FinancialChartThemeData theme;

  /// The active configuration.
  final FinancialChartConfig config;

  /// The current crosshair/hover position, or null if inactive.
  final CrosshairPosition? crosshairPosition;

  /// Returns a copy of this context with the given fields replaced. Used
  /// by [FinancialChartPainter] to re-scope the context (e.g. a different
  /// [plotArea]) for a specific pipeline stage without rebuilding
  /// everything else.
  ChartRenderContext copyWith({
    Rect? plotArea,
    ChartCoordinateSystem? coordinateSystem,
  }) {
    return ChartRenderContext(
      chartType: chartType,
      plotArea: plotArea ?? this.plotArea,
      coordinateSystem: coordinateSystem ?? this.coordinateSystem,
      visibleCandles: visibleCandles,
      visibleStartIndex: visibleStartIndex,
      theme: theme,
      config: config,
      crosshairPosition: crosshairPosition,
    );
  }
}
