import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';
import '../theme/app_colors.dart';
import '../widgets/timeframe_button.dart';
import '../widgets/toolbar_icon_button.dart';

/// A trading-terminal-style demo: symbol header with live price/change,
/// an icon toolbar for chart type / timeframe / volume pane / zoom, an
/// edge-to-edge chart with an OHLC legend overlay, and a status bar —
/// styled after the density and dark palette of a professional charting
/// product rather than a generic Material settings screen.
class ChartDemoPage extends StatefulWidget {
  /// Creates the chart demo page.
  const ChartDemoPage({super.key});

  @override
  State<ChartDemoPage> createState() => _ChartDemoPageState();
}

class _ChartDemoPageState extends State<ChartDemoPage> {
  static const DefaultPriceFormatter _priceFormatter = DefaultPriceFormatter(
    currencySymbol: '₹',
  );
  static const Map<String, int?> _timeframes = <String, int?>{
    '1M': 30,
    '3M': 90,
    '6M': 180,
    '1Y': 365,
    'ALL': null,
  };

  final List<Candle> _candles = generateDemoCandles(
    count: 500,
    interval: const Duration(days: 1),
    startPrice: 24812.35,
  );
  final FinancialChartController _controller = FinancialChartController();

  FinancialChartType _type = FinancialChartType.candlestick;
  bool _darkMode = true;
  bool _showVolumePane = true;
  String _timeframe = '3M';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTimeframe(String label, int? visibleCandles) {
    setState(() => _timeframe = label);
    if (visibleCandles == null) {
      _controller.fitContent();
    } else {
      _controller.scrollToLatest(visibleCandles: visibleCandles.toDouble());
    }
  }

  static IconData _iconFor(FinancialChartType type) {
    switch (type) {
      case FinancialChartType.candlestick:
        return Icons.candlestick_chart_outlined;
      case FinancialChartType.ohlc:
        return Icons.bar_chart;
      case FinancialChartType.line:
        return Icons.show_chart;
      case FinancialChartType.area:
        return Icons.area_chart;
      case FinancialChartType.volume:
        return Icons.equalizer;
    }
  }

  static String _labelFor(FinancialChartType type) {
    switch (type) {
      case FinancialChartType.candlestick:
        return 'Candlestick';
      case FinancialChartType.ohlc:
        return 'OHLC';
      case FinancialChartType.line:
        return 'Line';
      case FinancialChartType.area:
        return 'Area';
      case FinancialChartType.volume:
        return 'Volume';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(dark: _darkMode);
    final FinancialChartThemeData chartTheme = _darkMode
        ? FinancialChartThemeData.dark()
        : FinancialChartThemeData.light();

    final Candle latest = _candles.last;
    final Candle previous = _candles.length > 1
        ? _candles[_candles.length - 2]
        : latest;
    final double change = latest.close - previous.close;
    final double changePercent = previous.close == 0
        ? 0
        : (change / previous.close) * 100;
    final bool isUp = change >= 0;
    final Color changeColor = isUp ? AppColors.bullish : AppColors.bearish;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _Header(
              palette: palette,
              latest: latest,
              change: change,
              changePercent: changePercent,
              changeColor: changeColor,
              isUp: isUp,
              darkMode: _darkMode,
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
            ),
            _Toolbar(
              palette: palette,
              type: _type,
              onTypeSelected: (FinancialChartType type) =>
                  setState(() => _type = type),
              timeframe: _timeframe,
              onTimeframeSelected: _selectTimeframe,
              showVolumePane: _showVolumePane,
              onToggleVolumePane: () =>
                  setState(() => _showVolumePane = !_showVolumePane),
              controller: _controller,
              onReset: () => setState(() => _timeframe = '3M'),
            ),
            Expanded(
              child: FinancialChart(
                data: _candles,
                type: _type,
                controller: _controller,
                theme: chartTheme,
                config: FinancialChartConfig(
                  showVolumePane: _showVolumePane,
                  crosshair: const CrosshairConfig(enabled: true),
                  priceFormatter: _priceFormatter,
                ),
              ),
            ),
            _StatusBar(palette: palette, candleCount: _candles.length),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.palette,
    required this.latest,
    required this.change,
    required this.changePercent,
    required this.changeColor,
    required this.isUp,
    required this.darkMode,
    required this.onToggleTheme,
  });

  final AppPalette palette;
  final Candle latest;
  final double change;
  final double changePercent;
  final Color changeColor;
  final bool isUp;
  final bool darkMode;
  final VoidCallback onToggleTheme;

  static const DefaultPriceFormatter _formatter = DefaultPriceFormatter(
    currencySymbol: '₹',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: palette.textPrimary, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'N',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'NIFTY 50 · DEMO',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Synthetic data — not real market data',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            _formatter.format(latest.close),
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: changeColor,
                  size: 16,
                ),
                Text(
                  '${_formatter.format(change.abs())} (${changePercent.abs().toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: darkMode
                ? 'Switch to light theme'
                : 'Switch to dark theme',
            icon: Icon(
              darkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: palette.textSecondary,
              size: 20,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.palette,
    required this.type,
    required this.onTypeSelected,
    required this.timeframe,
    required this.onTimeframeSelected,
    required this.showVolumePane,
    required this.onToggleVolumePane,
    required this.controller,
    required this.onReset,
  });

  final AppPalette palette;
  final FinancialChartType type;
  final ValueChanged<FinancialChartType> onTypeSelected;
  final String timeframe;
  final void Function(String label, int? visibleCandles) onTimeframeSelected;
  final bool showVolumePane;
  final VoidCallback onToggleVolumePane;
  final FinancialChartController controller;
  final VoidCallback onReset;

  Widget _divider() => Container(
    width: 1,
    height: 20,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    color: palette.border,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final FinancialChartType value
                      in FinancialChartType.values) ...<Widget>[
                    ToolbarIconButton(
                      icon: _ChartDemoPageState._iconFor(value),
                      selected: type == value,
                      tooltip: _ChartDemoPageState._labelFor(value),
                      palette: palette,
                      onTap: () => onTypeSelected(value),
                    ),
                    const SizedBox(width: 2),
                  ],
                  _divider(),
                  for (final MapEntry<String, int?> entry
                      in _ChartDemoPageState._timeframes.entries)
                    TimeframeButton(
                      label: entry.key,
                      selected: timeframe == entry.key,
                      palette: palette,
                      onTap: () => onTimeframeSelected(entry.key, entry.value),
                    ),
                  _divider(),
                  ToolbarIconButton(
                    icon: Icons.stacked_line_chart,
                    selected: showVolumePane,
                    tooltip: 'Volume pane',
                    palette: palette,
                    onTap: onToggleVolumePane,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove, color: palette.textSecondary, size: 18),
            tooltip: 'Zoom out',
            onPressed: controller.zoomOut,
          ),
          IconButton(
            icon: Icon(Icons.add, color: palette.textSecondary, size: 18),
            tooltip: 'Zoom in',
            onPressed: controller.zoomIn,
          ),
          IconButton(
            icon: Icon(
              Icons.fit_screen_outlined,
              color: palette.textSecondary,
              size: 18,
            ),
            tooltip: 'Fit content',
            onPressed: controller.fitContent,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: palette.textSecondary, size: 18),
            tooltip: 'Reset viewport',
            onPressed: () {
              controller.resetViewport();
              onReset();
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.palette, required this.candleCount});

  final AppPalette palette;
  final int candleCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '$candleCount candles · synthetic data',
            style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
          ),
          const Spacer(),
          Text(
            'fincharts v0.1.0',
            style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
