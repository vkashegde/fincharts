/// The visual style used to render a series of [Candle] data.
///
/// Each value corresponds to exactly one [ChartRenderer] implementation.
/// Adding a new chart type in a future release means adding a new enum
/// value and a new renderer registration — it does not require modifying
/// any existing renderer.
enum FinancialChartType {
  /// Renders open/high/low/close as candlestick bodies and wicks.
  candlestick,

  /// Renders open/high/low/close as traditional OHLC tick bars.
  ohlc,

  /// Renders a single price series (see [PriceField]) as a continuous line.
  line,

  /// Renders a single price series (see [PriceField]) as a filled area.
  area,

  /// Renders traded volume as a bar series, colored by candle direction.
  volume,
}
