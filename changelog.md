# Changelog

## v3.0.4

- Added debugging log
- Changed how files are exported / shared
- [iOS + MacOS] Added option to enable background operation
- Minor UI adjustments
- Fixed "Discharge Overcurrent Trigger" value offset by 10 mA
- [Windows] reduced connection times
- Fix Auto-Connect when a device is already connected

## v3.0.3

- Fix wrong keyboard type on device filter
- Minor UI layout and text adjustments
- Added help texts in Configuration View

## v3.0.2

- Added option to filter for BMS names
- Fixed crash on Android 12

## v3.0.1

- Fix estimated Range in GPS View
- Fix text breaking in Overview
- Minor visual improvements
- Added alert when connection to BMS takes longer than expected
- Display warnings and errors from BMS (Overcurrent etc.)
- Added Export Logging Data to CSV file

## v3.0.0

- Rewritten the App in Flutter
- Available for Android, iOS, MacOS and Windows

## v2.0.1

- added back option to export log data to csv
- added back gps view including range calculations

## v2.0.0

- complete recode in SwiftUI
- Added Logging using SwiftUI's new Chart library
- enhanced password features

## v1.2.2

- Fixed charging/discharging buttons sending wrong states after first launch
- Added "pull down to refresh" on the devices tab to clear the list and search for new devices
- Added a graph view for logging (experimental, just a interim solution)
- fixed red texts in the logging files list
- Auto connect to device
- Fixed negative values on GPS page

## v1.2.1

- Fixed some minor crashes
- Fixed capacity settings and overvoltage protection values over 65530
- Added logic that detects when certain features are unavailable and blocks them from beeing used

## v1.2.0

- Added warning for LionTron users
- Option to log BMS data
- Reworked persistent storage backend
- Added "Rename device" in "more" tab, also available in the welcome screen by swiping to the left on a device
- Removed "about & credits" in settings menu
- Fixed charging/discharging button getting stuck
- Fixed broken bluetooth connection after slightly swiping to the right
- Write Data button stays visible after switching tabs
- Added option to log data in background
- Fixed empty devicelist after disconnecting
- improved reconnecting
- Min/Max values are now device specific
- Fixed rare crash on checksum validation

## v1.1.1

- Fixed crashes when higher currents are beeing drawn
- Exit condition for reading and writing data in the configuration page

## v1.1.0

- Added configuration of your bms
- Fixed charge- and runtime calculation
- Smaller design changes
- Inverted current reporting, charging is positive, discharging negative

## v1.0.2

- Fixed crashing when the BMS offered more than 3 temperature sensors
- Fixed crashing when the bluetooth connection dropped

## v1.0.1 Release
