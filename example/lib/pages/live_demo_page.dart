import 'dart:async';
import 'dart:math' as math;

import 'package:fincharts/fincharts.dart';
import 'package:flutter/material.dart';

import '../data/demo_data_generator.dart';
import '../theme/app_colors.dart';

/// Demonstrates feeding `FinancialChart` a simulated real-time feed: a
/// [Timer] ticks the currently-forming candle every [_tickInterval], and
/// every [_ticksPerCandle] ticks "closes" the bar and starts a new one —
/// the same two update shapes described in the package README's Live
/// data section.
class LiveDemoPage extends StatefulWidget {
  /// Creates the live demo page.
  const LiveDemoPage({super.key});

  @override
  State<LiveDemoPage> createState() => _LiveDemoPageState();
}

class _LiveDemoPageState extends State<LiveDemoPage>
    with SingleTickerProviderStateMixin {
  static const DefaultPriceFormatter _formatter = DefaultPriceFormatter(
    currencySymbol: '₹',
  );
  static const Duration _tickInterval = Duration(milliseconds: 700);
  static const int _ticksPerCandle = 8;

  late List<Candle> _candles;
  final FinancialChartController _controller = FinancialChartController();
  final math.Random _random = math.Random();
  late final AnimationController _pulseController;

  Timer? _timer;
  int _ticksSinceNewCandle = 0;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _candles = generateDemoCandles(
      count: 120,
      interval: const Duration(minutes: 1),
      startPrice: 24812.35,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    // Always replace with a new List<Candle> — FinancialChart diffs by
    // list identity to decide whether to re-normalize, so mutating the
    // existing list in place wouldn't be picked up. See the README's
    // "Live data" section.
    final List<Candle> next = List<Candle>.of(_candles);
    _ticksSinceNewCandle++;
    if (_ticksSinceNewCandle >= _ticksPerCandle) {
      _ticksSinceNewCandle = 0;
      final Candle last = next.last;
      final Candle opened = nextLiveCandle(
        last,
        last.timestamp.add(const Duration(minutes: 1)),
      );
      next.add(nextLiveTick(opened, _random));
    } else {
      next[next.length - 1] = nextLiveTick(next.last, _random);
    }
    setState(() => _candles = next);
  }

  void _toggleRunning() {
    setState(() => _running = !_running);
    if (_running) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(dark: true);
    final Candle latest = _candles.last;
    final Candle previous = _candles.length > 1
        ? _candles[_candles.length - 2]
        : latest;
    final double change = latest.close - previous.close;
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
              changeColor: changeColor,
              isUp: isUp,
              running: _running,
              pulseController: _pulseController,
              onToggleRunning: _toggleRunning,
              onJumpToLive: _controller.scrollToLatest,
            ),
            Expanded(
              child: FinancialChart(
                data: _candles,
                controller: _controller,
                theme: FinancialChartThemeData.dark(),
                config: const FinancialChartConfig(
                  showVolumePane: true,
                  showLivePriceLine: true,
                  crosshair: CrosshairConfig(enabled: true),
                  priceFormatter: _formatter,
                ),
              ),
            ),
            _Footer(
              palette: palette,
              candleCount: _candles.length,
              running: _running,
            ),
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
    required this.changeColor,
    required this.isUp,
    required this.running,
    required this.pulseController,
    required this.onToggleRunning,
    required this.onJumpToLive,
  });

  final AppPalette palette;
  final Candle latest;
  final double change;
  final Color changeColor;
  final bool isUp;
  final bool running;
  final AnimationController pulseController;
  final VoidCallback onToggleRunning;
  final VoidCallback onJumpToLive;

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
          _LiveBadge(running: running, pulseController: pulseController),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'NIFTY 50',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Simulated real-time feed',
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
                  _formatter.format(change.abs()),
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
            tooltip: 'Jump to live',
            icon: Icon(
              Icons.center_focus_strong_outlined,
              color: palette.textSecondary,
              size: 20,
            ),
            onPressed: onJumpToLive,
          ),
          IconButton(
            tooltip: running ? 'Pause feed' : 'Resume feed',
            icon: Icon(
              running ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: palette.textSecondary,
              size: 20,
            ),
            onPressed: onToggleRunning,
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.running, required this.pulseController});

  final bool running;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final Color color = running
        ? AppColors.bearish
        : AppColors.textSecondaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedBuilder(
            animation: pulseController,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: running ? (0.35 + 0.65 * pulseController.value) : 1,
                child: child,
              );
            },
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            running ? 'LIVE' : 'PAUSED',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.palette,
    required this.candleCount,
    required this.running,
  });

  final AppPalette palette;
  final int candleCount;
  final bool running;

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
            '$candleCount candles · simulated tick every 700ms',
            style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
          ),
          const Spacer(),
          Text(
            running ? 'streaming' : 'paused',
            style: TextStyle(color: palette.textSecondary, fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
