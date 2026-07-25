# Changelog

## 0.0.1

* Initial release.
* Support for Android and iOS platforms.

## 0.0.2

* Added support for fetching health data from the connected ring.

## 0.0.3

* add documentation in code

## 0.0.4

* `ScanDevice` now exposes `rssi` (signal strength in dBm) from scan results on
  both Android and iOS. Null when the platform reported no reading.
* **Fix (iOS):** `getHealthData()` did not reset its collector between calls, so
  each sync appended another copy of the ring's replayed history to the previous
  payload. Readings accumulated without bound for the life of the connection and
  totals read far too high. Android already cleared its collector; iOS now does
  the same.
* **Fix:** sport `calories` is now reported in whole kcal. The SDK returns
  milli-kcal (a 563-step, 6-minute walk reports `17536`), which surfaced as
  absurd calorie figures.

