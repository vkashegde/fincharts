import 'package:flutter/material.dart';

import 'pages/chart_demo_page.dart';
import 'pages/live_demo_page.dart';
import 'pages/performance_page.dart';
import 'theme/app_colors.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  static const List<String> _features = <String>[
    'Candlestick · OHLC · Line · Area · Volume',
    'Pan & zoom (touch + mouse-wheel)',
    'Live data',
    'Crosshair & tooltip',
    'Dark / light theming',
  ];

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(dark: true);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.candlestick_chart_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'FinCharts',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'v0.2.0',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'A Flutter-native financial charting engine for fintech, trading, '
              'and investment applications.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String feature in _features)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _NavCard(
              palette: palette,
              icon: Icons.candlestick_chart_outlined,
              iconColor: AppColors.bullish,
              title: 'Chart demo',
              subtitle:
                  'All 5 chart types, theming, pan, zoom, crosshair, tooltip',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ChartDemoPage()),
              ),
            ),
            const SizedBox(height: 12),
            _NavCard(
              palette: palette,
              icon: Icons.podcasts_outlined,
              iconColor: AppColors.bearish,
              title: 'Live demo',
              subtitle:
                  'Simulated real-time feed, live price line, ticking candle',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const LiveDemoPage()),
              ),
            ),
            const SizedBox(height: 12),
            _NavCard(
              palette: palette,
              icon: Icons.speed_outlined,
              iconColor: AppColors.accent,
              title: 'Performance',
              subtitle: '1,000 / 10,000 / 50,000 candle data sets',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PerformancePage(),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                'Synthetic demo data — not real market data',
                style: TextStyle(color: palette.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.palette,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppPalette palette;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: palette.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
