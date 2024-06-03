# Changelog

## v3.3.1 [Android only]
- Fix crash on startup

## v3.3.0
- Added option to set up notifications and actions once certain events occur
- Fix opening contact form and other sites on android
- Improved logging view
- JBD:
  - Fix writing certain configuration parameters that depend on others

## v3.2.4
- Exporting files under MacOS fixed
- Daly:
    - Checking password has been fixed

## v3.2.3
- Fixed some bugs with setting a bms password
- Daly: 
    - Added unfiltered search to find all dongles and support more bms

## v3.2.2

- Added Chinese and Italian to the supported languages.
- JBD: 
  - Fixed read configuration for some special batteries.

## v3.2.0

- Configuration profiles added. You can export and import them to get support from your dealer or share them with your friends!
- The version number of the app is now visible on the information page.
- More logging information has been added so we can better help you when you contact us!
- JBD:
  - Added compatibility for newer BMS versions
  - More crash safety!
- Daly:
  - Progress bar will be displayed when writing configuration
  - The switch-off delay is now calculated correctly

## v3.1.2

- Devices will now reconnect after connection has been lost
- JBD: Added support for older bluetooth dongles

## v3.1.1

- Multiview scrollable
- Open Device from MultiDeviceView
- Battery Display in overview can be switched between old and new style by clicking
- Daly: Refactored the configuration dropdowns
- JBD: Advanced Protection configuration added
- JBD: Disable configuration editing until first read

## v3.1.0

- We now support the Daly BMS with all the available features!
- New UI to display the battery capacity
- In the Multiconnection screen you have a section to display summed up values
- reorganized app settings
- Changes for JBD:
  - display the bms error counts
  - reset the bms errors

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
