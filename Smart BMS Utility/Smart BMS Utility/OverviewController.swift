//
//  OverviewController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 11.10.20.
//

import UIKit
import MBCircularProgressBar

class OverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static var BLEInterface: BluetoothInterface?
    
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    
    @IBOutlet weak var batteryVoltageLabel: UILabel!
    @IBOutlet weak var batteryPowerLabel: UILabel!
    @IBOutlet weak var batteryCurrentLabel: UILabel!
    
    @IBOutlet weak var detailTableView: UITableView!
    
    
    static var peakPower = 0.0
    static var peakCurrent = 0.0
    static var lowestVoltage = 0.0
    static var highestVoltage = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set min/max according to LiIon/LiFePo
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.allowsSelection = false
        
//        OverviewController.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(SettingController.refreshTime) / 1000.0), target: self, selector: #selector(sendPacketNotification), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(dataAvailable), name: Notification.Name("OverviewDataAvailable"), object: nil)
//        if OverviewController.timer != nil {
//            return
//        }
//        if !OverviewController.timer!.isValid {
//            print("Timer invalid... recreating...")
//            OverviewController.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(SettingController.refreshTime) / 1000.0), target: self, selector: #selector(sendPacketNotification), userInfo: nil, repeats: true)
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cmd_basicInformation.numberOfTempSensors = 2
        detailTableView.reloadData()
    }
    
    @objc func dataAvailable() {
        //print("OverviewController: dataAvailable()")
        
        UIView.animate(withDuration: 0.8) {
            self.progressBar.value = CGFloat(cmd_basicInformation.rsoc ?? 0)
            if(cmd_basicInformation.rsoc ?? 0 >= 0 && cmd_basicInformation.rsoc ?? 0 <= 20) {
                let color = self.mapColor(color1: .red, color2: .yellow, value: self.map(x: CGFloat(cmd_basicInformation.rsoc ?? 0), in_min: 0.0, in_max: 20, out_min: 0.0, out_max: 100))
                self.progressBar.progressColor = color
                self.progressBar.progressStrokeColor = color
            }
            else if(cmd_basicInformation.rsoc ?? 0 > 20 && cmd_basicInformation.rsoc ?? 0 <= 40) {
                let color = self.mapColor(color1: .yellow, color2: .green, value: self.map(x: CGFloat(cmd_basicInformation.rsoc ?? 0), in_min: 21, in_max: 40, out_min: 0.0, out_max: 100))
                self.progressBar.progressColor = color
                self.progressBar.progressStrokeColor = color
            }
            else {
                self.progressBar.progressColor = .green
                self.progressBar.progressStrokeColor = .green
            }
        }
        
        
        
        batteryVoltageLabel.text = BMSData.convertToString(value: cmd_basicInformation.totalVoltage ?? 0) + " V"
        let power = Double(Double(cmd_basicInformation.current ?? 0)/100) * Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100)
        if(power > OverviewController.peakPower) {
            OverviewController.peakPower = power
        }
        if(Double(cmd_basicInformation.current ?? 0) / Double(100) > OverviewController.peakCurrent) {
            OverviewController.peakCurrent = Double(cmd_basicInformation.current ?? 0) / Double(100)
        }
        batteryPowerLabel.text = String(format: "%.0f", power) + " W"
        batteryCurrentLabel.text = String(format: "%.2f", Double(cmd_basicInformation.current ?? 0) / 100.0) + " A"
//        lowestCellLabel.text = BMSData.convertToVoltageString(value: BMSData.getLowestCell().1, decimalplaces: 3) + " V"
//        averageCellVoltage.text = BMSData.convertToVoltageString(value: UInt16(BMSData.getAvgCell()), decimalplaces: 3) + " V"
//        highestCellVoltage.text = BMSData.convertToVoltageString(value: UInt16(BMSData.getHighestCell().1), decimalplaces: 3) + " V"
//        peakCurrentLabel.text = String(format: "%.2f", peakCurrent) + " A"
        detailTableView.reloadData()
    }
    
    
    func mapColor(color1: UIColor, color2: UIColor, value: CGFloat) -> UIColor {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: nil)
        
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: nil)
        
        
        let red3: CGFloat = map(x: value, in_min: 0.0, in_max: 100, out_min: red1, out_max: red2)
        let green3: CGFloat = map(x: value, in_min: 0.0, in_max: 100, out_min: green1, out_max: green2)
        let blue3: CGFloat = map(x: value, in_min: 0.0, in_max: 100, out_min: blue1, out_max: blue2)
        return UIColor(red: red3, green: green3, blue: blue3, alpha: 1.0)
    }
    
    func map(x: CGFloat, in_min: CGFloat, in_max: CGFloat, out_min: CGFloat, out_max: CGFloat) -> CGFloat {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    }
    
    func doubleToRemainingTime(time: Double) -> String {
        if time >= 1.0 {
            var returnString = String(format: "%.0f", time) + "h"
            let minuteRemainder = round(time.truncatingRemainder(dividingBy: 1.0) * 60)
            if minuteRemainder > 0 {
                //print(minuteRemainder)
                returnString += ", " + String(format: "%.0f", minuteRemainder) + "min"
            }
            return returnString
        }
        else {
            let minuteRemainder = time.truncatingRemainder(dividingBy: 1.0) * 60
            return String(format: "%.0f", round(minuteRemainder)) + "min"
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 7 + Int(cmd_basicInformation.numberOfTempSensors ?? 0)
        }
        else {
            return Int(cmd_basicInformation.numberOfCells ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "informationCell", for: indexPath) as! detailCell
            
            switch indexPath.row {
            case 0:
                cell.descriptionLabel.text = "Lowest cellvoltage:"
                cell.valueLabel.text = String(format: "%.3f", Double(BMSData.getLowestCell().1) / 1000.0) + " V"
                break
            case 1:
                cell.descriptionLabel.text = "Highest cellvoltage:"
                cell.valueLabel.text = String(format: "%.3f", Double(BMSData.getHighestCell().1) / 1000.0) + " V"
                break
            case 2:
                cell.descriptionLabel.text = "Peak amperage:"
                cell.valueLabel.text = String(format: "%.2f", OverviewController.peakCurrent) + " A"
                break
            case 3:
                cell.descriptionLabel.text = "Peak power:"
                cell.valueLabel.text = String(format: "%.0f", OverviewController.peakPower) + " W"
                break
            case 4:
                if OverviewController.lowestVoltage == 0.0 {
                    OverviewController.lowestVoltage = Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100)
                }
                if Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100) > 0.0 {
                    OverviewController.lowestVoltage = min(OverviewController.lowestVoltage, Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100))
                }
                
                cell.descriptionLabel.text = "Lowest voltage:"
                cell.valueLabel.text = String(format: "%.2f", OverviewController.lowestVoltage) + " V"
                break
            case 5:
                OverviewController.highestVoltage = max(OverviewController.highestVoltage, Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100))
                
                cell.descriptionLabel.text = "Highest voltage:"
                cell.valueLabel.text = String(format: "%.2f", OverviewController.highestVoltage) + " V"
                break
            case 6:
                let current = BMSData.returnAverage()
                
                if current == 0 {
                    cell.descriptionLabel.text = "Remaining runtime:"
                    cell.valueLabel.text = " - "
                }
                else if current < 0 {
                    cell.descriptionLabel.text = "Remaining chargetime:"
                    let remainingTime = Double((cmd_basicInformation.nominalCapacity ?? 0) - (cmd_basicInformation.residualCapacity ?? 0)) / Double(-current)
                    let remainingTimeString = doubleToRemainingTime(time: remainingTime*0.9)
                    cell.valueLabel.text = remainingTimeString
                }
                else {
                    cell.descriptionLabel.text = "Remaining runtime:"
                    let remainingTime = Double(cmd_basicInformation.residualCapacity ?? 0) / Double(current)
                    let remainingTimeString = doubleToRemainingTime(time: remainingTime)
                    cell.valueLabel.text = remainingTimeString
                }
            default:
                var description = UserDefaults.standard.string(forKey: "com.nearix.Smart-BMS-Utility:\(DevicesController.getConnectedDevice().getIdentifier()):\(indexPath.row-7)")
                if description == nil || description == "" {
                    description = "Temperature \(indexPath.row-6)"
                }
                cell.descriptionLabel.text = description! + ":"
                let temperatureUnit = (SettingController.thermalUnit == .celsius) ? "C" : "F"
                cell.valueLabel.text = String(format: "%.1f", cmd_basicInformation.temperatureReadings[indexPath.row-7]) + "°" + temperatureUnit
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoltageCell", for: indexPath) as! VoltageInfoCell
            cell.cellLabel.text = "Cell " + String(indexPath.row+1) + ":\t " + BMSData.convertToVoltageString(value: cmd_voltages.voltageOfCell[indexPath.row], decimalplaces: 3) + " V"
            
//            UIView.setAnimationsEnabled(true)
//            UIView.animate(withDuration: Double(SettingController.refreshTime) / 1000.0 * 0.8) {
//            } Pretty buggy, do not use?
            
            cell.progressView.setProgress(self.map(x: Float(cmd_voltages.voltageOfCell[indexPath.row]) / 1000.0, in_min: 3.0, in_max: 4.2, out_min: 0.0, out_max: 1.0), animated: true)
            cell.balancingImage.alpha = (cmd_basicInformation.balanceCells[indexPath.row] ? CGFloat(1.0) : CGFloat(0.0))
            return cell
        }
    }
    
    func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        progressBar.value = 0.0
        dataAvailable()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Cellvoltages"
        default:
            return ""
        }
    }
}
