/// A Flutter-native financial charting engine for fintech, trading, and
/// investment applications.
///
/// Import this single file to use the package:
///
/// ```dart
/// import 'package:fincharts/fincharts.dart';
/// ```
///
/// Week 1 provides five chart types (see [FinancialChartType]) rendered by
/// [FinancialChart], driven by [Candle] data, configured via
/// [FinancialChartConfig], styled via [FinancialChartThemeData], and
/// controlled programmatically via [FinancialChartController].
library;

export 'src/chart/financial_chart.dart' show FinancialChart;
export 'src/chart/financial_chart_config.dart'
    show CrosshairConfig, FinancialChartConfig;
export 'src/chart/financial_chart_controller.dart'
    show FinancialChartController;
export 'src/core/enums/candle_direction.dart' show CandleDirection;
export 'src/core/enums/financial_chart_type.dart' show FinancialChartType;
export 'src/core/enums/price_field.dart' show PriceField;
export 'src/core/formatters/price_formatter.dart'
    show DefaultPriceFormatter, PriceFormatter;
export 'src/core/formatters/time_label_formatter.dart'
    show DefaultTimeLabelFormatter, TimeLabelFormatter;
export 'src/core/models/candle.dart' show Candle;
export 'src/theme/financial_chart_theme.dart'
    show
        AreaSeriesStyle,
        AxisStyle,
        CandleStyle,
        CrosshairStyle,
        FinancialChartThemeData,
        GridStyle,
        LineSeriesStyle,
        TooltipStyle,
        VolumeStyle;
export 'src/viewport/chart_viewport.dart' show ChartViewport;
