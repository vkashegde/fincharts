import 'dart:async';
import 'dart:math' as math;

import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';

/// Demonstrates [CandleSeries] with a simulated live market feed:
/// tick-level updates to the forming bar, then periodic new bars.
class RealtimeDemoPage extends StatefulWidget {
  /// Creates the realtime demo page.
  const RealtimeDemoPage({super.key});

  @override
  State<RealtimeDemoPage> createState() => _RealtimeDemoPageState();
}

class _RealtimeDemoPageState extends State<RealtimeDemoPage> {
  static const Duration _barInterval = Duration(seconds: 5);
  static const Duration _tickInterval = Duration(milliseconds: 200);

  late final CandleSeries _series;
  final FinancialChartController _controller = FinancialChartController();
  final math.Random _random = math.Random(42);

  Timer? _tickTimer;
  bool _running = true;
  bool _darkMode = true;
  FinancialChartType _type = FinancialChartType.candlestick;

  late DateTime _barOpenTime;
  late double _lastPrice;
  int _ticksInBar = 0;

  @override
  void initState() {
    super.initState();
    final List<Candle> history = generateDemoCandles(
      count: 80,
      interval: _barInterval,
      seed: 11,
    );
    _series = CandleSeries(history);
    final Candle last = history.last;
    _barOpenTime = last.timestamp;
    _lastPrice = last.close;
    _startFeed();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _series.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startFeed() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _stopFeed() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void _toggleRunning() {
    setState(() {
      _running = !_running;
      if (_running) {
        _startFeed();
      } else {
        _stopFeed();
      }
    });
  }

  void _onTick() {
    if (!_running) return;

    final double drift = (_random.nextDouble() - 0.48) * _lastPrice * 0.0015;
    final double tickPrice = math.max(1, _lastPrice + drift);
    _lastPrice = tickPrice;
    _ticksInBar++;

    final Candle? current = _series.lastOrNull;
    if (current == null) return;

    final Duration elapsed = DateTime.now().difference(_barOpenTime);
    final bool openNewBar = elapsed >= _barInterval || _ticksInBar >= 25;

    if (openNewBar) {
      _barOpenTime = _barOpenTime.add(_barInterval);
      _ticksInBar = 0;
      _series.update(
        Candle(
          timestamp: _barOpenTime,
          open: tickPrice,
          high: tickPrice,
          low: tickPrice,
          close: tickPrice,
          volume: 1000 + _random.nextInt(4000).toDouble(),
        ),
      );
    } else {
      _series.update(
        current.copyWith(
          high: math.max(current.high, tickPrice),
          low: math.min(current.low, tickPrice),
          close: tickPrice,
          volume: current.volume + 200 + _random.nextInt(800),
        ),
      );
    }

    // Rebuild chrome (last price / status) — the chart listens to [_series]
    // on its own and does not need this setState.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final FinancialChartThemeData chartTheme = _darkMode
        ? FinancialChartThemeData.dark()
        : FinancialChartThemeData.light();
    final Candle? last = _series.lastOrNull;
    final String priceText = last == null
        ? '—'
        : last.close.toStringAsFixed(2);
    final bool bullish = last != null && last.close >= last.open;

    return Scaffold(
      backgroundColor: chartTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Realtime feed'),
        actions: <Widget>[
          IconButton(
            tooltip: _running ? 'Pause feed' : 'Resume feed',
            icon: Icon(_running ? Icons.pause_circle_outline : Icons.play_circle_outline),
            onPressed: _toggleRunning,
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _running ? const Color(0xFF26A69A) : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _running ? 'LIVE' : 'PAUSED',
                  style: TextStyle(
                    color: chartTheme.axis.labelColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  priceText,
                  style: TextStyle(
                    color: bullish
                        ? chartTheme.candle.bullishColor
                        : chartTheme.candle.bearishColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_series.length} bars',
                  style: TextStyle(
                    color: chartTheme.axis.labelColor.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final FinancialChartType type
                    in <FinancialChartType>[
                      FinancialChartType.candlestick,
                      FinancialChartType.ohlc,
                      FinancialChartType.line,
                      FinancialChartType.area,
                    ])
                  ChoiceChip(
                    label: Text(type.name),
                    selected: _type == type,
                    onSelected: (bool _) => setState(() => _type = type),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FinancialChart(
                series: _series,
                type: _type,
                controller: _controller,
                theme: chartTheme,
                config: const FinancialChartConfig(
                  showVolumePane: true,
                  followLatestOnUpdate: true,
                  crosshair: CrosshairConfig(enabled: true),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Simulated ticks every ${_tickInterval.inMilliseconds}ms; '
              'new bar about every ${_barInterval.inSeconds}s. '
              'Pan away from the right edge to stop auto-follow.',
              style: TextStyle(
                color: chartTheme.axis.labelColor.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
