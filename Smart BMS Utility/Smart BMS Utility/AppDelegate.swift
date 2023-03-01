//
//  AppDelegate.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 11.10.20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UISceneDelegate {

    
    
    public static var timer: Timer?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(SettingController.settings.refreshTime) / 1000.0), target: self, selector: #selector(sendPacketNotification), userInfo: nil, repeats: true)
        fileController.createDirectories()
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Invalidating timer...")
        AppDelegate.timer?.invalidate()
    }

    // MARK: UISceneSession Lifecycle
    
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("connectingSceneSession")
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("didDiscardSceneSessions")
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("sceneDidDisconnect")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
    }

    
    
    @objc func sendPacketNotification() {
//        print("AppDelegate: sendPacketNotification()")
        if DevicesController.connectionMode == .bluetooth && !(OverviewController.BLEInterface?.pauseTransmission ?? false) {
            if UIApplication.shared.applicationState == .background {
                if !SettingController.settings.backgroundUpdating {
                    return
                }
            }
            NotificationCenter.default.post(name: Notification.Name("BluetoothSendNeeded"), object: nil)
        }
        if SettingController.settings.useDemo && DevicesController.connectionMode == .demo {
            NotificationCenter.default.post(name: Notification.Name("DemoDeviceNeeded"), object: nil)
        }
    }
    
}

