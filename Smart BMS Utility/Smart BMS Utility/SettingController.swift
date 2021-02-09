//
//  SettingController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 11.10.20.
//

import UIKit
import CoreLocation

class SettingController: UITableViewController {
    
    //TODO: Write Userdefaults async
    
    @IBOutlet weak var tempSegmentControl: UISegmentedControl!
    @IBOutlet weak var distanceSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var demoSwitch: UISwitch!
    
    @IBOutlet weak var gpsAccuracyDetailLabel: UILabel!
    
    
    static var useBluetooth = true
    static var useDemo = true
    static var udpPort: Int32 = 4210
    static var distanceUnit: distanceEnum = .kilometers
    static var thermalUnit: thermalEnum = .celsius
    static var gpsAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    
    static var refreshTime: Int = 1000
    
    
    public enum distanceEnum {
        case kilometers
        case miles
    }
    
    public enum thermalEnum {
        case fahrenheit
        case celsius
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAndDisplaySettings()
    }
    
    
    func loadAndDisplaySettings() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("SettingController: loadAndDisplaySettings()")
            
//            let bluetooth = UserDefaults.standard.object(forKey: "com.nearix.Smart-BMS-Utility:useBluetooth") as? Bool
            let demo = UserDefaults.standard.object(forKey: "com.nearix.Smart-BMS-Utility:useDemo") as? Bool
//            if bluetooth != nil {
//                SettingController.useBluetooth = bluetooth!
//            }
            if demo != nil {
                SettingController.useDemo = demo!
            }
            
//            self.bluetoothButton.isOn = SettingController.useBluetooth
            self.demoSwitch.isOn = SettingController.useDemo
            
            let distanceInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:distanceUnit")
            let thermalInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:thermalUnit")
            let accuracyInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:accuracyInt")
            
            self.tempSegmentControl.selectedSegmentIndex = thermalInt
            self.distanceSegmentControl.selectedSegmentIndex = distanceInt
            
            switch distanceInt {
            case 0:
                SettingController.distanceUnit = .kilometers
                break
            case 1:
                SettingController.distanceUnit = .miles
                break
            default:
                SettingController.distanceUnit = .kilometers
            }
            
            switch thermalInt {
            case 0:
                SettingController.thermalUnit = .celsius
                break
            case 1:
                SettingController.thermalUnit = .fahrenheit
                break
            default:
                SettingController.thermalUnit = .celsius
            }
            
            switch accuracyInt {
            case 0:
                SettingController.gpsAccuracy = kCLLocationAccuracyBest
                self.gpsAccuracyDetailLabel.text = "Best"
                break
            case 1:
                SettingController.gpsAccuracy = kCLLocationAccuracyNearestTenMeters
                self.gpsAccuracyDetailLabel.text = "Ten meters"
                break
            case 2:
                SettingController.gpsAccuracy = kCLLocationAccuracyHundredMeters
                self.gpsAccuracyDetailLabel.text = "Hundred meters"
                break
            case 3:
                SettingController.gpsAccuracy = kCLLocationAccuracyKilometer
                self.gpsAccuracyDetailLabel.text = "Kilometers"
                break
            default:
                break
            }
        }
    }
    
    static func loadSettings() {
        print("SettingController: loadSettings()")
        
//        let bluetooth = UserDefaults.standard.object(forKey: "com.nearix.Smart-BMS-Utility:useBluetooth") as? Bool
        let demo = UserDefaults.standard.object(forKey: "com.nearix.Smart-BMS-Utility:useDemo") as? Bool
//        if bluetooth != nil {
//            SettingController.useBluetooth = bluetooth!
//        }
        if demo != nil {
            SettingController.useDemo = demo!
        }
        
        
        let distanceInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:distanceUnit")
        let thermalInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:thermalUnit")
        let accuracyInt = UserDefaults.standard.integer(forKey: "com.nearix.Smart-BMS-Utility:accuracyInt")
        
        switch distanceInt {
        case 0:
            SettingController.distanceUnit = .kilometers
            break
        case 1:
            SettingController.distanceUnit = .miles
            break
        default:
            SettingController.distanceUnit = .kilometers
        }
        
        switch thermalInt {
        case 0:
            SettingController.thermalUnit = .celsius
            break
        case 1:
            SettingController.thermalUnit = .fahrenheit
            break
        default:
            SettingController.thermalUnit = .celsius
        }
        
        switch accuracyInt {
        case 0:
            SettingController.gpsAccuracy = kCLLocationAccuracyBest
            break
        case 1:
            SettingController.gpsAccuracy = kCLLocationAccuracyNearestTenMeters
            break
        case 2:
            SettingController.gpsAccuracy = kCLLocationAccuracyHundredMeters
            break
        case 3:
            SettingController.gpsAccuracy = kCLLocationAccuracyKilometer
            break
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 && indexPath.section == 1 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Best", style: .default) { _ in
                SettingController.gpsAccuracy = kCLLocationAccuracyBest
                self.gpsAccuracyDetailLabel.text = "Best"
            })

            alert.addAction(UIAlertAction(title: "10 meters", style: .default) { _ in
                SettingController.gpsAccuracy = kCLLocationAccuracyNearestTenMeters
                self.gpsAccuracyDetailLabel.text = "Ten meters"
            })
            
            alert.addAction(UIAlertAction(title: "100 meters", style: .default) { _ in
                SettingController.gpsAccuracy = kCLLocationAccuracyHundredMeters
                self.gpsAccuracyDetailLabel.text = "Hundred meters"
            })
            
            alert.addAction(UIAlertAction(title: "1 kilometer", style: .default) { _ in
                SettingController.gpsAccuracy = kCLLocationAccuracyKilometer
                self.gpsAccuracyDetailLabel.text = "Kilometers"
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
            })

            present(alert, animated: true)
        }
        else if indexPath.row == 3 && indexPath.section == 1 {
            guard let url = URL(string: "https://github.com/NeariX67/SmartBMSUtility/blob/main/Credits.md") else { return }
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func bluetoothSwitched(_ sender: UISwitch) {
        SettingController.useBluetooth = sender.isOn
        UserDefaults.standard.setValue(sender.isOn, forKey: "com.nearix.Smart-BMS-Utility:useBluetooth")
    }
    @IBAction func demoSwitched(_ sender: UISwitch) {
        SettingController.useDemo = sender.isOn
        UserDefaults.standard.setValue(sender.isOn, forKey: "com.nearix.Smart-BMS-Utility:useDemo")
    }
    
    @IBAction func thermalChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            SettingController.thermalUnit = .celsius
            break
        case 1:
            SettingController.thermalUnit = .fahrenheit
            break
        default:
            print("SettingController: Unknown thermal segment: \(sender.selectedSegmentIndex)")
            SettingController.thermalUnit = .celsius
        }
        UserDefaults.standard.setValue(sender.selectedSegmentIndex, forKey: "com.nearix.Smart-BMS-Utility:thermalUnit")
    }
    
    @IBAction func distanceChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            SettingController.distanceUnit = .kilometers
            break
        case 1:
            SettingController.distanceUnit = .miles
            break
        default:
            print("SettingController: Unknown distance segment: \(sender.selectedSegmentIndex)")
            SettingController.distanceUnit = .kilometers
        }
        UserDefaults.standard.setValue(sender.selectedSegmentIndex, forKey: "com.nearix.Smart-BMS-Utility:distanceUnit")
    }
}
