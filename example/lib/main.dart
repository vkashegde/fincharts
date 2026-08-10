import 'package:flutter/material.dart';

import 'pages/chart_demo_page.dart';
import 'pages/performance_page.dart';

void main() {
  runApp(const FinChartsExampleApp());
}

/// The example app's root widget.
class FinChartsExampleApp extends StatelessWidget {
  /// Creates the example app.
  const FinChartsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinCharts Example',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2962FF),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FinCharts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'A Flutter-native financial charting engine for fintech, trading, '
            'and investment applications.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.candlestick_chart_outlined),
              title: const Text('Chart demo'),
              subtitle: const Text(
                'All 5 chart types, theming, pan, zoom, crosshair, tooltip',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChartDemoPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed_outlined),
              title: const Text('Performance'),
              subtitle: const Text('1,000 / 10,000 / 50,000 candle data sets'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PerformancePage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
