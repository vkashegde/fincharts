import 'package:flutter/painting.dart';

import '../core/models/candle.dart';
import '../core/models/crosshair_position.dart';
import '../chart/financial_chart_config.dart';
import '../theme/financial_chart_theme.dart';
import 'chart_render_context.dart';
import 'chart_renderer.dart';

/// Renders the crosshair guide lines, axis readout labels, and the OHLCV
/// tooltip.
///
/// Reads only [ChartRenderContext.crosshairPosition] plus the current
/// candle's OHLCV fields — it has no dependency on which chart type is
/// active, so the crosshair behaves identically for candlestick, OHLC,
/// line, area, and volume charts.
class CrosshairRenderer implements ChartRenderer {
  /// Creates a crosshair renderer.
  const CrosshairRenderer();

  @override
  void paint(Canvas canvas, ChartRenderContext context) {
    final CrosshairConfig crosshairConfig = context.config.crosshair;
    final CrosshairPosition? position = context.crosshairPosition;
    if (!crosshairConfig.enabled || position == null) return;

    final coordinateSystem = context.coordinateSystem;
    final CrosshairStyle style = context.theme.crosshair;
    final Rect plotArea = context.plotArea;
    final Paint linePaint = Paint()
      ..color = style.lineColor
      ..strokeWidth = style.lineWidth;

    final double x = coordinateSystem.indexToX(position.dataIndex + 0.5);
    final double y = crosshairConfig.snapToCandle
        ? coordinateSystem.priceToY(position.candle.close)
        : position.localPosition.dy;

    if (crosshairConfig.showVerticalLine) {
      canvas.drawLine(
        Offset(x, plotArea.top),
        Offset(x, plotArea.bottom),
        linePaint,
      );
    }
    if (crosshairConfig.showHorizontalLine) {
      canvas.drawLine(
        Offset(plotArea.left, y),
        Offset(plotArea.right, y),
        linePaint,
      );
    }

    if (context.config.showPriceAxis && crosshairConfig.showHorizontalLine) {
      _drawAxisLabel(
        canvas,
        text: context.config.priceFormatter.format(
          coordinateSystem.yToPrice(y),
        ),
        style: style,
        anchor: Offset(plotArea.right + 4, y),
        centerVertically: true,
      );
    }
    if (context.config.showTimeAxis && crosshairConfig.showVerticalLine) {
      _drawAxisLabel(
        canvas,
        text: context.config.timeLabelFormatter.formatFull(
          position.candle.timestamp,
        ),
        style: style,
        anchor: Offset(x, plotArea.bottom + 4),
        centerHorizontally: true,
      );
    }

    if (context.config.showTooltip) {
      _drawTooltip(canvas, context, position.candle);
    }
  }

  void _drawAxisLabel(
    Canvas canvas, {
    required String text,
    required CrosshairStyle style,
    required Offset anchor,
    bool centerVertically = false,
    bool centerHorizontally = false,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: style.labelTextColor, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const double paddingX = 4;
    const double paddingY = 2;
    double left = anchor.dx;
    double top = anchor.dy;
    if (centerHorizontally) left -= textPainter.width / 2;
    if (centerVertically) top -= textPainter.height / 2;

    final Rect background = Rect.fromLTWH(
      left - paddingX,
      top - paddingY,
      textPainter.width + paddingX * 2,
      textPainter.height + paddingY * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(background, const Radius.circular(3)),
      Paint()..color = style.labelBackgroundColor,
    );
    textPainter.paint(canvas, Offset(left, top));
  }

  void _drawTooltip(Canvas canvas, ChartRenderContext context, Candle candle) {
    final TooltipStyle style = context.theme.tooltip;
    final priceFormatter = context.config.priceFormatter;
    final timeFormatter = context.config.timeLabelFormatter;

    final List<String> lines = <String>[
      timeFormatter.formatFull(candle.timestamp),
      'O  ${priceFormatter.format(candle.open)}',
      'H  ${priceFormatter.format(candle.high)}',
      'L  ${priceFormatter.format(candle.low)}',
      'C  ${priceFormatter.format(candle.close)}',
      'Vol  ${_formatVolume(candle.volume)}',
    ];

    const double fontSize = 11;
    const double lineHeight = 16;
    const double padding = 8;

    double maxWidth = 0;
    final List<TextPainter> painters = <TextPainter>[];
    for (int i = 0; i < lines.length; i++) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: lines[i],
          style: TextStyle(
            color: style.textColor,
            fontSize: fontSize,
            fontWeight: i == 0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painters.add(textPainter);
      if (textPainter.width > maxWidth) maxWidth = textPainter.width;
    }

    final double boxWidth = maxWidth + padding * 2;
    final double boxHeight = lineHeight * lines.length + padding * 2;
    final Rect box = Rect.fromLTWH(
      context.plotArea.left + 8,
      context.plotArea.top + 8,
      boxWidth,
      boxHeight,
    );
    final RRect rounded = RRect.fromRectAndRadius(
      box,
      Radius.circular(style.borderRadius),
    );

    canvas.drawRRect(rounded, Paint()..color = style.backgroundColor);
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = style.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (int i = 0; i < painters.length; i++) {
      painters[i].paint(
        canvas,
        Offset(box.left + padding, box.top + padding + i * lineHeight),
      );
    }
  }

  static String _formatVolume(double volume) {
    if (volume >= 1e6) return '${(volume / 1e6).toStringAsFixed(2)}M';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(2)}K';
    return volume.toStringAsFixed(0);
  }
}
