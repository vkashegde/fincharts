import 'package:flutter/foundation.dart';

import '../core/enums/price_field.dart';
import '../core/formatters/price_formatter.dart';
import '../core/formatters/time_label_formatter.dart';

/// Configuration for the crosshair overlay.
///
/// Passed to [FinancialChartConfig.crosshair]. The crosshair works
/// identically across all five Week-1 chart types — it is not coupled to
/// candlestick rendering.
@immutable
class CrosshairConfig {
  /// Creates a crosshair configuration.
  const CrosshairConfig({
    this.enabled = true,
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.snapToCandle = true,
  });

  /// Whether the crosshair (and tooltip) responds to interaction at all.
  final bool enabled;

  /// Whether to draw the vertical guide line.
  final bool showVerticalLine;

  /// Whether to draw the horizontal guide line.
  final bool showHorizontalLine;

  /// Whether the vertical line and tooltip snap to the nearest candle's
  /// center, or follow the raw pointer position.
  final bool snapToCandle;

  /// Returns a copy of this configuration with the given fields replaced.
  CrosshairConfig copyWith({
    bool? enabled,
    bool? showVerticalLine,
    bool? showHorizontalLine,
    bool? snapToCandle,
  }) {
    return CrosshairConfig(
      enabled: enabled ?? this.enabled,
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      snapToCandle: snapToCandle ?? this.snapToCandle,
    );
  }
}

/// Strongly typed, composable configuration for [FinancialChart].
///
/// Grouped into a single object (rather than dozens of constructor
/// parameters on the widget itself) so new options can be added over time
/// without breaking existing call sites, and so configuration can be
/// shared/reused across multiple chart instances.
@immutable
class FinancialChartConfig {
  /// Creates a chart configuration.
  const FinancialChartConfig({
    this.showGrid = true,
    this.showPriceAxis = true,
    this.showTimeAxis = true,
    this.showVolumePane = false,
    this.showLivePriceLine = false,
    this.enablePan = true,
    this.enableZoom = true,
    this.showTooltip = true,
    this.priceField = PriceField.close,
    this.crosshair = const CrosshairConfig(),
    this.priceFormatter = const DefaultPriceFormatter(),
    this.timeLabelFormatter = const DefaultTimeLabelFormatter(),
    this.minVisibleCandles = 5,
    this.maxVisibleCandles,
    this.priceAxisWidth = 64,
    this.timeAxisHeight = 28,
    this.volumePaneHeightFraction = 0.2,
  }) : assert(minVisibleCandles >= 2, 'minVisibleCandles must be at least 2'),
       assert(
         volumePaneHeightFraction > 0 && volumePaneHeightFraction < 1,
         'volumePaneHeightFraction must be between 0 and 1',
       );

  /// Whether to draw background grid lines.
  final bool showGrid;

  /// Whether to draw the price axis.
  final bool showPriceAxis;

  /// Whether to draw the time axis.
  final bool showTimeAxis;

  /// Whether to composite a volume sub-pane beneath the main chart. Has no
  /// effect when [FinancialChart.type] is already
  /// `FinancialChartType.volume`.
  final bool showVolumePane;

  /// Whether to draw a horizontal reference line (and axis label) at the
  /// latest candle's closing price, colored to match its direction.
  ///
  /// This is the chart's visual "this is live" affordance — the dashed
  /// line + price tag a real-time trading chart shows. It tracks whichever
  /// candle is currently last in `FinancialChart.data` regardless of the
  /// current viewport, so it stays visible even while scrolled back into
  /// history. Has no effect when [FinancialChart.type] is
  /// `FinancialChartType.volume`, which has no price axis to anchor to.
  final bool showLivePriceLine;

  /// Whether horizontal panning is enabled.
  final bool enablePan;

  /// Whether pinch-to-zoom is enabled.
  final bool enableZoom;

  /// Whether the OHLCV tooltip is shown alongside the crosshair.
  final bool showTooltip;

  /// Which OHLC field a `line`/`area` chart plots.
  final PriceField priceField;

  /// Crosshair behavior and visibility.
  final CrosshairConfig crosshair;

  /// Formats prices for the price axis and tooltip.
  final PriceFormatter priceFormatter;

  /// Formats timestamps for the time axis and tooltip.
  final TimeLabelFormatter timeLabelFormatter;

  /// The minimum number of candles the viewport may zoom in to.
  final double minVisibleCandles;

  /// The maximum number of candles the viewport may zoom out to, or null
  /// to allow zooming out to the full data set.
  final double? maxVisibleCandles;

  /// The width reserved for the price axis, in logical pixels.
  final double priceAxisWidth;

  /// The height reserved for the time axis, in logical pixels.
  final double timeAxisHeight;

  /// The fraction of the plot area's height reserved for the volume pane
  /// when [showVolumePane] is true.
  final double volumePaneHeightFraction;

  /// Returns a copy of this configuration with the given fields replaced.
  FinancialChartConfig copyWith({
    bool? showGrid,
    bool? showPriceAxis,
    bool? showTimeAxis,
    bool? showVolumePane,
    bool? showLivePriceLine,
    bool? enablePan,
    bool? enableZoom,
    bool? showTooltip,
    PriceField? priceField,
    CrosshairConfig? crosshair,
    PriceFormatter? priceFormatter,
    TimeLabelFormatter? timeLabelFormatter,
    double? minVisibleCandles,
    double? maxVisibleCandles,
    double? priceAxisWidth,
    double? timeAxisHeight,
    double? volumePaneHeightFraction,
  }) {
    return FinancialChartConfig(
      showGrid: showGrid ?? this.showGrid,
      showPriceAxis: showPriceAxis ?? this.showPriceAxis,
      showTimeAxis: showTimeAxis ?? this.showTimeAxis,
      showVolumePane: showVolumePane ?? this.showVolumePane,
      showLivePriceLine: showLivePriceLine ?? this.showLivePriceLine,
      enablePan: enablePan ?? this.enablePan,
      enableZoom: enableZoom ?? this.enableZoom,
      showTooltip: showTooltip ?? this.showTooltip,
      priceField: priceField ?? this.priceField,
      crosshair: crosshair ?? this.crosshair,
      priceFormatter: priceFormatter ?? this.priceFormatter,
      timeLabelFormatter: timeLabelFormatter ?? this.timeLabelFormatter,
      minVisibleCandles: minVisibleCandles ?? this.minVisibleCandles,
      maxVisibleCandles: maxVisibleCandles ?? this.maxVisibleCandles,
      priceAxisWidth: priceAxisWidth ?? this.priceAxisWidth,
      timeAxisHeight: timeAxisHeight ?? this.timeAxisHeight,
      volumePaneHeightFraction:
          volumePaneHeightFraction ?? this.volumePaneHeightFraction,
    );
  }
}
