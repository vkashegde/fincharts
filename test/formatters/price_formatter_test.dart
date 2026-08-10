import 'package:fincharts/fincharts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultPriceFormatter', () {
    const DefaultPriceFormatter formatter = DefaultPriceFormatter();

    test('groups thousands and uses 2 decimals for values >= 1', () {
      expect(formatter.format(24850.50), '24,850.50');
      expect(formatter.format(1250.25), '1,250.25');
      expect(formatter.format(250.50), '250.50');
      expect(formatter.format(25.50), '25.50');
      expect(formatter.format(2.55), '2.55');
    });

    test('uses 3 decimals for values under 1', () {
      expect(formatter.format(0.255), '0.255');
    });

    test('handles zero and negative values', () {
      expect(formatter.format(0), '0.00');
      expect(formatter.format(-1234.5), '-1,234.50');
    });

    test('prefixes an optional currency symbol', () {
      const DefaultPriceFormatter rupee = DefaultPriceFormatter(
        currencySymbol: '₹',
      );
      expect(rupee.format(24850.50), '₹24,850.50');
    });

    test('honors a fixed decimalDigits override', () {
      const DefaultPriceFormatter fixed = DefaultPriceFormatter(
        decimalDigits: 4,
      );
      expect(fixed.format(1.5), '1.5000');
    });
  });
}
