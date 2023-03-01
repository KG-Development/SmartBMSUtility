//
//  OverviewController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 11.10.20.
//

import UIKit
import TYProgressBar
import NotificationBannerSwift
import LGButton

class OverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    static let onColors: [UIColor] = [UIColor(red: 0.395, green: 0.711, blue: 0.0, alpha: 0.85), UIColor(red: 0.042, green: 0.54, blue: 0.0, alpha: 0.85)]
    static let offColors: [UIColor] = [UIColor(red: 1, green: 0.455, blue: 0.0, alpha: 0.85), .systemRed]
    static let disabledColors: [UIColor] = [.gray, .systemGray]
    
    static var notificationQueue: NotificationBannerQueue!
    static var BLEInterface: BluetoothInterface?
    
    static var notificationManager = NotificationController()
    
    static var didCheckReadWriteMode = false
    
    @IBOutlet weak var batteryVoltageLabel: UILabel!
    @IBOutlet weak var batteryPowerLabel: UILabel!
    @IBOutlet weak var batteryCurrentLabel: UILabel!
    @IBOutlet weak var batteryCapacityLabel: UILabel!
    
    @IBOutlet weak var ChargingButton: LGButton!
    @IBOutlet weak var DischargingButton: LGButton!
    var chargingEnabled = true
    var dischargingEnabled = true
    var didLoadButtons = false
    
    static var retryCount = 0
    
    @IBOutlet weak var detailTableView: UITableView!
    
    @IBOutlet weak var progressBar: TYProgressBar!
    
    static var waitingForMosStatus = false
    var lastMosWriteReceived = Date().millisecondsSince1970 {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if Date().millisecondsSince1970 - self.lastMosWriteReceived > 1400 && OverviewController.waitingForMosStatus {
                    print("Re-updating MOS status!...")
                    OverviewController.retryCount += 1
                    self.sendMosStatus()
                }
            }
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OverviewController.notificationManager.setupObserver()
        //TODO: Set min/max according to LiIon/LiFePo
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.allowsSelection = false
        
        progressBar.debugInit()
        progressBar.lineDashPattern = [4, 2]
        progressBar.lineHeight = 14
        progressBar.font = UIFont(name: "HelveticaNeue-Medium", size: 23)!
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
        OverviewController.notificationQueue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 2)
        traitCollectionDidChange(nil)
        detailTableView.reloadData()
        progressBar.isCharging = false
        progressBar.lastIsCharging = false
        updateButtons()
    }
    
    @objc func dataAvailable() {
        testWriteMode()
        if (cmd_basicInformation.numberOfCells ?? 0) > 0 && !didLoadButtons {
            dischargingEnabled = cmd_basicInformation.dischargingPort
            chargingEnabled = cmd_basicInformation.chargingPort
            didLoadButtons = true
        }
        //print("OverviewController: dataAvailable()")
        progressBar.isCharging = (cmd_basicInformation.current ?? 0) != 0
        UIView.animate(withDuration: 0.8) {
            self.progressBar.progress = Double(cmd_basicInformation.rsoc ?? 0)/100.0
            if(cmd_basicInformation.rsoc ?? 0 >= 0 && cmd_basicInformation.rsoc ?? 0 <= 20) {
                let color = self.mapColor(color1: .red, color2: .yellow, value: self.map(x: CGFloat(cmd_basicInformation.rsoc ?? 0), in_min: 0.0, in_max: 20, out_min: 0.0, out_max: 100))
                self.progressBar.gradients = color
            }
            else if(cmd_basicInformation.rsoc ?? 0 > 20 && cmd_basicInformation.rsoc ?? 0 <= 40) {
                let color = self.mapColor(color1: .yellow, color2: .green, value: self.map(x: CGFloat(cmd_basicInformation.rsoc ?? 0), in_min: 21, in_max: 40, out_min: 0.0, out_max: 100))
                self.progressBar.gradients = color
            }
            else {
                self.progressBar.gradients = [.green, UIColor(red: 0.0, green: 1.0, blue: 0.45, alpha: 1.0)]
            }
        }
        let device = DevicesController.getConnectedDevice()
        if device == nil {
            return
        }
        batteryVoltageLabel.text = BMSData.convertToString(value: cmd_basicInformation.totalVoltage ?? 0) + " V"
        let power = abs(Double(Double(cmd_basicInformation.current ?? 0)/100) * Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100))
        if(power > device!.peakPower) {
            device!.peakPower = power
        }
        if(abs(Double(cmd_basicInformation.current ?? 0)) / Double(100) > device!.peakCurrent) {
            device!.peakCurrent = abs(Double(cmd_basicInformation.current ?? 0)) / Double(100)
        }
        batteryPowerLabel.text = String(format: "%.0f", power) + " W"
        batteryCurrentLabel.text = String(format: "%.2f", Double(cmd_basicInformation.current ?? 0) / 100.0) + " A"
        batteryCapacityLabel.text = "\(String(format: "%.2f", Double(cmd_basicInformation.residualCapacity ?? 0) / 100.0)) of \(String(format: "%.2f", Double(cmd_basicInformation.nominalCapacity ?? 0) / 100.0)) Ah"
        detailTableView.reloadData()
        detailTableView.estimatedRowHeight = 0
        detailTableView.estimatedSectionHeaderHeight = 0
        detailTableView.estimatedSectionFooterHeight = 0
        updateButtons()
    }
    
    func mapColor(color1: UIColor, color2: UIColor, value: CGFloat) -> [UIColor] {
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
        
        let red4: CGFloat = map(x: value, in_min: 10, in_max: 90, out_min: red1, out_max: red2)
        let green4: CGFloat = map(x: value, in_min: 10, in_max: 90, out_min: green1, out_max: green2)
        let blue4: CGFloat = map(x: value, in_min: 10, in_max: 90, out_min: blue1, out_max: blue2)
        return [UIColor(red: red3, green: green3, blue: blue3, alpha: 1.0), UIColor(red: red4, green: green4, blue: blue4, alpha: 0.95)]
    }
    
    func map(x: CGFloat, in_min: CGFloat, in_max: CGFloat, out_min: CGFloat, out_max: CGFloat) -> CGFloat {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    }
    
    func doubleToRemainingTime(time: Double) -> String {
        if time >= 1.0 {
            var returnString = String(format: "%.0f", floor(time)) + "h"
            let minuteRemainder = round(time.truncatingRemainder(dividingBy: 1.0) * 60)
            if minuteRemainder > 0 && minuteRemainder < 60 {
                returnString += ", " + String(format: "%.0f", minuteRemainder) + "min"
            }
            return returnString
        }
        else if time >= 0.0 {
            let minuteRemainder = time.truncatingRemainder(dividingBy: 1.0) * 60
            return String(format: "%.0f", round(minuteRemainder)) + "min"
        }
        return "unknown"
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
            let device = DevicesController.getConnectedDevice()!
            
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
                cell.valueLabel.text = String(format: "%.2f", device.peakCurrent) + " A"
                break
            case 3:
                cell.descriptionLabel.text = "Peak power:"
                cell.valueLabel.text = String(format: "%.0f", device.peakPower) + " W"
                break
            case 4:
                if device.lowestVoltage == 0.0 {
                    device.lowestVoltage = Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100)
                }
                if Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100) > 0.0 {
                    device.lowestVoltage = min(device.lowestVoltage, Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100))
                }
                
                cell.descriptionLabel.text = "Lowest voltage:"
                cell.valueLabel.text = String(format: "%.2f", device.lowestVoltage) + " V"
                break
            case 5:
                device.highestVoltage = max(device.highestVoltage, Double(Double(cmd_basicInformation.totalVoltage ?? 0)/100))
                
                cell.descriptionLabel.text = "Highest voltage:"
                cell.valueLabel.text = String(format: "%.2f", device.highestVoltage) + " V"
                break
            case 6:
                let current = BMSData.returnAverage()
                
                if current == 0 {
                    cell.descriptionLabel.text = "Remaining runtime:"
                    cell.valueLabel.text = " - "
                    BMSData.lastCurrentIndex = -1
                }
                else if current > 0 {
                    cell.descriptionLabel.text = "Remaining chargetime:"
                    let chargingCapacity = Int64(cmd_basicInformation.nominalCapacity ?? 0) - Int64(cmd_basicInformation.residualCapacity ?? 0)
                    let remainingTime = Double(chargingCapacity) / Double(current)
                    let remainingTimeString = doubleToRemainingTime(time: remainingTime*0.9)
                    cell.valueLabel.text = remainingTimeString
                }
                else {
                    cell.descriptionLabel.text = "Remaining runtime:"
                    let remainingTime = Double(cmd_basicInformation.residualCapacity ?? 0) / Double(-current)
                    let remainingTimeString = doubleToRemainingTime(time: remainingTime)
                    cell.valueLabel.text = remainingTimeString
                }
            default:
                let device = DevicesController.getConnectedDevice()
                if device == nil {
                    cell.descriptionLabel.text = "Temperature \(indexPath.row-6):"
                }
                else {
                    let description = DevicesController.getConnectedDevice()!.settings.getSensorName(index: indexPath.row-7) ?? "Temperature \(indexPath.row-6)"
                    
                    cell.descriptionLabel.text = description + ":"
                }
                let temperatureUnit = (SettingController.settings.thermalUnit == .celsius) ? "C" : "F"
                cell.valueLabel.text = String(format: "%.1f", cmd_basicInformation.temperatureReadings[indexPath.row-7]) + "°" + temperatureUnit
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoltageCell", for: indexPath) as! VoltageInfoCell
            
            cell.cellLabel.text = "Cell " + String(indexPath.row+1) + ":\t " + BMSData.convertToVoltageString(value: cmd_voltages.voltageOfCell[indexPath.row], decimalplaces: 3) + " V"
            let in_min = Float(cmd_configuration.CellEmptyVoltage ?? 3000) / 1000.0
            let in_max = Float(cmd_configuration.CellFullVoltage ?? 4200) / 1000.0
            cell.progressView.progress = self.map(x: Float(cmd_voltages.voltageOfCell[indexPath.row]) / 1000.0, in_min: in_min, in_max: in_max, out_min: 0.0, out_max: 1.0)
            
            UIView.animate(withDuration: Double((SettingController.settings.refreshTime / 1000)) * 0.35) {
                cell.balancingImage.alpha = (cmd_basicInformation.balanceCells[indexPath.row] ? CGFloat(1.0) : CGFloat(0.0))
            }
            
            #if targetEnvironment(macCatalyst)
            if self.view.bounds.width > 900 {
                cell.voltageWidthConstraint.constant = 500
            }
            else {
                cell.voltageWidthConstraint.constant = self.view.bounds.width - 400
            }
            #else
            #endif
            
            
            return cell
        }
    }
    
    func map(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float) -> Float {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.progressBar.progress = 0.0
        self.progressBar.textColor = .label
        dataAvailable()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if targetEnvironment(macCatalyst)
        return 36
        #endif
        return 28
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
            return "Cellseries voltages"
        default:
            return ""
        }
    }
    @IBAction func chargingPressed(_ sender: LGButton) {
        OverviewController.retryCount = 0
        chargingEnabled = !chargingEnabled
        sender.isLoading = true
        OverviewController.waitingForMosStatus = true
        lastMosWriteReceived = Date().millisecondsSince1970
        sendMosStatus()
        updateButtons()
    }
    
    @IBAction func dischargingPressed(_ sender: LGButton) {
        OverviewController.retryCount = 0
        dischargingEnabled = !dischargingEnabled
        sender.isLoading = true
        OverviewController.waitingForMosStatus = true
        lastMosWriteReceived = Date().millisecondsSince1970
        sendMosStatus()
        updateButtons()
    }
    
    func sendMosStatus() {
        var mosCode: UInt8 = 3
        if chargingEnabled {
            mosCode -= 1
        }
        if dischargingEnabled {
            mosCode -= 2
        }
        if OverviewController.retryCount <= 3 {
//            print("sending mosCode \(mosCode), chargingEnabled: \(chargingEnabled), dischargingEnabled: \(dischargingEnabled)")
            OverviewController.BLEInterface?.sendCustomRequest(data: [0xDD, 0x5A, 0xE1, 0x02, 0x00, mosCode, 0xFF, 0x1D - mosCode, 0x77])
        }
        else {
            OverviewController.waitingForMosStatus = false
            DischargingButton.isLoading = false
            ChargingButton.isLoading = false
        }
    }
    
    func updateButtons() {
        let device = DevicesController.getConnectedDevice()
        if device != nil {
            if device!.settings.liontronMode ?? false {
                DischargingButton.isEnabled = false
                DischargingButton.isLoading = false
                DischargingButton.gradientRotation = 45
                DischargingButton.gradientHorizontal = false
                DischargingButton.gradientStartColor = OverviewController.disabledColors[0]
                DischargingButton.gradientEndColor = OverviewController.disabledColors[1]
                ChargingButton.isLoading = false
                ChargingButton.isEnabled = false
                ChargingButton.gradientRotation = 45
                ChargingButton.gradientHorizontal = false
                ChargingButton.gradientStartColor = OverviewController.disabledColors[0]
                ChargingButton.gradientEndColor = OverviewController.disabledColors[1]
            }
            else {
                if chargingEnabled == cmd_basicInformation.chargingPort {
                    ChargingButton.isLoading = false
                }
                if dischargingEnabled == cmd_basicInformation.dischargingPort {
                    DischargingButton.isLoading = false
                }
                //        print("OverviewController: updateButtons()")
                ChargingButton.gradientStartColor = nil
                ChargingButton.gradientEndColor = nil
                ChargingButton.gradientRotation = 45
                ChargingButton.gradientHorizontal = false
                DischargingButton.gradientStartColor = nil
                DischargingButton.gradientEndColor = nil
                DischargingButton.gradientRotation = 45
                DischargingButton.gradientHorizontal = false
                
                
                if cmd_basicInformation.chargingPort {
                    ChargingButton.gradientStartColor = OverviewController.onColors[0]
                    ChargingButton.gradientEndColor = OverviewController.onColors[1]
                }
                else {
                    ChargingButton.gradientStartColor = OverviewController.offColors[0]
                    ChargingButton.gradientEndColor = OverviewController.offColors[1]
                }
                
                if cmd_basicInformation.dischargingPort {
                    DischargingButton.gradientStartColor = OverviewController.onColors[0]
                    DischargingButton.gradientEndColor = OverviewController.onColors[1]
                }
                else {
                    DischargingButton.gradientStartColor = OverviewController.offColors[0]
                    DischargingButton.gradientEndColor = OverviewController.offColors[1]
                }
            }
        }
    }
    
    
    func testWriteMode() {
        let device = DevicesController.getConnectedDevice()
        if device != nil && !(device!.settings.liontronMode ?? false) && !OverviewController.didCheckReadWriteMode {
            OverviewController.didCheckReadWriteMode = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                OverviewController.BLEInterface?.sendOpenReadWriteModeRequest()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                OverviewController.BLEInterface?.sendCloseReadWriteModeRequest()
            }
        }
    }
}
