import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../core/enums/financial_chart_type.dart';
import '../core/models/candle.dart';
import '../core/models/crosshair_position.dart';
import '../interaction/chart_gesture_detector.dart';
import '../interaction/crosshair_handler.dart';
import '../interaction/pan_handler.dart';
import '../interaction/zoom_handler.dart';
import '../rendering/chart_layout.dart';
import '../rendering/financial_chart_painter.dart';
import '../theme/financial_chart_theme.dart';
import '../viewport/chart_coordinate_system.dart';
import '../viewport/chart_viewport.dart';
import 'financial_chart_config.dart';
import 'financial_chart_controller.dart';
import 'financial_chart_state.dart';

/// A financial chart: candlestick, OHLC, line, area, or volume, rendered
/// entirely with `CustomPainter` — no per-candle widgets.
///
/// `FinancialChart` does not assume it owns the whole screen; it expects
/// bounded layout constraints from its parent (the same requirement any
/// `CustomPaint`-based chart has), so wrap it in a `SizedBox`, `Expanded`,
/// or similar when the parent would otherwise offer unbounded space.
///
/// ```dart
/// FinancialChart(
///   data: candles,
///   type: FinancialChartType.candlestick,
///   controller: controller,
///   config: FinancialChartConfig(
///     showGrid: true,
///     enablePan: true,
///     enableZoom: true,
///     crosshair: CrosshairConfig(enabled: true),
///   ),
/// )
/// ```
///
/// The package accepts market data and knows nothing about where it came
/// from — no REST/WebSocket/broker/backend concerns live here. See
/// `normalizeCandleData` for exactly how malformed input is handled.
class FinancialChart extends StatefulWidget {
  /// Creates a financial chart.
  const FinancialChart({
    required this.data,
    this.type = FinancialChartType.candlestick,
    this.controller,
    this.config = const FinancialChartConfig(),
    this.theme,
    this.onDataIssues,
    this.emptyStateBuilder,
    super.key,
  });

  /// The candle series to render, ideally already sorted ascending by
  /// timestamp. See `normalizeCandleData` for how out-of-order, duplicate,
  /// or malformed entries are handled.
  final List<Candle> data;

  /// Which chart type to render.
  final FinancialChartType type;

  /// Optional programmatic control over the viewport. If omitted, the
  /// chart creates and manages its own controller internally.
  final FinancialChartController? controller;

  /// Chart behavior and feature configuration.
  final FinancialChartConfig config;

  /// The visual theme. Defaults to [FinancialChartThemeData.dark].
  final FinancialChartThemeData? theme;

  /// Called with a human-readable description of each correction applied
  /// while sanitizing [data] (see `normalizeCandleData`), whenever [data]
  /// changes. Optional — most applications that supply well-formed data
  /// will never see this called.
  final ValueChanged<List<String>>? onDataIssues;

  /// Builds the widget shown when [data] is empty. Defaults to a centered
  /// "No data" message styled from [theme].
  final WidgetBuilder? emptyStateBuilder;

  @override
  State<FinancialChart> createState() => _FinancialChartState();
}

class _FinancialChartState extends State<FinancialChart> {
  late FinancialChartController _controller;
  bool _controllerIsInternal = false;
  List<Candle> _normalizedData = const <Candle>[];
  CrosshairPosition? _crosshairPosition;

  ChartViewport? _gestureStartViewport;
  Offset? _gestureStartFocalPoint;

  @override
  void initState() {
    super.initState();
    _attachController();
    _normalizeData();
  }

  @override
  void didUpdateWidget(covariant FinancialChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
    }
    if (!identical(widget.data, oldWidget.data)) {
      _crosshairPosition = null;
      _normalizeData();
    } else {
      _syncController();
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _controllerIsInternal = false;
    } else {
      _controller = FinancialChartController();
      _controllerIsInternal = true;
    }
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    if (_controllerIsInternal) _controller.dispose();
  }

  void _handleControllerChanged() => setState(() {});

  void _normalizeData() {
    final NormalizedCandleData result = normalizeCandleData(widget.data);
    _normalizedData = result.candles;
    if (result.issues.isNotEmpty) {
      widget.onDataIssues?.call(result.issues);
    }
    _syncController();
  }

  void _syncController() {
    _controller.syncWithChart(
      dataLength: _normalizedData.length,
      minVisibleCandles: widget.config.minVisibleCandles,
      maxVisibleCandles: widget.config.maxVisibleCandles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FinancialChartThemeData theme =
        widget.theme ?? FinancialChartThemeData.dark();

    if (_normalizedData.isEmpty) {
      return ColoredBox(
        color: theme.backgroundColor,
        child: Center(
          child:
              widget.emptyStateBuilder?.call(context) ??
              DefaultTextStyle(
                style: TextStyle(color: theme.axis.labelColor, fontSize: 13),
                child: const Text('No data'),
              ),
        ),
      );
    }

    return Semantics(
      label: 'Financial chart (${widget.type.name})',
      value: _semanticsValue(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Size size = constraints.biggest;
          return ChartGestureDetector(
            panEnabled: widget.config.enablePan,
            zoomEnabled: widget.config.enableZoom,
            crosshairEnabled: widget.config.crosshair.enabled,
            onScaleStart: (ScaleStartDetails details) =>
                _handleScaleStart(details),
            onScaleUpdate: (ScaleUpdateDetails details) =>
                _handleScaleUpdate(details, size),
            onScaleEnd: (ScaleEndDetails details) => _handleScaleEnd(),
            onPointerScroll: (PointerScrollEvent event) =>
                _handlePointerScroll(event, size),
            onHover: (Offset position) => _updateCrosshair(position, size),
            onHoverExit: _clearCrosshair,
            onLongPressStart: (LongPressStartDetails details) =>
                _updateCrosshair(details.localPosition, size),
            onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) =>
                _updateCrosshair(details.localPosition, size),
            onLongPressEnd: (LongPressEndDetails details) => _clearCrosshair(),
            child: CustomPaint(
              size: size,
              painter: FinancialChartPainter(
                data: _normalizedData,
                chartType: widget.type,
                viewport: _controller.viewport,
                theme: theme,
                config: widget.config,
                crosshairPosition: _crosshairPosition,
              ),
            ),
          );
        },
      ),
    );
  }

  String _semanticsValue() {
    final Candle current = _crosshairPosition?.candle ?? _normalizedData.last;
    final String price = widget.config.priceFormatter.format(current.close);
    final String time = widget.config.timeLabelFormatter.formatFull(
      current.timestamp,
    );
    return 'Price $price at $time';
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _gestureStartViewport = _controller.viewport;
    _gestureStartFocalPoint = details.localFocalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    final ChartViewport? startViewport = _gestureStartViewport;
    final Offset? startFocalPoint = _gestureStartFocalPoint;
    if (startViewport == null || startFocalPoint == null) return;

    final Rect plotArea = computeMainPlotArea(
      size: size,
      config: widget.config,
      chartType: widget.type,
    );
    if (plotArea.width <= 0) return;
    final double startCandleWidth = plotArea.width / startViewport.visibleSpan;

    ChartViewport next = startViewport;

    if (widget.config.enableZoom && details.scale != 1.0) {
      final double startFocalIndex =
          startViewport.startIndex +
          (startFocalPoint.dx - plotArea.left) / startCandleWidth;
      next = applyZoom(
        viewport: startViewport,
        scaleFactor: details.scale,
        focalIndex: startFocalIndex,
        dataLength: _normalizedData.length,
        minVisibleCandles: widget.config.minVisibleCandles,
        maxVisibleCandles: widget.config.maxVisibleCandles,
      );
    }

    if (widget.config.enablePan) {
      final double candleWidthAfterZoom = plotArea.width / next.visibleSpan;
      final double panDeltaPixels =
          details.localFocalPoint.dx - startFocalPoint.dx;
      next = applyPan(
        viewport: next,
        deltaIndices: panDeltaPixels / candleWidthAfterZoom,
        dataLength: _normalizedData.length,
        minVisibleCandles: widget.config.minVisibleCandles,
        maxVisibleCandles: widget.config.maxVisibleCandles,
      );
    }

    _controller.applyGestureViewport(next);
  }

  void _handleScaleEnd() {
    _gestureStartViewport = null;
    _gestureStartFocalPoint = null;
  }

  /// Handles mouse-wheel and trackpad scroll signals as zoom.
  ///
  /// Desktop trackpads and mice don't produce the multi-touch pointer
  /// events [_handleScaleUpdate] relies on for pinch — a trackpad "pinch"
  /// reaches Flutter (and is most reliable cross-browser/cross-platform,
  /// including Windows Chrome) as a wheel scroll signal instead, so this
  /// is the primary way desktop/web users zoom the chart.
  void _handlePointerScroll(PointerScrollEvent event, Size size) {
    if (!widget.config.enableZoom) return;
    final Rect plotArea = computeMainPlotArea(
      size: size,
      config: widget.config,
      chartType: widget.type,
    );
    if (plotArea.width <= 0) return;

    final ChartViewport current = _controller.viewport;
    final double candleWidth = plotArea.width / current.visibleSpan;
    final double focalIndex =
        current.startIndex +
        (event.localPosition.dx - plotArea.left) / candleWidth;

    // Scrolling up (negative dy) zooms in; exponential scaling keeps the
    // feel consistent regardless of a single event's delta magnitude.
    final double scaleFactor = math.exp(-event.scrollDelta.dy * 0.0015);

    _controller.applyGestureViewport(
      applyZoom(
        viewport: current,
        scaleFactor: scaleFactor,
        focalIndex: focalIndex,
        dataLength: _normalizedData.length,
        minVisibleCandles: widget.config.minVisibleCandles,
        maxVisibleCandles: widget.config.maxVisibleCandles,
      ),
    );
  }

  void _updateCrosshair(Offset localPosition, Size size) {
    if (!widget.config.crosshair.enabled) return;
    final Rect plotArea = computeMainPlotArea(
      size: size,
      config: widget.config,
      chartType: widget.type,
    );
    final ChartCoordinateSystem coordinateSystem = ChartCoordinateSystem(
      plotArea: plotArea,
      viewport: _controller.viewport,
      priceMin: 0,
      priceMax: 1,
      data: _normalizedData,
    );
    final CrosshairPosition? position = resolveCrosshairPosition(
      localPosition: localPosition,
      coordinateSystem: coordinateSystem,
      data: _normalizedData,
    );
    if (position != _crosshairPosition) {
      setState(() => _crosshairPosition = position);
    }
  }

  void _clearCrosshair() {
    if (_crosshairPosition != null) {
      setState(() => _crosshairPosition = null);
    }
  }
}
