import 'dart:math' as math;

/// Computes visually "nice" axis tick values (1, 2, 5, 10, 20, 50, ...
/// scaled by powers of ten) for a given data range, following the classic
/// Heckbert "nice numbers for graph labels" algorithm.
///
/// Used by the price axis (and available for any future axis) so labels
/// land on round numbers instead of arbitrary fractions, and so the number
/// of labels stays bounded regardless of the data range.
class NiceScale {
  /// Computes nice tick bounds and spacing for the range `[min, max]`,
  /// targeting approximately [maxTickCount] ticks.
  factory NiceScale(double min, double max, {int maxTickCount = 6}) {
    assert(maxTickCount >= 2, 'maxTickCount must be at least 2');
    final double safeMax = max > min ? max : min + 1;
    final double rawRange = _niceNumber(safeMax - min, false);
    final double tickSpacing = _niceNumber(rawRange / (maxTickCount - 1), true);
    final double niceMin = tickSpacing == 0
        ? min
        : (min / tickSpacing).floorToDouble() * tickSpacing;
    final double niceMax = tickSpacing == 0
        ? safeMax
        : (safeMax / tickSpacing).ceilToDouble() * tickSpacing;
    return NiceScale._(
      niceMin: niceMin,
      niceMax: niceMax,
      tickSpacing: tickSpacing,
    );
  }

  const NiceScale._({
    required this.niceMin,
    required this.niceMax,
    required this.tickSpacing,
  });

  /// The rounded-down lower bound of the axis.
  final double niceMin;

  /// The rounded-up upper bound of the axis.
  final double niceMax;

  /// The spacing between consecutive ticks.
  final double tickSpacing;

  /// The list of tick values from [niceMin] to [niceMax], inclusive.
  List<double> get ticks {
    if (tickSpacing <= 0) return <double>[niceMin];
    final int count = ((niceMax - niceMin) / tickSpacing).round() + 1;
    return List<double>.generate(count, (int i) => niceMin + i * tickSpacing);
  }

  static double _niceNumber(double range, bool round) {
    if (range <= 0) return 0;
    final double exponent = (math.log(range) / math.ln10).floorToDouble();
    final double magnitude = math.pow(10, exponent).toDouble();
    final double fraction = range / magnitude;
    final double niceFraction;
    if (round) {
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else {
      if (fraction <= 1) {
        niceFraction = 1;
      } else if (fraction <= 2) {
        niceFraction = 2;
      } else if (fraction <= 5) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    }
    return niceFraction * magnitude;
  }
}
