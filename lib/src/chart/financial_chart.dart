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
import 'candle_series.dart';
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
/// ### Static data
///
/// ```dart
/// FinancialChart(
///   data: candles,
///   type: FinancialChartType.candlestick,
/// )
/// ```
///
/// ### Live / streaming data
///
/// Prefer a [CandleSeries] so ticks and new bars update without rebuilding
/// the parent with a new `List` identity on every message:
///
/// ```dart
/// final series = CandleSeries(historical);
///
/// FinancialChart(
///   series: series,
///   type: FinancialChartType.candlestick,
/// );
///
/// // Later, from a WebSocket / timer:
/// series.update(formingOrNextBar);
/// ```
///
/// When both [series] and [data] are provided, [series] takes precedence.
///
/// The package accepts market data and knows nothing about where it came
/// from — no REST/WebSocket/broker/backend concerns live here. See
/// `normalizeCandleData` for exactly how malformed input is handled.
class FinancialChart extends StatefulWidget {
  /// Creates a financial chart.
  const FinancialChart({
    this.data = const <Candle>[],
    this.series,
    this.type = FinancialChartType.candlestick,
    this.controller,
    this.config = const FinancialChartConfig(),
    this.theme,
    this.onDataIssues,
    this.emptyStateBuilder,
    super.key,
  });

  /// The candle series to render when [series] is null, ideally already
  /// sorted ascending by timestamp. See `normalizeCandleData` for how
  /// out-of-order, duplicate, or malformed entries are handled.
  ///
  /// Replacing this list with a new identity triggers a full normalize.
  /// For high-frequency live updates, use [series] instead.
  final List<Candle> data;

  /// Optional live candle series. When non-null, the chart listens to it
  /// and ignores [data].
  final CandleSeries? series;

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
  /// while sanitizing snapshot [data] (see `normalizeCandleData`), whenever
  /// [data] changes. Also invoked when a [series] is attached if that
  /// series reported issues from its last [CandleSeries.setData].
  /// Optional — most applications that supply well-formed data will never
  /// see this called.
  final ValueChanged<List<String>>? onDataIssues;

  /// Builds the widget shown when the active data set is empty. Defaults
  /// to a centered "No data" message styled from [theme].
  final WidgetBuilder? emptyStateBuilder;

  @override
  State<FinancialChart> createState() => _FinancialChartState();
}

class _FinancialChartState extends State<FinancialChart> {
  late FinancialChartController _controller;
  bool _controllerIsInternal = false;
  List<Candle> _normalizedData = const <Candle>[];
  int _dataVersion = 0;
  CrosshairPosition? _crosshairPosition;

  ChartViewport? _gestureStartViewport;
  Offset? _gestureStartFocalPoint;

  @override
  void initState() {
    super.initState();
    _attachController();
    _attachSeries(widget.series);
    _refreshData(reportIssues: true);
  }

  @override
  void didUpdateWidget(covariant FinancialChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _attachController();
    }
    if (widget.series != oldWidget.series) {
      _detachSeries(oldWidget.series);
      _attachSeries(widget.series);
      _crosshairPosition = null;
      _refreshData(reportIssues: true);
    } else if (widget.series == null &&
        !identical(widget.data, oldWidget.data)) {
      _crosshairPosition = null;
      _refreshData(reportIssues: true);
    } else {
      _syncController();
    }
  }

  @override
  void dispose() {
    _detachSeries(widget.series);
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

  void _attachSeries(CandleSeries? series) {
    series?.addListener(_handleSeriesChanged);
  }

  void _detachSeries(CandleSeries? series) {
    series?.removeListener(_handleSeriesChanged);
  }

  void _handleControllerChanged() => setState(() {});

  void _handleSeriesChanged() {
    setState(() {
      final CrosshairPosition? previous = _crosshairPosition;
      _refreshData(reportIssues: false);
      if (previous == null) return;
      final int index = previous.dataIndex;
      if (index < 0 || index >= _normalizedData.length) {
        _crosshairPosition = null;
      } else {
        _crosshairPosition = CrosshairPosition(
          dataIndex: index,
          candle: _normalizedData[index],
          localPosition: previous.localPosition,
        );
      }
    });
  }

  void _refreshData({required bool reportIssues}) {
    final CandleSeries? series = widget.series;
    if (series != null) {
      _normalizedData = series.candles;
      _dataVersion = series.version;
      if (reportIssues && series.issues.isNotEmpty) {
        widget.onDataIssues?.call(series.issues);
      }
    } else {
      final NormalizedCandleData result = normalizeCandleData(widget.data);
      _normalizedData = result.candles;
      _dataVersion++;
      if (reportIssues && result.issues.isNotEmpty) {
        widget.onDataIssues?.call(result.issues);
      }
    }
    _syncController();
  }

  void _syncController() {
    _controller.syncWithChart(
      dataLength: _normalizedData.length,
      minVisibleCandles: widget.config.minVisibleCandles,
      maxVisibleCandles: widget.config.maxVisibleCandles,
      followLatestOnUpdate: widget.config.followLatestOnUpdate,
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
                dataVersion: _dataVersion,
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
