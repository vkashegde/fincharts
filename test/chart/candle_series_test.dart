import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime t0 = DateTime.utc(2024, 1, 1, 9, 15);
  final DateTime t1 = t0.add(const Duration(minutes: 1));
  final DateTime t2 = t0.add(const Duration(minutes: 2));

  Candle bar(DateTime timestamp, {double close = 100, double volume = 10}) {
    return Candle(
      timestamp: timestamp,
      open: 100,
      high: close > 100 ? close : 100,
      low: close < 100 ? close : 100,
      close: close,
      volume: volume,
    );
  }

  group('CandleSeries', () {
    test('normalizes initial data on construction', () {
      final CandleSeries series = CandleSeries(<Candle>[
        bar(t1, close: 101),
        bar(t0, close: 100),
      ]);

      expect(series.length, 2);
      expect(series.candles.first.timestamp, t0);
      expect(series.issues, isNotEmpty);
      expect(series.version, greaterThan(0));
    });

    test('update replaces the forming bar for the same timestamp', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0, close: 100)]);
      final int versionBefore = series.version;

      expect(series.update(bar(t0, close: 102, volume: 20)), isTrue);

      expect(series.length, 1);
      expect(series.lastOrNull!.close, 102);
      expect(series.lastOrNull!.volume, 20);
      expect(series.version, greaterThan(versionBefore));
    });

    test('update appends when the timestamp is newer', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);

      expect(series.update(bar(t1, close: 101)), isTrue);

      expect(series.length, 2);
      expect(series.candles.last.timestamp, t1);
    });

    test('update ignores out-of-order older timestamps', () {
      final CandleSeries series = CandleSeries(<Candle>[
        bar(t0),
        bar(t1, close: 101),
      ]);
      final int versionBefore = series.version;

      expect(series.update(bar(t0, close: 99)), isFalse);
      expect(series.length, 2);
      expect(series.version, versionBefore);
    });

    test('append rejects equal or older timestamps', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);

      expect(series.append(bar(t0, close: 101)), isFalse);
      expect(series.append(bar(t1, close: 101)), isTrue);
      expect(series.length, 2);
    });

    test('updateLast requires matching timestamp', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);

      expect(series.updateLast(bar(t1, close: 101)), isFalse);
      expect(series.updateLast(bar(t0, close: 103)), isTrue);
      expect(series.lastOrNull!.close, 103);
    });

    test('setData replaces the series and bumps version', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);
      final int versionBefore = series.version;

      series.setData(<Candle>[bar(t0), bar(t1), bar(t2)]);

      expect(series.length, 3);
      expect(series.version, greaterThan(versionBefore));
    });

    test('clear empties the series', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);
      series.clear();
      expect(series.isEmpty, isTrue);
      expect(series.lastOrNull, isNull);
    });

    test('notifies listeners on update', () {
      final CandleSeries series = CandleSeries(<Candle>[bar(t0)]);
      int notifications = 0;
      series.addListener(() => notifications++);

      series.update(bar(t0, close: 101));
      series.update(bar(t1, close: 102));

      expect(notifications, 2);
    });
  });
}
