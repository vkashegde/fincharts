import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../interaction/zoom_handler.dart';
import '../viewport/chart_viewport.dart';

/// Programmatic control over a [FinancialChart]'s viewport.
///
/// Create one, pass it to `FinancialChart.controller`, and call its methods
/// to zoom, reset, or navigate the chart from outside the widget tree —
/// the same pattern as `ScrollController` or `TextEditingController`.
/// `FinancialChart` attaches itself to the controller and keeps it in sync
/// with the current data length; the controller does not hold a reference
/// to the candle data itself.
///
/// Like every other part of this package, `FinancialChartController` is a
/// plain `ChangeNotifier` — it does not require or assume any particular
/// state-management approach in the host application.
class FinancialChartController extends ChangeNotifier {
  ChartViewport? _viewport;
  int _dataLength = 0;
  double _minVisibleCandles = 5;
  double? _maxVisibleCandles;

  /// The current visible data-index window.
  ///
  /// Returns a default single-candle viewport before the controller has
  /// been attached to a [FinancialChart].
  ChartViewport get viewport =>
      _viewport ?? const ChartViewport(startIndex: 0, endIndex: 1);

  /// The data length this controller was last synced with.
  int get dataLength => _dataLength;

  /// Zooms in around the center of the current viewport.
  void zoomIn({double factor = 1.2}) => _zoomAroundCenter(factor);

  /// Zooms out around the center of the current viewport.
  void zoomOut({double factor = 1.2}) => _zoomAroundCenter(1 / factor);

  /// Resets the viewport to show the entire data set.
  void fitContent() {
    if (_dataLength <= 0) return;
    _setViewport(
      ChartViewport(startIndex: 0, endIndex: _dataLength.toDouble()).clamp(
        dataLength: _dataLength,
        minVisibleCandles: _minVisibleCandles,
        maxVisibleCandles: _maxVisibleCandles,
      ),
    );
  }

  /// Scrolls to show the most recent candles, preserving the current zoom
  /// level (number of visible candles) unless [visibleCandles] is given.
  void scrollToLatest({double? visibleCandles}) {
    if (_dataLength <= 0) return;
    final double span =
        visibleCandles ??
        _viewport?.visibleSpan ??
        math.min(60, _dataLength.toDouble());
    _setViewport(
      ChartViewport(
        startIndex: _dataLength - span,
        endIndex: _dataLength.toDouble(),
      ).clamp(
        dataLength: _dataLength,
        minVisibleCandles: _minVisibleCandles,
        maxVisibleCandles: _maxVisibleCandles,
      ),
    );
  }

  /// Resets the viewport to its initial state (the most recent candles, at
  /// the default zoom level).
  void resetViewport() {
    if (_dataLength <= 0) return;
    _setViewport(ChartViewport.initial(_dataLength));
  }

  void _zoomAroundCenter(double scaleFactor) {
    final ChartViewport current = viewport;
    final double center = current.startIndex + current.visibleSpan / 2;
    _setViewport(
      applyZoom(
        viewport: current,
        scaleFactor: scaleFactor,
        focalIndex: center,
        dataLength: _dataLength,
        minVisibleCandles: _minVisibleCandles,
        maxVisibleCandles: _maxVisibleCandles,
      ),
    );
  }

  /// Attaches this controller to a [FinancialChart] instance, or updates
  /// its data length and zoom constraints as they change.
  ///
  /// Not part of the public API surface consumers are expected to call —
  /// `FinancialChart` calls this itself whenever its data or configuration
  /// changes.
  @internal
  void syncWithChart({
    required int dataLength,
    required double minVisibleCandles,
    double? maxVisibleCandles,
    double initialVisibleCandles = 60,
    bool followLatestOnUpdate = true,
  }) {
    _minVisibleCandles = minVisibleCandles;
    _maxVisibleCandles = maxVisibleCandles;

    if (_viewport == null) {
      _viewport = ChartViewport.initial(
        dataLength,
        initialVisibleCandles: initialVisibleCandles,
      );
      _dataLength = dataLength;
      return;
    }

    if (_dataLength == dataLength) {
      final ChartViewport clamped = _viewport!.clamp(
        dataLength: dataLength,
        minVisibleCandles: minVisibleCandles,
        maxVisibleCandles: maxVisibleCandles,
      );
      if (clamped != _viewport) {
        _viewport = clamped;
      }
      return;
    }

    final bool wasAtLatest =
        followLatestOnUpdate &&
        _dataLength > 0 &&
        _viewport!.endIndex >= _dataLength - 0.5;
    if (wasAtLatest) {
      final double span = _viewport!.visibleSpan;
      _viewport =
          ChartViewport(
            startIndex: dataLength - span,
            endIndex: dataLength.toDouble(),
          ).clamp(
            dataLength: dataLength,
            minVisibleCandles: minVisibleCandles,
            maxVisibleCandles: maxVisibleCandles,
          );
    } else {
      _viewport = _viewport!.clamp(
        dataLength: dataLength,
        minVisibleCandles: minVisibleCandles,
        maxVisibleCandles: maxVisibleCandles,
      );
    }
    _dataLength = dataLength;
  }

  /// Applies a viewport produced by an in-progress pan/zoom gesture.
  ///
  /// Not part of the public API surface consumers are expected to call —
  /// `FinancialChart`'s internal gesture handling calls this itself.
  @internal
  void applyGestureViewport(ChartViewport next) => _setViewport(next);

  void _setViewport(ChartViewport next) {
    if (next == _viewport) return;
    _viewport = next;
    notifyListeners();
  }
}
