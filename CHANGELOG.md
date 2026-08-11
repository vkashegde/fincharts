# Changelog

## 0.2.0

### Added

- Live data support: `FinancialChart` is now explicitly designed and documented for streaming/frequently-updating `data` (tick updates to the forming candle, and new candles appended as bars close), preserving the viewport's "scrolled to latest" state and an active crosshair across updates.
- `FinancialChartConfig.showLivePriceLine` — a dashed reference line and price tag at the latest close, colored by direction, anchored to the last candle in the full data set regardless of the current viewport.
- Mouse-wheel / trackpad-scroll zoom, as the primary desktop/web zoom path.

## 0.1.0

Initial release.

### Added

- Candlestick chart
- OHLC chart
- Line chart
- Area chart
- Volume chart
- Pan interaction
- Pinch zoom
- Crosshair
- Financial tooltip
- Price axis
- Time axis
- Dark/light themes
- Chart controller

