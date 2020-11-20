//
//  GPSController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 01.11.20.
//

import UIKit
import CoreLocation
import MBCircularProgressBar

class GPSController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var speedProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var efficiencyTableView: UITableView!
    
    @IBOutlet weak var PowerLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var latestLocation: CLLocation!
    
    var totalDistance: Double = 0.0 //meters
    
    var started = false
    var authenticated = false
    
    var topSpeed = 0.0 //km/h or mph
    //var maxPower = 0.0 //W
    var currentSpeed = 0.0 //m/s
    var efficiency = 0.0 //Wh/km or Wh/mi
    
    override func viewDidLoad() {
        efficiencyTableView.delegate = self
        efficiencyTableView.dataSource = self
        efficiencyTableView.allowsSelection = false
        print("GPSController: viewDidLoad()")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = SettingController.gpsAccuracy
        started = true
        locationManager.startUpdatingLocation()
        if #available(iOS 14.0, *) {
            print(locationManager.authorizationStatus)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "GPS"
        print("GPSController: viewWillAppear()")
        if started {
            print("Starting updates...")
            locationManager.startUpdatingLocation()
        }
        speedProgressBar.unitString = (SettingController.distanceUnit == SettingController.distanceEnum.kilometers) ? "km/h" : "mph"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("GPSController: viewWillDisappear()")
//        print("Stopping updates...")
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("OverviewDataAvailable"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
        authenticated = status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last?.speed != nil {
            if latestLocation != nil {
                totalDistance += latestLocation.distance(from: locations.last!)
            }
            
            
            let speed = locations.last?.speed ?? 0.0
            if speed < 0 {
                currentSpeed = 0.0
                efficiency = 0.0
                latestLocation = nil
                return
            }
            self.topSpeed = max(self.topSpeed, speed)
            if SettingController.distanceUnit == .kilometers {
                currentSpeed = round(speed * 3.6)
            }
            else {
                currentSpeed = round(speed * 2.23694)
            }
            
            let power = Double(BMSData.returnAverage()) / 100.0 * Double(cmd_basicInformation.totalVoltage ?? 0) / 100.0
//            if (Double(BMSData.returnAverage())) > 0.0 {
//                maxPower = max(maxPower, power)
////                print(maxPower)
//            }
//            else if (Double(BMSData.returnAverage())) < 0.0 {
//                maxPower = max(maxPower, power)
//            }
            if currentSpeed > 0.0 {
                efficiency = power/currentSpeed
            }
            else {
                efficiency = 0.0
            }
            self.speedProgressBar.maxValue = CGFloat((SettingController.distanceUnit == .kilometers) ? self.topSpeed*3.6 : self.topSpeed*2.23694)
            UIView.animate(withDuration: Double((SettingController.refreshTime / 1000)) * 0.8) {
                self.speedProgressBar.value = CGFloat(self.currentSpeed)
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
            cell.valueLabel.text = String(format: "%.0f", (SettingController.distanceUnit == .kilometers) ? self.topSpeed*3.6 : self.topSpeed*2.23694) + ((SettingController.distanceUnit == SettingController.distanceEnum.kilometers) ? " km/h" : " mph")
            break
        case 1:
            let power = Double(BMSData.returnAverage()) / 100.0 * Double(cmd_basicInformation.totalVoltage ?? 0) / 100.0
            cell.descriptionLabel.text = "Current power:"
            cell.valueLabel.text = String(format: "%.0f", power) + " W"
            break
        case 2:
            cell.descriptionLabel.text = "Rate of consumption:"
            cell.valueLabel.text = String(format: "%.1f", efficiency) + " Wh/" + ((SettingController.distanceUnit == SettingController.distanceEnum.kilometers) ? "km" : "mi")
            break
        case 3:
            cell.descriptionLabel.text = "Estimated range:"
            //TODO:                                                                                                         Change with battery type
            let remainingPower = Double(cmd_basicInformation.residualCapacity ?? 0) * Double(cmd_basicInformation.numberOfCells ?? 0) * 3.6 / 100.0
//            print(remainingPower)
//            print("\(cmd_basicInformation.residualCapacity ?? 0) \((cmd_basicInformation.numberOfCells ?? 0))")
            if efficiency == 0.0 || remainingPower == 0.0 {
                cell.valueLabel.text = "0" + ((SettingController.distanceUnit == SettingController.distanceEnum.kilometers) ? " km" : " mi")
                break
            }
            cell.valueLabel.text = String(format: "%.0f", remainingPower/efficiency) + ((SettingController.distanceUnit == SettingController.distanceEnum.kilometers) ? " km" : " mi")
            break
        case 4:
            cell.descriptionLabel.text = "Traveled distance:"
            if SettingController.distanceUnit == .kilometers {
                if totalDistance < 1000 {
                    cell.valueLabel.text = String(format: "%.0f", totalDistance) + " m"
                }
                else {
                    cell.valueLabel.text = String(format: "%.1f", totalDistance/1000.0) + " km"
                }
            }
            else {
                if totalDistance < 1609.34 {
                    cell.valueLabel.text = String(format: "%.0f", totalDistance*3.28084) + " ft"
                }
                else {
                    cell.valueLabel.text = String(format: "%.1f", totalDistance/1609.34) + " mi"
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
}
