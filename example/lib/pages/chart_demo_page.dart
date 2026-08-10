import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';

/// Demonstrates all five Week-1 chart types with a live type selector,
/// theme toggle, controller buttons, and interactive crosshair/tooltip.
class ChartDemoPage extends StatefulWidget {
  /// Creates the chart demo page.
  const ChartDemoPage({super.key});

  @override
  State<ChartDemoPage> createState() => _ChartDemoPageState();
}

class _ChartDemoPageState extends State<ChartDemoPage> {
  final List<Candle> _candles = generateDemoCandles();
  final FinancialChartController _controller = FinancialChartController();

  FinancialChartType _type = FinancialChartType.candlestick;
  bool _darkMode = true;
  bool _showVolumePane = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FinancialChartThemeData chartTheme = _darkMode
        ? FinancialChartThemeData.dark()
        : FinancialChartThemeData.light();

    return Scaffold(
      backgroundColor: chartTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Chart demo'),
        actions: <Widget>[
          IconButton(
            tooltip: _darkMode
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            icon: Icon(
              _darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => setState(() => _darkMode = !_darkMode),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final FinancialChartType type in FinancialChartType.values)
                  ChoiceChip(
                    label: Text(type.name),
                    selected: _type == type,
                    onSelected: (bool _) => setState(() => _type = type),
                  ),
                FilterChip(
                  label: const Text('Volume pane'),
                  selected: _showVolumePane,
                  onSelected: (bool value) =>
                      setState(() => _showVolumePane = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FinancialChart(
                data: _candles,
                type: _type,
                controller: _controller,
                theme: chartTheme,
                config: FinancialChartConfig(
                  showVolumePane: _showVolumePane,
                  crosshair: const CrosshairConfig(enabled: true),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: _controller.zoomIn,
                  child: const Text('Zoom in'),
                ),
                OutlinedButton(
                  onPressed: _controller.zoomOut,
                  child: const Text('Zoom out'),
                ),
                OutlinedButton(
                  onPressed: _controller.fitContent,
                  child: const Text('Fit content'),
                ),
                OutlinedButton(
                  onPressed: _controller.scrollToLatest,
                  child: const Text('Latest'),
                ),
                OutlinedButton(
                  onPressed: _controller.resetViewport,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
