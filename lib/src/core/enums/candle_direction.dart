/// The direction implied by a candle's open/close relationship.
enum CandleDirection {
  /// `close > open`.
  bullish,

  /// `close < open`.
  bearish,

  /// `close == open`.
  doji,
}
