import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Candle', () {
    test('direction reports bullish, bearish, and doji correctly', () {
      final DateTime t = DateTime.utc(2024);
      final Candle bullish = Candle(
        timestamp: t,
        open: 10,
        high: 12,
        low: 9,
        close: 11,
        volume: 100,
      );
      final Candle bearish = Candle(
        timestamp: t,
        open: 11,
        high: 12,
        low: 9,
        close: 10,
        volume: 100,
      );
      final Candle doji = Candle(
        timestamp: t,
        open: 10,
        high: 12,
        low: 9,
        close: 10,
        volume: 100,
      );

      expect(bullish.direction, CandleDirection.bullish);
      expect(bearish.direction, CandleDirection.bearish);
      expect(doji.direction, CandleDirection.doji);
    });

    test('copyWith replaces only the given fields', () {
      final Candle original = Candle(
        timestamp: DateTime.utc(2024),
        open: 10,
        high: 12,
        low: 9,
        close: 11,
        volume: 100,
      );
      final Candle copy = original.copyWith(close: 11.5);

      expect(copy.close, 11.5);
      expect(copy.open, original.open);
      expect(copy.high, original.high);
      expect(copy.low, original.low);
      expect(copy.volume, original.volume);
      expect(copy.timestamp, original.timestamp);
    });

    test('equality and hashCode are value-based', () {
      final DateTime t = DateTime.utc(2024);
      final Candle a = Candle(
        timestamp: t,
        open: 10,
        high: 12,
        low: 9,
        close: 11,
        volume: 100,
      );
      final Candle b = Candle(
        timestamp: t,
        open: 10,
        high: 12,
        low: 9,
        close: 11,
        volume: 100,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('asserts when high is below open/close/low', () {
      expect(
        () => Candle(
          timestamp: DateTime.utc(2024),
          open: 10,
          high: 9,
          low: 8,
          close: 10,
          volume: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts when low is above open/close/high', () {
      expect(
        () => Candle(
          timestamp: DateTime.utc(2024),
          open: 10,
          high: 12,
          low: 11,
          close: 10,
          volume: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on negative volume', () {
      expect(
        () => Candle(
          timestamp: DateTime.utc(2024),
          open: 10,
          high: 12,
          low: 9,
          close: 10,
          volume: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on non-finite values', () {
      expect(
        () => Candle(
          timestamp: DateTime.utc(2024),
          open: double.nan,
          high: 12,
          low: 9,
          close: 10,
          volume: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Candle(
          timestamp: DateTime.utc(2024),
          open: 10,
          high: double.infinity,
          low: 9,
          close: 10,
          volume: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
