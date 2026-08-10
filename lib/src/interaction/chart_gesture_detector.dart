import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Wires raw Flutter gesture/pointer callbacks to [child] for pan, pinch
/// zoom, and crosshair interaction.
///
/// This widget performs no chart math of its own — it only plumbs Flutter's
/// gesture APIs through to callbacks. All pan/zoom/crosshair arithmetic
/// lives in the pure functions in `pan_handler.dart`, `zoom_handler.dart`,
/// and `crosshair_handler.dart`, which can be unit-tested without pumping a
/// widget tree.
///
/// A single `onScale*` family drives both panning (scale ≈ 1) and pinch
/// zoom (scale ≠ 1), matching how Flutter's own `ScaleGestureDetector`
/// unifies drag and pinch — using separate pan and scale recognizers would
/// make them compete for the same pointer. [HitTestBehavior.opaque] claims
/// pointers within the chart's bounds so a horizontally-panning chart does
/// not fight a vertically-scrolling ancestor (e.g. inside a `ListView`).
class ChartGestureDetector extends StatelessWidget {
  /// Creates a chart gesture detector.
  const ChartGestureDetector({
    required this.child,
    required this.panEnabled,
    required this.zoomEnabled,
    required this.crosshairEnabled,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onHover,
    this.onHoverExit,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressEnd,
    super.key,
  });

  /// The chart surface (typically a `CustomPaint`) to wrap.
  final Widget child;

  /// Whether the scale gesture's pan component is currently enabled.
  final bool panEnabled;

  /// Whether the scale gesture's zoom component is currently enabled.
  final bool zoomEnabled;

  /// Whether long-press-drag and pointer-hover crosshair interaction is
  /// currently enabled.
  final bool crosshairEnabled;

  /// Called when a pan/zoom gesture begins.
  final GestureScaleStartCallback? onScaleStart;

  /// Called as a pan/zoom gesture progresses.
  final GestureScaleUpdateCallback? onScaleUpdate;

  /// Called when a pan/zoom gesture ends.
  final GestureScaleEndCallback? onScaleEnd;

  /// Called on mouse hover (desktop/web crosshair).
  final ValueChanged<Offset>? onHover;

  /// Called when the mouse exits the chart bounds.
  final VoidCallback? onHoverExit;

  /// Called when a long-press crosshair interaction begins (touch).
  final GestureLongPressStartCallback? onLongPressStart;

  /// Called as a long-press crosshair drag continues.
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;

  /// Called when a long-press crosshair interaction ends.
  final GestureLongPressEndCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final bool scaleActive = panEnabled || zoomEnabled;

    Widget result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: scaleActive ? onScaleStart : null,
      onScaleUpdate: scaleActive ? onScaleUpdate : null,
      onScaleEnd: scaleActive ? onScaleEnd : null,
      onLongPressStart: crosshairEnabled ? onLongPressStart : null,
      onLongPressMoveUpdate: crosshairEnabled ? onLongPressMoveUpdate : null,
      onLongPressEnd: crosshairEnabled ? onLongPressEnd : null,
      child: child,
    );

    if (crosshairEnabled) {
      result = MouseRegion(
        onHover: (PointerHoverEvent event) =>
            onHover?.call(event.localPosition),
        onExit: (_) => onHoverExit?.call(),
        child: result,
      );
    }

    return result;
  }
}
