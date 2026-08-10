import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultTimeLabelFormatter', () {
    const DefaultTimeLabelFormatter formatter = DefaultTimeLabelFormatter();
    final DateTime timestamp = DateTime.utc(2026, 8, 8, 10, 35);

    test('shows only the year for a multi-year label span', () {
      expect(
        formatter.formatAxisLabel(timestamp, const Duration(days: 400)),
        '2026',
      );
    });

    test('shows month and year for a multi-week label span', () {
      expect(
        formatter.formatAxisLabel(timestamp, const Duration(days: 40)),
        'Aug 2026',
      );
    });

    test('shows day and month for a multi-day label span', () {
      expect(
        formatter.formatAxisLabel(timestamp, const Duration(days: 2)),
        '08 Aug',
      );
    });

    test('shows time-of-day for a sub-day label span', () {
      expect(
        formatter.formatAxisLabel(timestamp, const Duration(hours: 2)),
        '10:35',
      );
    });

    test('formatFull shows date and time together', () {
      expect(formatter.formatFull(timestamp), '08 Aug 2026 10:35');
    });
  });
}
