//
//  NotificationController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 28.11.20.
//

import NotificationBannerSwift

class NotificationController {
    
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(alertAvailable), name: Notification.Name("AlertAvailable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectUpdate), name: Notification.Name("disconnectUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFailToConnect), name: Notification.Name("didFailToConnect"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(parsingFailed), name: Notification.Name("parsingFailed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unavailableFunctionality), name: Notification.Name("unavailableFunctionality"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LionTronMode), name: Notification.Name("LionTronMode"), object: nil)
    }
    
    @objc func parsingFailed() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Unable to parse temperature sensors from your BMS! Please contact me via email (justin.kuehner@gmail.com) in order to help me fix this issue!",
                                                style: .warning)
        banner.haptic = .medium
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    
    @objc func alertAvailable() {
        let protection = BMSData.protectionArray()
        for i in 0...protection.count-2 {
            if protection[i] {
                let banner = FloatingNotificationBanner(title: "Warning:",
                                                        subtitle: BMSData.protectionDescription(index: i),
                                                        style: .danger)
                banner.haptic = .medium
                banner.autoDismiss = true
                banner.dismissOnTap = true
                banner.dismissOnSwipeUp = true
                banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
            }
        }
    }
    
    @objc func disconnectUpdate() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Lost connection to \(DevicesController.getConnectedDevice()!.getName())!",
                                                style: .warning)
        banner.haptic = .medium
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    @objc func didFailToConnect() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Connection to \(DevicesController.getConnectedDevice()!.getName()) failed!",
                                                style: .warning)
        banner.haptic = .medium
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    @objc func unavailableFunctionality() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Reading and writing is unavailable with a demo device!",
                                                style: .warning)
        banner.haptic = .light
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    @objc func LionTronMode() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Some functionality seem to be unavailable, some functions will be disabled.",
                                                style: .warning)
        banner.haptic = .light
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    @objc func CSVParsingFailed() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Failed to read and parse logfile. File might be corrupted.",
                                                style: .warning)
        banner.haptic = .none
        banner.autoDismiss = true
        banner.dismissOnTap = true
        banner.dismissOnSwipeUp = true
        banner.show(queuePosition: .back, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
}
