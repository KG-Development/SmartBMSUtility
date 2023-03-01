//
//  GPSController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 01.11.20.
//

import UIKit
import CoreLocation
import MBCircularProgressBar
import NotificationBannerSwift

class GPSController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var speedProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var efficiencyTableView: UITableView!
    
    @IBOutlet weak var PowerLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var latestLocation: CLLocation!
    
    static var totalDistance: Double = 0.0 //meters
    
    var started = false
    var authenticated = false
    
    static var topSpeed = 0.0 //km/h or mph
    static var currentSpeed = 0.0 //m/s
    static var efficiency = 0.0 //Wh/km or Wh/mi
    
    override func viewDidLoad() {
        efficiencyTableView.delegate = self
        efficiencyTableView.dataSource = self
        efficiencyTableView.allowsSelection = false
        print("GPSController: viewDidLoad()")
        locationManager.delegate = self
        if DevicesController.getConnectedDevice()?.settings.gpsLoggingEnabled ?? false {
            locationManager.requestAlwaysAuthorization()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.desiredAccuracy = SettingController.settings.gpsAccuracy
        started = true
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "GPS"
        print("GPSController: viewWillAppear()")
        if started {
            locationManager.startUpdatingLocation()
        }
        speedProgressBar.unitString = (SettingController.settings.distanceUnit == .kilometers) ? "km/h" : "mph"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("GPSController: viewWillDisappear()")
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("OverviewDataAvailable"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print(status)
        authenticated = status == .authorizedAlways || status == .authorizedWhenInUse
        print(authenticated)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last?.speed != nil {
            if latestLocation != nil {
                GPSController.totalDistance += latestLocation.distance(from: locations.last!)
            }
            
            
            let speed = locations.last?.speed ?? 0.0
            if speed == -1.0 {
                GPSController.currentSpeed = 0.0
                GPSController.efficiency = 0.0
                latestLocation = nil
                return
            }
            GPSController.topSpeed = max(GPSController.topSpeed, speed)
            if SettingController.settings.distanceUnit == .kilometers {
                GPSController.currentSpeed = round(speed * 3.6)
            }
            else {
                GPSController.currentSpeed = round(speed * 2.23694)
            }
            
            let power = Double((-BMSData.returnAverage())) / 100.0 * Double(cmd_basicInformation.totalVoltage ?? 0) / 100.0
            if GPSController.currentSpeed > 0.0 {
                GPSController.efficiency = power/GPSController.currentSpeed
            }
            else {
                GPSController.efficiency = 0.0
            }
            self.speedProgressBar.maxValue = CGFloat((SettingController.settings.distanceUnit == .kilometers) ? GPSController.topSpeed*3.6 : GPSController.topSpeed*2.23694)
            UIView.animate(withDuration: Double((SettingController.settings.refreshTime / 1000)) * 0.8) {
                self.speedProgressBar.value = CGFloat(GPSController.currentSpeed)
            }
            efficiencyTableView.reloadData()
            latestLocation = locations.last
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gpsCell", for: indexPath) as! gpsCell
        
        switch indexPath.row {
        case 0:
            cell.descriptionLabel.text = "Top speed:"
            cell.valueLabel.text = String(format: "%.0f", (SettingController.settings.distanceUnit == .kilometers) ? GPSController.topSpeed*3.6 : GPSController.topSpeed*2.23694) + ((SettingController.settings.distanceUnit == .kilometers) ? " km/h" : " mph")
            break
        case 1:
            cell.descriptionLabel.text = "Power:"
            let power = Double(Double(cmd_basicInformation.current ?? 0)/100) * Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100)
            cell.valueLabel.text = String(format: "%.0f", power) + " W"
            break
        case 2:
            cell.descriptionLabel.text = "Efficiency:"
            cell.valueLabel.text = String(format: "%.1f", GPSController.efficiency) + " Wh/" + ((SettingController.settings.distanceUnit == .kilometers) ? "km" : "mi")
            break
        case 3:
            cell.descriptionLabel.text = "Estimated range:"
            //TODO:                                                                                                         Change with battery type
            let remainingPower = Double(cmd_basicInformation.residualCapacity ?? 0) * Double(cmd_basicInformation.numberOfCells ?? 0) * 3.6 / 100.0
//            print(remainingPower)
//            print("\(cmd_basicInformation.residualCapacity ?? 0) \((cmd_basicInformation.numberOfCells ?? 0))")
            if GPSController.efficiency == 0.0 || remainingPower == 0.0 {
                cell.valueLabel.text = "0" + ((SettingController.settings.distanceUnit == .kilometers) ? " km" : " mi")
                break
            }
            cell.valueLabel.text = String(format: "%.0f", remainingPower/GPSController.efficiency) + ((SettingController.settings.distanceUnit == .kilometers) ? " km" : " mi")
            break
        case 4:
            cell.descriptionLabel.text = "Traveled distance:"
            if SettingController.settings.distanceUnit == .kilometers {
                if GPSController.totalDistance < 1000 {
                    cell.valueLabel.text = String(format: "%.0f", GPSController.totalDistance) + " m"
                }
                else {
                    cell.valueLabel.text = String(format: "%.1f", GPSController.totalDistance/1000.0) + " km"
                }
            }
            else {
                if GPSController.totalDistance < 1609.34 {
                    cell.valueLabel.text = String(format: "%.0f", GPSController.totalDistance*3.28084) + " ft"
                }
                else {
                    cell.valueLabel.text = String(format: "%.1f", GPSController.totalDistance/1609.34) + " mi"
                }
            }
            break
        default:
            break
            //print("GPSController: unimplemented tableviewcell: \(indexPath.row)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    @objc func reloadData() {
        efficiencyTableView.reloadData()
    }
    
    @objc func alertAvailable() {
        let protection = BMSData.protectionArray()
        for i in 0...protection.count-1 {
            if protection[i] {
                let banner = FloatingNotificationBanner(title: "Warning:",
                                                        subtitle: BMSData.protectionDescription(index: i),
                                                        style: .danger)
                banner.haptic = .medium
                banner.autoDismiss = true
                banner.show(queuePosition: .front, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
            }
        }
    }
    
    @objc func disconnectUpdate() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Lost connection to \(DevicesController.getConnectedDevice()!.getName())!",
                                                style: .warning)
        banner.haptic = .medium
        banner.autoDismiss = false
        banner.show(queuePosition: .front, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
    
    @objc func didFailToConnect() {
        let banner = FloatingNotificationBanner(title: "Warning:",
                                                subtitle: "Connection to \(DevicesController.getConnectedDevice()!.getName()) failed!",
                                                style: .warning)
        banner.haptic = .medium
        banner.autoDismiss = true
        banner.show(queuePosition: .front, bannerPosition: .top, queue: OverviewController.notificationQueue, on: nil)
    }
}
