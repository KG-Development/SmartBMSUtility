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
    @IBOutlet weak var backgroundSwitch: UISwitch!
    
    @IBOutlet weak var gpsAccuracyDetailLabel: UILabel!
    
    
    static var settings = AppSettings.Settings()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAndDisplaySettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fileController.saveAppSettings()
    }
    
    func loadAndDisplaySettings() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            SettingController.loadSettings()
            
            self.demoSwitch.isOn = SettingController.settings.useDemo
            self.backgroundSwitch.isOn = SettingController.settings.backgroundUpdating
            
            self.tempSegmentControl.selectedSegmentIndex = SettingController.settings.thermalUnit.rawValue
            self.distanceSegmentControl.selectedSegmentIndex = SettingController.settings.distanceUnit.rawValue
            
            switch SettingController.settings.gpsUnit {
            case .best:
                self.gpsAccuracyDetailLabel.text = "Best"
                break
            case .tenMeters:
                self.gpsAccuracyDetailLabel.text = "Ten meters"
                break
            case .hundretMeters:
                self.gpsAccuracyDetailLabel.text = "Hundred meters"
                break
            case .kilometers:
                self.gpsAccuracyDetailLabel.text = "Kilometers"
                break
            }
        }
    }
    
    static func loadSettings() {
        print("SettingsController: LoadSettings")
        let data = fileController.loadConfigFile(filename: "appSettings")
        if data == nil {
            print("Could not load Settings...")
            fileController.listConfigFiles()
            return
        }
        do {
            let newSettings = try JSONDecoder().decode(AppSettings.Settings.self, from: data!)
            SettingController.settings = newSettings
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 && indexPath.section == 1 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Best", style: .default) { _ in
                SettingController.settings.gpsAccuracy = kCLLocationAccuracyBest
                self.gpsAccuracyDetailLabel.text = "Best"
            })

            alert.addAction(UIAlertAction(title: "10 meters", style: .default) { _ in
                SettingController.settings.gpsAccuracy = kCLLocationAccuracyNearestTenMeters
                self.gpsAccuracyDetailLabel.text = "Ten meters"
            })
            
            alert.addAction(UIAlertAction(title: "100 meters", style: .default) { _ in
                SettingController.settings.gpsAccuracy = kCLLocationAccuracyHundredMeters
                self.gpsAccuracyDetailLabel.text = "Hundred meters"
            })
            
            alert.addAction(UIAlertAction(title: "1 kilometer", style: .default) { _ in
                SettingController.settings.gpsAccuracy = kCLLocationAccuracyKilometer
                self.gpsAccuracyDetailLabel.text = "Kilometers"
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
            })
            present(alert, animated: true)
        }
    }
    
    @IBAction func demoSwitched(_ sender: UISwitch) {
        SettingController.settings.useDemo = sender.isOn
    }
    
    @IBAction func backgroundSwitched(_ sender: UISwitch) {
        SettingController.settings.backgroundUpdating = sender.isOn
    }
    
    @IBAction func thermalChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            SettingController.settings.thermalUnit = .celsius
            break
        case 1:
            SettingController.settings.thermalUnit = .fahrenheit
            break
        default:
            SettingController.settings.thermalUnit = .celsius
        }
    }
    
    @IBAction func distanceChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            SettingController.settings.distanceUnit = .kilometers
            break
        case 1:
            SettingController.settings.distanceUnit = .miles
            break
        default:
            SettingController.settings.distanceUnit = .kilometers
        }
    }
}
