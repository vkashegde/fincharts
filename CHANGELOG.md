# Changelog

## 0.2.0

### Added

- Live data support: `FinancialChart` is now explicitly designed and documented for streaming/frequently-updating `data` (tick updates to the forming candle, and new candles appended as bars close), preserving the viewport's "scrolled to latest" state and an active crosshair across updates.
- `FinancialChartConfig.showLivePriceLine` — a dashed reference line and price tag at the latest close, colored by direction, anchored to the last candle in the full data set regardless of the current viewport.
- Mouse-wheel / trackpad-scroll zoom, as the primary desktop/web zoom path (see 0.1.1).

### Fixed

- An active crosshair no longer gets cleared every time `data` changes. Previously, since a live feed necessarily supplies a new list identity on every tick, hovering the chart while data streamed in made the crosshair and tooltip disappear on each update; it now stays attached to the same candle index and its displayed OHLCV values update live.

## 0.1.1

### Fixed

- Pinch-to-zoom not working on desktop trackpads (notably Windows Chrome): added a dedicated mouse-wheel/trackpad-scroll zoom path, since a desktop trackpad "pinch" reaches the browser as wheel events rather than the multi-touch pointer events `ScaleGestureRecognizer` relies on.

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
