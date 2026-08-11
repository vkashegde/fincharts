import 'package:flutter/rendering.dart';

import '../chart/financial_chart_config.dart';
import '../core/enums/financial_chart_type.dart';
import '../core/models/candle.dart';
import '../core/models/crosshair_position.dart';
import '../theme/financial_chart_theme.dart';
import '../viewport/chart_coordinate_system.dart';
import '../viewport/chart_viewport.dart';
import '../viewport/visible_range.dart';
import 'area_renderer.dart';
import 'candlestick_renderer.dart';
import 'chart_layout.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';
import 'crosshair_renderer.dart';
import 'grid_renderer.dart';
import 'line_renderer.dart';
import 'ohlc_renderer.dart';
import 'price_axis_renderer.dart';
import 'time_axis_renderer.dart';
import 'volume_renderer.dart';

/// Orchestrates the full rendering pipeline for a single frame:
/// background → grid → main series → volume pane (if composited) →
/// crosshair → price axis → time axis.
///
/// The main series renderer is resolved from [FinancialChartType] via a
/// lookup table rather than a `switch`, so adding a new chart type in a
/// future release means adding one map entry, not touching this class.
class FinancialChartPainter extends CustomPainter {
  /// Creates a financial chart painter.
  FinancialChartPainter({
    required this.data,
    required this.chartType,
    required this.viewport,
    required this.theme,
    required this.config,
    this.dataVersion = 0,
    this.crosshairPosition,
  });

  /// The full (unsliced) candle data set, sorted ascending by timestamp.
  final List<Candle> data;

  /// Revision from [CandleSeries.version] (or a host-managed counter) so
  /// in-place last-bar updates still trigger a repaint when [data]'s list
  /// identity is unchanged.
  final int dataVersion;

  /// Which chart type's renderer paints the main series.
  final FinancialChartType chartType;

  /// The current visible data-index window.
  final ChartViewport viewport;

  /// The active theme.
  final FinancialChartThemeData theme;

  /// The active configuration.
  final FinancialChartConfig config;

  /// The current crosshair/hover position, or null if inactive.
  final CrosshairPosition? crosshairPosition;

  static const Map<FinancialChartType, ChartRenderer> _mainRenderers =
      <FinancialChartType, ChartRenderer>{
        FinancialChartType.candlestick: CandlestickRenderer(),
        FinancialChartType.ohlc: OhlcRenderer(),
        FinancialChartType.line: LineRenderer(),
        FinancialChartType.area: AreaRenderer(),
        FinancialChartType.volume: VolumeRenderer(),
      };

  static const GridRenderer _gridRenderer = GridRenderer();
  static const PriceAxisRenderer _priceAxisRenderer = PriceAxisRenderer();
  static const TimeAxisRenderer _timeAxisRenderer = TimeAxisRenderer();
  static const CrosshairRenderer _crosshairRenderer = CrosshairRenderer();
  static const VolumeRenderer _volumeRenderer = VolumeRenderer();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.backgroundColor);
    if (data.isEmpty) return;

    final VisibleRange visibleRange = VisibleRange.resolve(
      viewport,
      data.length,
    );
    if (visibleRange.isEmpty) return;
    final List<Candle> visibleCandles = visibleRange.slice(data);

    final bool hasVolumePane =
        config.showVolumePane && chartType != FinancialChartType.volume;
    final Rect mainPlotArea = computeMainPlotArea(
      size: size,
      config: config,
      chartType: chartType,
    );
    final double volumePaneHeight = hasVolumePane
        ? (size.height - (config.showTimeAxis ? config.timeAxisHeight : 0)) *
              config.volumePaneHeightFraction
        : 0;

    final (double priceMin, double priceMax) = _computeValueRange(
      visibleCandles,
    );
    final ChartCoordinateSystem coordinateSystem = ChartCoordinateSystem(
      plotArea: mainPlotArea,
      viewport: viewport,
      priceMin: priceMin,
      priceMax: priceMax,
      data: data,
    );

    final ChartRenderContext context = ChartRenderContext(
      chartType: chartType,
      plotArea: mainPlotArea,
      coordinateSystem: coordinateSystem,
      visibleCandles: visibleCandles,
      visibleStartIndex: visibleRange.startIndex,
      theme: theme,
      config: config,
      crosshairPosition: crosshairPosition,
    );

    _gridRenderer.paint(canvas, context);
    _mainRenderers[chartType]!.paint(canvas, context);

    if (hasVolumePane) {
      final Rect volumePlotArea = Rect.fromLTWH(
        0,
        mainPlotArea.bottom,
        mainPlotArea.width,
        volumePaneHeight,
      );
      _volumeRenderer.paint(canvas, context.copyWith(plotArea: volumePlotArea));
    }

    _crosshairRenderer.paint(canvas, context);
    _priceAxisRenderer.paint(canvas, context);
    _timeAxisRenderer.paint(canvas, context);
  }

  (double, double) _computeValueRange(List<Candle> visibleCandles) {
    if (visibleCandles.isEmpty) return (0, 1);

    double min = double.infinity;
    double max = double.negativeInfinity;

    switch (chartType) {
      case FinancialChartType.candlestick:
      case FinancialChartType.ohlc:
        for (final Candle candle in visibleCandles) {
          if (candle.low < min) min = candle.low;
          if (candle.high > max) max = candle.high;
        }
      case FinancialChartType.volume:
        min = 0;
        for (final Candle candle in visibleCandles) {
          if (candle.volume > max) max = candle.volume;
        }
      case FinancialChartType.line:
      case FinancialChartType.area:
        for (final Candle candle in visibleCandles) {
          final double value = config.priceField.valueOf(candle);
          if (value < min) min = value;
          if (value > max) max = value;
        }
    }

    if (min > max) return (0, 1);
    if (min == max) {
      min -= 1;
      max += 1;
    }
    final double padding = (max - min) * 0.1;
    return (min - padding, max + padding);
  }

  @override
  bool shouldRepaint(covariant FinancialChartPainter oldDelegate) {
    return !identical(oldDelegate.data, data) ||
        oldDelegate.dataVersion != dataVersion ||
        oldDelegate.chartType != chartType ||
        oldDelegate.viewport != viewport ||
        oldDelegate.theme != theme ||
        oldDelegate.config != config ||
        oldDelegate.crosshairPosition != crosshairPosition;
  }
}
