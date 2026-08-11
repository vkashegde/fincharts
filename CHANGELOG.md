# Changelog

## Unreleased

### Added

- `CandleSeries` for live / streaming candle updates (`update`, `updateLast`, `append`, `setData`)
- `FinancialChart.series` to bind a chart to a `CandleSeries` without rebuilding on every tick
- `FinancialChartConfig.followLatestOnUpdate` to control auto-scroll when new bars arrive
- Example app **Realtime feed** page with a simulated tick + new-bar stream

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
