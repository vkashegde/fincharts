/// Formats candle timestamps into axis labels and tooltip headers.
///
/// The time axis renderer calls [formatAxisLabel] once per visible tick and
/// passes the approximate time span each label represents, so an
/// implementation can pick an appropriately granular format (e.g. showing
/// only a time-of-day when zoomed into a single day, but a month/year when
/// zoomed out over years) without the caller needing to know the format
/// rules.
abstract interface class TimeLabelFormatter {
  /// Formats [timestamp] for an axis tick that represents roughly
  /// [approximateLabelSpan] of time.
  String formatAxisLabel(DateTime timestamp, Duration approximateLabelSpan);

  /// Formats [timestamp] for a tooltip header, where full precision is
  /// always appropriate regardless of zoom level.
  String formatFull(DateTime timestamp);
}

/// The default [TimeLabelFormatter].
///
/// Implemented by hand (no `intl` dependency) so the package's only
/// dependency remains the Flutter SDK itself.
class DefaultTimeLabelFormatter implements TimeLabelFormatter {
  /// Creates a default time label formatter.
  const DefaultTimeLabelFormatter();

  static const List<String> _monthAbbreviations = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  String formatAxisLabel(DateTime timestamp, Duration approximateLabelSpan) {
    if (approximateLabelSpan >= const Duration(days: 300)) {
      return '${timestamp.year}';
    }
    if (approximateLabelSpan >= const Duration(days: 25)) {
      return '${_monthAbbreviations[timestamp.month - 1]} ${timestamp.year}';
    }
    if (approximateLabelSpan >= const Duration(hours: 20)) {
      return '${_pad2(timestamp.day)} ${_monthAbbreviations[timestamp.month - 1]}';
    }
    return '${_pad2(timestamp.hour)}:${_pad2(timestamp.minute)}';
  }

  @override
  String formatFull(DateTime timestamp) {
    final String date =
        '${_pad2(timestamp.day)} ${_monthAbbreviations[timestamp.month - 1]} ${timestamp.year}';
    final String time = '${_pad2(timestamp.hour)}:${_pad2(timestamp.minute)}';
    return '$date $time';
  }

  static String _pad2(int value) => value.toString().padLeft(2, '0');
}
