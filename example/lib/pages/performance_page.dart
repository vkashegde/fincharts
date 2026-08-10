import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';

/// Lets a developer manually assess pan/zoom smoothness across data sets of
/// increasing size, without making any specific performance claims.
class PerformancePage extends StatefulWidget {
  /// Creates the performance page.
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  static const List<int> _sizes = <int>[1000, 10000, 50000];

  int _count = 1000;
  late List<Candle> _candles = generateDemoCandles(
    count: _count,
    interval: const Duration(minutes: 5),
  );

  void _regenerate(int count) {
    setState(() {
      _count = count;
      _candles = generateDemoCandles(
        count: count,
        interval: const Duration(minutes: 5),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: <Widget>[
                for (final int size in _sizes)
                  ChoiceChip(
                    label: Text('$size candles'),
                    selected: _count == size,
                    onSelected: (bool _) => _regenerate(size),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Pan and pinch-zoom to manually assess frame smoothness. Only the '
              'visible candles are painted regardless of data set size — run in '
              'profile mode with the performance overlay for objective frame timing.',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FinancialChart(
                key: ValueKey<int>(_count),
                data: _candles,
                config: const FinancialChartConfig(showVolumePane: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
