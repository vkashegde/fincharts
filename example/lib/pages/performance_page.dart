import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';
import '../theme/app_colors.dart';
import '../widgets/timeframe_button.dart';

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
    final AppPalette palette = AppPalette.of(dark: true);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(bottom: BorderSide(color: palette.border)),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: palette.textPrimary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Performance',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Only visible candles are painted, regardless of data set size',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(bottom: BorderSide(color: palette.border)),
              ),
              child: Row(
                children: <Widget>[
                  for (final int size in _sizes) ...<Widget>[
                    TimeframeButton(
                      label: '$size',
                      selected: _count == size,
                      palette: palette,
                      onTap: () => _regenerate(size),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.speed_outlined,
                    color: palette.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_count candles loaded',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: FinancialChart(
                  key: ValueKey<int>(_count),
                  data: _candles,
                  theme: FinancialChartThemeData.dark(),
                  config: const FinancialChartConfig(showVolumePane: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
