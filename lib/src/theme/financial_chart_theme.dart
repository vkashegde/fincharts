import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';

/// Visual styling for candle bodies and wicks.
class CandleStyle {
  /// Creates a candle style.
  const CandleStyle({
    required this.bullishColor,
    required this.bearishColor,
    required this.dojiColor,
    required this.bullishWickColor,
    required this.bearishWickColor,
  });

  /// Body/bar color when `close > open`.
  final Color bullishColor;

  /// Body/bar color when `close < open`.
  final Color bearishColor;

  /// Body color when `close == open`.
  final Color dojiColor;

  /// Wick color when `close > open`.
  final Color bullishWickColor;

  /// Wick color when `close < open`.
  final Color bearishWickColor;
}

/// Visual styling for the volume series.
class VolumeStyle {
  /// Creates a volume style.
  const VolumeStyle({required this.bullishColor, required this.bearishColor});

  /// Bar color for candles where `close > open`.
  final Color bullishColor;

  /// Bar color for candles where `close < open`.
  final Color bearishColor;
}

/// Visual styling for background grid lines.
class GridStyle {
  /// Creates a grid style.
  const GridStyle({required this.lineColor, this.lineWidth = 0.5});

  /// The grid line color.
  final Color lineColor;

  /// The grid line stroke width.
  final double lineWidth;
}

/// Visual styling for the price and time axes.
class AxisStyle {
  /// Creates an axis style.
  const AxisStyle({
    required this.lineColor,
    required this.labelColor,
    this.labelFontSize = 11,
  });

  /// The axis baseline/tick line color.
  final Color lineColor;

  /// The axis label text color.
  final Color labelColor;

  /// The axis label font size.
  final double labelFontSize;
}

/// Visual styling for a [FinancialChartType.line] series.
class LineSeriesStyle {
  /// Creates a line series style.
  const LineSeriesStyle({required this.color, this.strokeWidth = 2});

  /// The line color.
  final Color color;

  /// The line stroke width.
  final double strokeWidth;
}

/// Visual styling for a [FinancialChartType.area] series.
class AreaSeriesStyle {
  /// Creates an area series style.
  const AreaSeriesStyle({
    required this.lineColor,
    required this.topFillColor,
    required this.bottomFillColor,
    this.strokeWidth = 2,
  });

  /// The stroke color of the line at the top of the filled area.
  final Color lineColor;

  /// The fill color at the top of the gradient (near the line).
  final Color topFillColor;

  /// The fill color at the bottom of the gradient (near the axis). Should
  /// generally be fully transparent so the fill stays visually subtle.
  final Color bottomFillColor;

  /// The stroke width of the line at the top of the area.
  final double strokeWidth;
}

/// Visual styling for the crosshair.
class CrosshairStyle {
  /// Creates a crosshair style.
  const CrosshairStyle({
    required this.lineColor,
    required this.labelBackgroundColor,
    required this.labelTextColor,
    this.lineWidth = 1,
  });

  /// The color of the horizontal and vertical guide lines.
  final Color lineColor;

  /// The background color of the price/time labels drawn on the axes.
  final Color labelBackgroundColor;

  /// The text color of the price/time labels drawn on the axes.
  final Color labelTextColor;

  /// The guide line stroke width.
  final double lineWidth;
}

/// Visual styling for the OHLCV tooltip.
class TooltipStyle {
  /// Creates a tooltip style.
  const TooltipStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.borderRadius = 6,
  });

  /// The tooltip's background fill color.
  final Color backgroundColor;

  /// The tooltip's border color.
  final Color borderColor;

  /// The tooltip's text color.
  final Color textColor;

  /// The tooltip's corner radius.
  final double borderRadius;
}

/// A complete, composable theme for [FinancialChart].
///
/// No renderer hard-codes a color — every visual value a renderer needs
/// comes from an instance of this class, injected via
/// `ChartRenderContext.theme`. Use [FinancialChartThemeData.dark] or
/// [FinancialChartThemeData.light] as a starting point and override
/// individual nested styles with [copyWith], or construct a theme from
/// scratch for full control.
class FinancialChartThemeData {
  /// Creates a theme from its component styles.
  const FinancialChartThemeData({
    required this.backgroundColor,
    required this.candle,
    required this.volume,
    required this.grid,
    required this.axis,
    required this.line,
    required this.area,
    required this.crosshair,
    required this.tooltip,
  });

  /// A dark theme suited to trading/fintech applications.
  factory FinancialChartThemeData.dark() {
    const Color bullish = Color(0xFF26A69A);
    const Color bearish = Color(0xFFEF5350);
    return const FinancialChartThemeData(
      backgroundColor: Color(0xFF131722),
      candle: CandleStyle(
        bullishColor: bullish,
        bearishColor: bearish,
        dojiColor: Color(0xFF9598A1),
        bullishWickColor: bullish,
        bearishWickColor: bearish,
      ),
      volume: VolumeStyle(
        bullishColor: Color(0x8026A69A),
        bearishColor: Color(0x80EF5350),
      ),
      grid: GridStyle(lineColor: Color(0x1FFFFFFF)),
      axis: AxisStyle(
        lineColor: Color(0x3DFFFFFF),
        labelColor: Color(0xB3FFFFFF),
      ),
      line: LineSeriesStyle(color: Color(0xFF2962FF)),
      area: AreaSeriesStyle(
        lineColor: Color(0xFF2962FF),
        topFillColor: Color(0x4D2962FF),
        bottomFillColor: Color(0x002962FF),
      ),
      crosshair: CrosshairStyle(
        lineColor: Color(0x80FFFFFF),
        labelBackgroundColor: Color(0xFF2A2E39),
        labelTextColor: Color(0xFFFFFFFF),
      ),
      tooltip: TooltipStyle(
        backgroundColor: Color(0xF01E222D),
        borderColor: Color(0x3DFFFFFF),
        textColor: Color(0xFFD1D4DC),
      ),
    );
  }

  /// A light theme suited to trading/fintech applications.
  factory FinancialChartThemeData.light() {
    const Color bullish = Color(0xFF089981);
    const Color bearish = Color(0xFFF23645);
    return const FinancialChartThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      candle: CandleStyle(
        bullishColor: bullish,
        bearishColor: bearish,
        dojiColor: Color(0xFF787B86),
        bullishWickColor: bullish,
        bearishWickColor: bearish,
      ),
      volume: VolumeStyle(
        bullishColor: Color(0x80089981),
        bearishColor: Color(0x80F23645),
      ),
      grid: GridStyle(lineColor: Color(0x1F000000)),
      axis: AxisStyle(
        lineColor: Color(0x3D000000),
        labelColor: Color(0xB3000000),
      ),
      line: LineSeriesStyle(color: Color(0xFF2962FF)),
      area: AreaSeriesStyle(
        lineColor: Color(0xFF2962FF),
        topFillColor: Color(0x332962FF),
        bottomFillColor: Color(0x002962FF),
      ),
      crosshair: CrosshairStyle(
        lineColor: Color(0x99000000),
        labelBackgroundColor: Color(0xFF131722),
        labelTextColor: Color(0xFFFFFFFF),
      ),
      tooltip: TooltipStyle(
        backgroundColor: Color(0xF5FFFFFF),
        borderColor: Color(0x1F000000),
        textColor: Color(0xFF131722),
      ),
    );
  }

  /// Convenience constructor that returns [dark] or [light] based on
  /// [brightness]. Useful for apps that want the chart to follow
  /// `Theme.of(context).brightness` without the package depending on
  /// Material theming itself.
  factory FinancialChartThemeData.fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? FinancialChartThemeData.dark()
        : FinancialChartThemeData.light();
  }

  /// The plot area's background color.
  final Color backgroundColor;

  /// Candlestick/OHLC styling.
  final CandleStyle candle;

  /// Volume series styling.
  final VolumeStyle volume;

  /// Grid line styling.
  final GridStyle grid;

  /// Price/time axis styling.
  final AxisStyle axis;

  /// Line chart styling.
  final LineSeriesStyle line;

  /// Area chart styling.
  final AreaSeriesStyle area;

  /// Crosshair styling.
  final CrosshairStyle crosshair;

  /// Tooltip styling.
  final TooltipStyle tooltip;

  /// Returns a copy of this theme with the given fields replaced.
  FinancialChartThemeData copyWith({
    Color? backgroundColor,
    CandleStyle? candle,
    VolumeStyle? volume,
    GridStyle? grid,
    AxisStyle? axis,
    LineSeriesStyle? line,
    AreaSeriesStyle? area,
    CrosshairStyle? crosshair,
    TooltipStyle? tooltip,
  }) {
    return FinancialChartThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      candle: candle ?? this.candle,
      volume: volume ?? this.volume,
      grid: grid ?? this.grid,
      axis: axis ?? this.axis,
      line: line ?? this.line,
      area: area ?? this.area,
      crosshair: crosshair ?? this.crosshair,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}
