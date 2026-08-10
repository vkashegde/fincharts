import 'package:flutter/painting.dart';

import '../chart/financial_chart_config.dart';
import '../core/enums/financial_chart_type.dart';

/// Computes the rectangle reserved for the main chart plot area within
/// [size], after subtracting the price axis, time axis, and (if
/// composited) the volume pane.
///
/// Shared by [FinancialChartPainter] and the chart's gesture handling code
/// so that converting a pixel offset to a data index during an in-progress
/// pan/zoom gesture always agrees with what was actually painted last
/// frame — this is the one place that layout math lives.
Rect computeMainPlotArea({
  required Size size,
  required FinancialChartConfig config,
  required FinancialChartType chartType,
}) {
  final double priceAxisWidth = config.showPriceAxis
      ? config.priceAxisWidth
      : 0;
  final double timeAxisHeight = config.showTimeAxis ? config.timeAxisHeight : 0;
  final bool hasVolumePane =
      config.showVolumePane && chartType != FinancialChartType.volume;
  final double availableHeight = size.height - timeAxisHeight;
  final double volumePaneHeight = hasVolumePane
      ? availableHeight * config.volumePaneHeightFraction
      : 0;
  return Rect.fromLTWH(
    0,
    0,
    size.width - priceAxisWidth,
    availableHeight - volumePaneHeight,
  );
}
