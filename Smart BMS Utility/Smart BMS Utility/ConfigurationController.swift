//
//  ConfigurationController.swift
//  Smart BMS Utility
//
//  Created by Justin on 31.12.20.
//

import UIKit
import SkyFloatingLabelTextField
import BEMCheckBox
import LGButton
import JGProgressHUD

class ConfigurationController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var readDataButton: LGButton!
    @IBOutlet weak var writeDataButton: LGButton!
    
    
    // MARK: -  General
    @IBOutlet weak var tfDeviceName: SkyFloatingLabelTextField!
    @IBOutlet weak var tfBarcode: SkyFloatingLabelTextField!
    @IBOutlet weak var tfNumberOfCells: SkyFloatingLabelTextField!
    
    // MARK: -  Capacity settings
    @IBOutlet weak var tfTotalBatteryCapacity: SkyFloatingLabelTextField!
    @IBOutlet weak var tfTotalCycleCapacity: SkyFloatingLabelTextField!
    @IBOutlet weak var tfSelfDischargeRate: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellFullVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tf80PercentVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tf60PercentVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tf40PercentVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tf20PercentVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellEmptyVoltage: SkyFloatingLabelTextField!
    
    // MARK: -  Balancing
    @IBOutlet weak var tfBalancingStartVoltage: SkyFloatingLabelTextField!
    @IBOutlet weak var tfBalancingVoltageDelta: SkyFloatingLabelTextField!
    @IBOutlet weak var cbEnableBalancing: BEMCheckBox!
    @IBOutlet weak var cbBalancingOnlyWhileCharging: BEMCheckBox!
    
    // MARK: -  BMS Functions
    @IBOutlet weak var cbCapacityIndicatorLEDs: BEMCheckBox!
    @IBOutlet weak var cbEnableOnboardLEDs: BEMCheckBox!
    @IBOutlet weak var cbWaitForLoadDisconnect: BEMCheckBox!
    @IBOutlet weak var cbEnableHardwareSwitch: BEMCheckBox!
    
    // MARK: -  Protection Settings
    //CellOVP
    @IBOutlet weak var tfCellOVPTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellOVPRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellOVPDelay: SkyFloatingLabelTextField!
    //CellUVP
    @IBOutlet weak var tfCellUVPTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellUVPRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfCellUVPDelay: SkyFloatingLabelTextField!
    //PackOVP
    @IBOutlet weak var tfPackOVPTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPackOVPRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPackOVPDelay: SkyFloatingLabelTextField!
    //PackUVP
    @IBOutlet weak var tfPackUVPTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPackUVPRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfPackUVPDelay: SkyFloatingLabelTextField!
    //ChargeOC
    @IBOutlet weak var tfChargeOCTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeOCRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeOCDelay: SkyFloatingLabelTextField!
    //DischargeOC
    @IBOutlet weak var tfDischargeOCTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeOCRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeOCDelay: SkyFloatingLabelTextField!
    //ChargeOT
    @IBOutlet weak var tfChargeOTTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeOTRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeOTDelay: SkyFloatingLabelTextField!
    @IBOutlet weak var lbChargeOTTriggerUnit: UILabel!
    @IBOutlet weak var lbChargeOTReleaseUnit: UILabel!
    //ChargeUT
    @IBOutlet weak var tfChargeUTTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeUTRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfChargeUTDelay: SkyFloatingLabelTextField!
    @IBOutlet weak var lbChargeUTTriggerUnit: UILabel!
    @IBOutlet weak var lbChargeUTReleaseUnit: UILabel!
    //DischargeOT
    @IBOutlet weak var tfDischargeOTTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeOTRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeOTDelay: SkyFloatingLabelTextField!
    @IBOutlet weak var lbDischargeOTTriggerUnit: UILabel!
    @IBOutlet weak var lbDischargeOTReleaseUnit: UILabel!
    //DischargeUT
    @IBOutlet weak var tfDischargeUTTrigger: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeUTRelease: SkyFloatingLabelTextField!
    @IBOutlet weak var tfDischargeUTDelay: SkyFloatingLabelTextField!
    @IBOutlet weak var lbDischargeUTTriggerUnit: UILabel!
    @IBOutlet weak var lbDischargeUTReleaseUnit: UILabel!
    
    // MARK: -  NTC Sensors
    
    @IBOutlet weak var cbNTC1: BEMCheckBox!
    @IBOutlet weak var cbNTC2: BEMCheckBox!
    @IBOutlet weak var cbNTC3: BEMCheckBox!
    @IBOutlet weak var cbNTC4: BEMCheckBox!
    @IBOutlet weak var cbNTC5: BEMCheckBox!
    @IBOutlet weak var cbNTC6: BEMCheckBox!
    @IBOutlet weak var cbNTC7: BEMCheckBox!
    @IBOutlet weak var cbNTC8: BEMCheckBox!
    
    
    var progressHUD = JGProgressHUD()
    static var WritingStarted = false
    static var WritingCommandsNeeded = 0
    
    var alreadyRead = false
    
    static var retryCount = 0
    
    
    //Actually not just NTC, but any BEMCheckBox element thats connected
    @IBAction func NTCPressed(_ sender: BEMCheckBox) {
        switch sender {
        case cbEnableBalancing:
            print("cbEnableBalancing")
        case cbBalancingOnlyWhileCharging:
            print("cbBalancingOnlyWhileCharging")
        case cbCapacityIndicatorLEDs:
            print("cbCapacityIndicatorLEDs")
        case cbEnableOnboardLEDs:
            print("cbEnableOnboardLEDs")
        case cbWaitForLoadDisconnect:
            print("cbWaitForLoadDisconnect")
        case cbEnableHardwareSwitch:
            print("cbEnableHardwareSwitch")
        case cbNTC1:
            print("cbNTC1")
        case cbNTC2:
            print("cbNTC2")
        case cbNTC3:
            print("cbNTC3")
        case cbNTC4:
            print("cbNTC4")
        case cbNTC5:
            print("cbNTC5")
        case cbNTC6:
            print("cbNTC6")
        case cbNTC7:
            print("cbNTC7")
        case cbNTC8:
            print("cbNTC8")
        default:
            print("unknown sender for BEMCheckBox Event")
        }
    }
    
    
    static var requestSendStarted = false
    static var remainingReadAddresses: [UInt8] = cmd_configuration.Addresses
    static var remainingWriteAddresses = [[UInt8]]()
    static var lastReadDataReceived = Date().millisecondsSince1970 {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if Date().millisecondsSince1970 - self.lastReadDataReceived > 1400 && ConfigurationController.requestSendStarted {
                    print("ConfigurationController: Didn't receive data in the last 2 seconds. Retrying...")
                    retryCount += retryCount + 1
                    ConfigurationController.sendNextReadRequest(address: 0)
                }
            }
        }
    }
    static var lastWriteDataReceived = Date().millisecondsSince1970 {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if Date().millisecondsSince1970 - self.lastWriteDataReceived > 1400 && ConfigurationController.WritingStarted {
                    print("ConfigurationController: Didn't receive data in the last 2 seconds. Retrying...")
                    retryCount += retryCount + 1
                    ConfigurationController.sendNextWriteCommand(address: 0)
                }
                else {
//                    print("\(Date().millisecondsSince1970 - self.lastWriteDataReceived > 1400), \(ConfigurationController.WritingStarted)")
                }
            }
        }
    }
    
    @objc func updateReadDataButton() {
        let device = DevicesController.getConnectedDevice()
        if device != nil {
            if device!.settings.liontronMode ?? false {
                print("Disabling read bms button")
                readDataButton.isEnabled = false
                readDataButton.isLoading = false
                readDataButton.gradientRotation = 45
                readDataButton.gradientHorizontal = false
                readDataButton.gradientStartColor = OverviewController.disabledColors[0]
                readDataButton.gradientEndColor = OverviewController.disabledColors[1]
                readDataButton.layoutSubviews()
            }
            else {
                print("Enabling read bms button")
                readDataButton.isEnabled = true
                readDataButton.isLoading = false
                readDataButton.gradientRotation = 45
                readDataButton.gradientHorizontal = false
                readDataButton.gradientStartColor = .systemOrange
                readDataButton.gradientEndColor = UIColor.init(named: "buttonColor")
                readDataButton.layoutSubviews()
            }
        }
    }
    
    func reloadUnitLabels() {
        var unit = ""
        if SettingController.settings.thermalUnit == .celsius {
            unit = "°C"
        }
        else {
            unit = "°F"
        }
        lbChargeOTTriggerUnit.text = unit
        lbChargeOTReleaseUnit.text = unit
        lbChargeUTTriggerUnit.text = unit
        lbChargeUTReleaseUnit.text = unit
        lbDischargeOTTriggerUnit.text = unit
        lbDischargeOTReleaseUnit.text = unit
        lbDischargeUTTriggerUnit.text = unit
        lbDischargeUTReleaseUnit.text = unit
    }
    
    
    
    
    override func viewDidLoad() {
        print("ConfigurationController: viewDidLoad()")
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        reloadUnitLabels()
        updateReadDataButton()
        updateTextfieldKeyboardTypes()
        updateTextfieldLimits()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ConfigurationController: viewDidAppear()")
        super.viewDidAppear(animated)
        updateReadDataButton()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextFields), name: Notification.Name("ConfigurationDataAvailable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(abortReadWrite), name: Notification.Name("abortReadWrite"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTextFieldAfterWrite(_:)), name: Notification.Name("ConfigurationDataWritten"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateReadDataButton), name: Notification.Name("LionTronMode"), object: nil)
        if DevicesController.connectionMode == .demo {
            print("demo device")
            NotificationCenter.default.post(name: Notification.Name("unavailableFunctionality"), object: nil)
            writeDataButton.isHidden = true
            readDataButton.isHidden = true
        }
        else if !readDataButton.isEnabled {
            OverviewController.BLEInterface?.pauseTransmission = true
        }
        else {
            OverviewController.BLEInterface?.pauseTransmission = true
            OverviewController.BLEInterface?.sendOpenReadWriteModeRequest()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        OverviewController.BLEInterface?.pauseTransmission = false
        ConfigurationController.requestSendStarted = false
        ConfigurationController.WritingStarted = false
        if readDataButton.isEnabled {
            OverviewController.BLEInterface?.sendCloseReadWriteModeRequest()
        }
        NotificationCenter.default.removeObserver(self)
        if !alreadyRead {
            writeDataButton.isHidden = true
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func abortReadWrite() {
        self.view.isUserInteractionEnabled = true
        self.tabBarController?.view.isUserInteractionEnabled = true
        progressHUD.textLabel.text = "Could not read data"
        progressHUD.indicatorView = JGProgressHUDErrorIndicatorView()
        progressHUD.dismiss(afterDelay: 0.5, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = header.textLabel?.font.withSize(24)
        
        let accentColor = UIColor(named: "AccentColor") ?? .label
        header.textLabel?.textColor = accentColor
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    @objc func updateTextFields(_ notification: Notification) {
        guard let commandCode = notification.userInfo?["commandCode"] as? UInt8 else {
            return
        }
        switch commandCode {
        case cmd_configuration.connectionType.FullCapacity.rawValue:
            tfTotalBatteryCapacity.originalText = ConvertToString(cmd_configuration.FullCapacity, multiplier: 10)
            break
        case cmd_configuration.connectionType.CycleCapacity.rawValue:
            tfTotalCycleCapacity.originalText = ConvertToString(cmd_configuration.CycleCapacity, multiplier: 10)
            break
        case cmd_configuration.connectionType.CellFullVoltage.rawValue:
            tfCellFullVoltage.originalText = ConvertToString(cmd_configuration.CellFullVoltage, multiplier: 1)
            DevicesController.getConnectedDevice()?.settings.cellFullVoltage = cmd_configuration.CellFullVoltage ?? 4200
            break
        case cmd_configuration.connectionType.CellEmptyVoltage.rawValue:
            tfCellEmptyVoltage.originalText = ConvertToString(cmd_configuration.CellEmptyVoltage, multiplier: 1)
            DevicesController.getConnectedDevice()?.settings.cellEmptyVoltage = cmd_configuration.CellEmptyVoltage ?? 3000
            break
        case cmd_configuration.connectionType.RateDsg.rawValue:
            tfSelfDischargeRate.originalText = ConvertToString(cmd_configuration.RateDsg, divider: 10)
            break
        case cmd_configuration.connectionType.ChgOTPtrig.rawValue:
            tfChargeOTTrigger.originalText = UInt16ToTemp(reading: cmd_configuration.ChgOTPtrig)
            break
        case cmd_configuration.connectionType.ChgOTPrel.rawValue:
            tfChargeOTRelease.originalText = UInt16ToTemp(reading: cmd_configuration.ChgOTPrel)
            break
        case cmd_configuration.connectionType.ChgUTPtrig.rawValue:
            tfChargeUTTrigger.originalText = UInt16ToTemp(reading: cmd_configuration.ChgUTPtrig)
            break
        case cmd_configuration.connectionType.ChgUTPrel.rawValue:
            tfChargeUTRelease.originalText = UInt16ToTemp(reading: cmd_configuration.ChgUTPrel)
            break
        case cmd_configuration.connectionType.DsgOTPtrig.rawValue:
            tfDischargeOTTrigger.originalText = UInt16ToTemp(reading: cmd_configuration.DsgOTPtrig)
            break
        case cmd_configuration.connectionType.DsgOTPrel.rawValue:
            tfDischargeOTRelease.originalText = UInt16ToTemp(reading: cmd_configuration.DsgOTPrel)
            break
        case cmd_configuration.connectionType.DsgUTPtrig.rawValue:
            tfDischargeUTTrigger.originalText = UInt16ToTemp(reading: cmd_configuration.DsgUTPtrig)
            break
        case cmd_configuration.connectionType.DsgUTPrel.rawValue:
            tfDischargeUTRelease.originalText = UInt16ToTemp(reading: cmd_configuration.DsgUTPrel)
            break
        case cmd_configuration.connectionType.PackOVPtrig.rawValue:
            tfPackOVPTrigger.originalText = ConvertToString(cmd_configuration.PackOVPtrig, multiplier: 10)
            break
        case cmd_configuration.connectionType.PackOVPrel.rawValue:
            tfPackOVPRelease.originalText = ConvertToString(cmd_configuration.PackOVPrel, multiplier: 10)
            break
        case cmd_configuration.connectionType.PackUVPtrig.rawValue:
            tfPackUVPTrigger.originalText = ConvertToString(cmd_configuration.PackUVPtrig, multiplier: 10)
            break
        case cmd_configuration.connectionType.PackUVPrel.rawValue:
            tfPackUVPRelease.originalText = ConvertToString(cmd_configuration.PackUVPrel, multiplier: 10)
            break
        case cmd_configuration.connectionType.CellOVPtrig.rawValue:
            tfCellOVPTrigger.originalText = ConvertToString(cmd_configuration.CellOVPtrig, multiplier: 1)
            break
        case cmd_configuration.connectionType.CellOVPrel.rawValue:
            tfCellOVPRelease.originalText = ConvertToString(cmd_configuration.CellOVPrel, multiplier: 1)
            break
        case cmd_configuration.connectionType.CellUVPtrig.rawValue:
            tfCellUVPTrigger.originalText = ConvertToString(cmd_configuration.CellUVPtrig, multiplier: 1)
            break
        case cmd_configuration.connectionType.CellUVPrel.rawValue:
            tfCellUVPRelease.originalText = ConvertToString(cmd_configuration.CellUVPrel, multiplier: 1)
            break
        case cmd_configuration.connectionType.ChgOCP.rawValue:
            tfChargeOCTrigger.originalText = ConvertToString(cmd_configuration.ChgOCP, multiplier: 10)
            break
        case cmd_configuration.connectionType.DsgOCP.rawValue:
            tfDischargeOCTrigger.originalText = ConvertToString(cmd_configuration.DsgOCP, multiplier: 10)
            break
        case cmd_configuration.connectionType.BalanceStartVoltage.rawValue:
            tfBalancingStartVoltage.originalText = ConvertToString(cmd_configuration.BalanceStartVoltage, multiplier: 1)
            break
        case cmd_configuration.connectionType.BalanceVoltageDelta.rawValue:
            tfBalancingVoltageDelta.originalText = ConvertToString(cmd_configuration.BalanceVoltageDelta, multiplier: 1)
            break
        case cmd_configuration.connectionType.BalanceSwitches.rawValue:
            cbEnableBalancing.setOn(cmd_configuration.BalanceEnable, animated: false)
            cbBalancingOnlyWhileCharging.setOn(cmd_configuration.BalanceOnlyWhileCharging, animated: false)
            cbCapacityIndicatorLEDs.setOn(cmd_configuration.LEDCapacityIndicator, animated: false)
            cbEnableOnboardLEDs.setOn(cmd_configuration.LEDEnable, animated: false)
            cbWaitForLoadDisconnect.setOn(cmd_configuration.LoadDetect, animated: false)
            cbEnableHardwareSwitch.setOn(cmd_configuration.HardwareSwitch, animated: false)
            cbEnableBalancing.originalValue = cmd_configuration.BalanceEnable
            cbBalancingOnlyWhileCharging.originalValue = cmd_configuration.BalanceOnlyWhileCharging
            cbCapacityIndicatorLEDs.originalValue = cmd_configuration.LEDCapacityIndicator
            cbEnableOnboardLEDs.originalValue = cmd_configuration.LEDEnable
            cbWaitForLoadDisconnect.originalValue = cmd_configuration.LoadDetect
            cbEnableHardwareSwitch.originalValue = cmd_configuration.HardwareSwitch
            break
        case cmd_configuration.connectionType.NTCSensorEnable.rawValue:
            cbNTC1.originalValue = cmd_configuration.NTCSensorEnable[0]
            cbNTC2.originalValue = cmd_configuration.NTCSensorEnable[1]
            cbNTC3.originalValue = cmd_configuration.NTCSensorEnable[2]
            cbNTC4.originalValue = cmd_configuration.NTCSensorEnable[3]
            cbNTC5.originalValue = cmd_configuration.NTCSensorEnable[4]
            cbNTC6.originalValue = cmd_configuration.NTCSensorEnable[5]
            cbNTC7.originalValue = cmd_configuration.NTCSensorEnable[6]
            cbNTC8.originalValue = cmd_configuration.NTCSensorEnable[7]
            cbNTC1.setOn(cmd_configuration.NTCSensorEnable[0], animated: false)
            cbNTC2.setOn(cmd_configuration.NTCSensorEnable[1], animated: false)
            cbNTC3.setOn(cmd_configuration.NTCSensorEnable[2], animated: false)
            cbNTC4.setOn(cmd_configuration.NTCSensorEnable[3], animated: false)
            cbNTC5.setOn(cmd_configuration.NTCSensorEnable[4], animated: false)
            cbNTC6.setOn(cmd_configuration.NTCSensorEnable[5], animated: false)
            cbNTC7.setOn(cmd_configuration.NTCSensorEnable[6], animated: false)
            cbNTC8.setOn(cmd_configuration.NTCSensorEnable[7], animated: false)
            break
        case cmd_configuration.connectionType.CellCount.rawValue:
            tfNumberOfCells.originalText = ConvertToString(cmd_configuration.CellCount, multiplier: 1)
            break
        case cmd_configuration.connectionType.Capacity80.rawValue:
            tf80PercentVoltage.originalText = ConvertToString(cmd_configuration.Capacity80, multiplier: 1)
            break
        case cmd_configuration.connectionType.Capacity60.rawValue:
            tf60PercentVoltage.originalText = ConvertToString(cmd_configuration.Capacity60, multiplier: 1)
            break
        case cmd_configuration.connectionType.Capacity40.rawValue:
            tf40PercentVoltage.originalText = ConvertToString(cmd_configuration.Capacity40, multiplier: 1)
            break
        case cmd_configuration.connectionType.Capacity20.rawValue:
            tf20PercentVoltage.originalText = ConvertToString(cmd_configuration.Capacity20, multiplier: 1)
            break
        case cmd_configuration.connectionType.ChargeTempDelay.rawValue:
            tfChargeOTDelay.originalText = ConvertToString(cmd_configuration.ChgOTPdel, multiplier: 1)
            tfChargeUTDelay.originalText = ConvertToString(cmd_configuration.ChgUTPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.DischargeTempDelay.rawValue:
            tfDischargeUTDelay.originalText = ConvertToString(cmd_configuration.DsgUTPdel, multiplier: 1)
            tfDischargeOTDelay.originalText = ConvertToString(cmd_configuration.DsgOTPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.PackVoltageProtectionDelay.rawValue:
            tfPackOVPDelay.originalText = ConvertToString(cmd_configuration.PackOVPdel, multiplier: 1)
            tfPackUVPDelay.originalText = ConvertToString(cmd_configuration.PackUVPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.CellVoltageProtectionDelay.rawValue:
            tfCellOVPDelay.originalText = ConvertToString(cmd_configuration.CellOVPdel, multiplier: 1)
            tfCellUVPDelay.originalText = ConvertToString(cmd_configuration.CellUVPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.ChargeOvercurrent.rawValue:
            tfChargeOCRelease.originalText = ConvertToString(cmd_configuration.ChgOCPrel, multiplier: 1)
            tfChargeOCDelay.originalText = ConvertToString(cmd_configuration.ChgOCPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.DischargeOvercurrent.rawValue:
            tfDischargeOCRelease.originalText = ConvertToString(cmd_configuration.DsgOCPrel, multiplier: 1)
            tfDischargeOCDelay.originalText = ConvertToString(cmd_configuration.DsgOCPdel, multiplier: 1)
            break
        case cmd_configuration.connectionType.Model.rawValue:
            tfDeviceName.originalText = cmd_configuration.Model
            break
        case cmd_configuration.connectionType.Barcode.rawValue:
            tfBarcode.originalText = cmd_configuration.Barcode
            break
        default:
            print("ConfigurationController: Did find an unknown Textfield update command: \(String(format:"%02X", commandCode))")
            break
        }
        
        let progress = map(x: CGFloat(ConfigurationController.remainingReadAddresses.count), in_min: 0, in_max: CGFloat(cmd_configuration.Addresses.count), out_min: 1.0, out_max: 0.0)
        progressHUD.progress = Float(progress)
        print("ConfigurationController: Progress \(String(format: "%.2f", progress)), remaining: \(ConfigurationController.remainingReadAddresses.count), size \(cmd_configuration.Addresses.count)")
        if ConfigurationController.remainingReadAddresses.count == 0 {
            self.view.isUserInteractionEnabled = true
            self.tabBarController?.view.isUserInteractionEnabled = true
            progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            progressHUD.dismiss(afterDelay: 0.4, animated: true)
            alreadyRead = true
            DevicesController.getConnectedDevice()?.saveDeviceSettings()
            UIView.animate(withDuration: 0.3) {
                self.writeDataButton.isHidden = false
            }
        }
    }
    
    
    @objc func refreshTextFieldAfterWrite(_ notification: Notification) {
        guard let commandCode = notification.userInfo?["commandCode"] as? UInt8 else {
            return
        }
        switch commandCode {
        case cmd_configuration.connectionType.FullCapacity.rawValue:
            tfTotalBatteryCapacity.originalText = tfTotalBatteryCapacity.text
            break
        case cmd_configuration.connectionType.CycleCapacity.rawValue:
            tfTotalCycleCapacity.originalText = tfTotalCycleCapacity.text
            break
        case cmd_configuration.connectionType.CellFullVoltage.rawValue:
            tfCellFullVoltage.originalText = tfCellFullVoltage.text
            DevicesController.getConnectedDevice()?.settings.cellFullVoltage = cmd_configuration.CellFullVoltage ?? 4200
            break
        case cmd_configuration.connectionType.CellEmptyVoltage.rawValue:
            tfCellEmptyVoltage.originalText = tfCellEmptyVoltage.text
            DevicesController.getConnectedDevice()?.settings.cellEmptyVoltage = cmd_configuration.CellEmptyVoltage ?? 3000
            break
        case cmd_configuration.connectionType.RateDsg.rawValue:
            tfSelfDischargeRate.originalText = tfSelfDischargeRate.text
            break
        case cmd_configuration.connectionType.ProdDate.rawValue:
            //Unused
            break
        case cmd_configuration.connectionType.CycleCount.rawValue:
            //Unused
            break
        case cmd_configuration.connectionType.ChgOTPtrig.rawValue:
            tfChargeOTTrigger.originalText = tfChargeOTTrigger.text
            break
        case cmd_configuration.connectionType.ChgOTPrel.rawValue:
            tfChargeOTRelease.originalText = tfChargeOTRelease.text
            break
        case cmd_configuration.connectionType.ChgUTPtrig.rawValue:
            tfChargeUTTrigger.originalText = tfChargeUTTrigger.text
            break
        case cmd_configuration.connectionType.ChgUTPrel.rawValue:
            tfChargeUTRelease.originalText = tfChargeUTRelease.text
            break
        case cmd_configuration.connectionType.DsgOTPtrig.rawValue:
            tfDischargeOTTrigger.originalText = tfDischargeOTTrigger.text
            break
        case cmd_configuration.connectionType.DsgOTPrel.rawValue:
            tfDischargeOTRelease.originalText = tfDischargeOTRelease.text
            break
        case cmd_configuration.connectionType.DsgUTPtrig.rawValue:
            tfDischargeUTTrigger.originalText = tfDischargeUTTrigger.text
            break
        case cmd_configuration.connectionType.DsgUTPrel.rawValue:
            tfDischargeUTRelease.originalText = tfDischargeUTRelease.text
            break
        case cmd_configuration.connectionType.PackOVPtrig.rawValue:
            tfPackOVPTrigger.originalText = tfPackOVPTrigger.text
            break
        case cmd_configuration.connectionType.PackOVPrel.rawValue:
            tfPackOVPRelease.originalText = tfPackOVPRelease.text
            break
        case cmd_configuration.connectionType.PackUVPtrig.rawValue:
            tfPackUVPTrigger.originalText = tfPackUVPTrigger.text
            break
        case cmd_configuration.connectionType.PackUVPrel.rawValue:
            tfPackUVPRelease.originalText = tfPackUVPRelease.text
            break
        case cmd_configuration.connectionType.CellOVPtrig.rawValue:
            tfCellOVPTrigger.originalText = tfCellOVPTrigger.text
            break
        case cmd_configuration.connectionType.CellOVPrel.rawValue:
            tfCellOVPRelease.originalText = tfCellOVPRelease.text
            break
        case cmd_configuration.connectionType.CellUVPtrig.rawValue:
            tfCellUVPTrigger.originalText = tfCellUVPTrigger.text
            break
        case cmd_configuration.connectionType.CellUVPrel.rawValue:
            tfCellUVPRelease.originalText = tfCellUVPRelease.text
            break
        case cmd_configuration.connectionType.ChgOCP.rawValue:
            tfChargeOCTrigger.originalText = tfChargeOCTrigger.text
            break
        case cmd_configuration.connectionType.DsgOCP.rawValue:
            tfDischargeOCTrigger.originalText = tfDischargeOCTrigger.text
            break
        case cmd_configuration.connectionType.BalanceStartVoltage.rawValue:
            tfBalancingStartVoltage.originalText = tfBalancingStartVoltage.text
            break
        case cmd_configuration.connectionType.BalanceVoltageDelta.rawValue:
            tfBalancingVoltageDelta.originalText = tfBalancingVoltageDelta.text
            break
        case cmd_configuration.connectionType.BalanceSwitches.rawValue:
            cbEnableBalancing.originalValue = cbEnableBalancing.on
            cbBalancingOnlyWhileCharging.originalValue = cbBalancingOnlyWhileCharging.on
            cbCapacityIndicatorLEDs.originalValue = cbCapacityIndicatorLEDs.on
            cbEnableOnboardLEDs.originalValue = cbEnableOnboardLEDs.on
            cbWaitForLoadDisconnect.originalValue = cbWaitForLoadDisconnect.on
            cbEnableHardwareSwitch.originalValue = cbEnableHardwareSwitch.on
            break
        case cmd_configuration.connectionType.NTCSensorEnable.rawValue:
            cbNTC1.originalValue = cbNTC1.on
            cbNTC2.originalValue = cbNTC2.on
            cbNTC3.originalValue = cbNTC3.on
            cbNTC4.originalValue = cbNTC4.on
            cbNTC5.originalValue = cbNTC5.on
            cbNTC6.originalValue = cbNTC6.on
            cbNTC7.originalValue = cbNTC7.on
            cbNTC8.originalValue = cbNTC8.on
            break
        case cmd_configuration.connectionType.CellCount.rawValue:
            tfNumberOfCells.originalText = tfNumberOfCells.text
            break
        case cmd_configuration.connectionType.Capacity80.rawValue:
            tf80PercentVoltage.originalText = tf80PercentVoltage.text
            break
        case cmd_configuration.connectionType.Capacity60.rawValue:
            tf60PercentVoltage.originalText = tf60PercentVoltage.text
            break
        case cmd_configuration.connectionType.Capacity40.rawValue:
            tf40PercentVoltage.originalText = tf40PercentVoltage.text
            break
        case cmd_configuration.connectionType.Capacity20.rawValue:
            tf20PercentVoltage.originalText = tf20PercentVoltage.text
            break
        case cmd_configuration.connectionType.HardCellOVP.rawValue:
            //Unused
            break
        case cmd_configuration.connectionType.HardCellUVP.rawValue:
            //Unused
            break
        case cmd_configuration.connectionType.ChargeTempDelay.rawValue:
            tfChargeOTDelay.originalText = tfChargeOTDelay.text
            tfChargeUTDelay.originalText = tfChargeUTDelay.text
            break
        case cmd_configuration.connectionType.DischargeTempDelay.rawValue:
            tfDischargeOTDelay.originalText = tfDischargeOTDelay.text
            tfDischargeUTDelay.originalText = tfDischargeUTDelay.text
            break
        case cmd_configuration.connectionType.PackVoltageProtectionDelay.rawValue:
            tfPackOVPDelay.originalText = tfPackOVPDelay.text
            tfPackUVPDelay.originalText = tfPackUVPDelay.text
            break
        case cmd_configuration.connectionType.CellVoltageProtectionDelay.rawValue:
            tfCellOVPDelay.originalText = tfCellOVPDelay.text
            tfCellUVPDelay.originalText = tfCellUVPDelay.text
            break
        case cmd_configuration.connectionType.ChargeOvercurrent.rawValue:
            tfChargeOCDelay.originalText = tfChargeOCDelay.text
            tfChargeOCRelease.originalText = tfChargeOCRelease.text
            break
        case cmd_configuration.connectionType.DischargeOvercurrent.rawValue:
            tfDischargeOCRelease.originalText = tfDischargeOCRelease.text
            tfDischargeOCDelay.originalText = tfDischargeOCDelay.text
            break
        case cmd_configuration.connectionType.SerialNumber.rawValue:
            //Unused
            break
        case cmd_configuration.connectionType.Model.rawValue:
            tfDeviceName.originalText = tfDeviceName.text
            break
        case cmd_configuration.connectionType.Barcode.rawValue:
            tfBarcode.originalText = tfBarcode.text
            break
        default:
            break
        }
        
        let progress = map(x: CGFloat(ConfigurationController.remainingWriteAddresses.count), in_min: 0, in_max: CGFloat(ConfigurationController.WritingCommandsNeeded), out_min: 1.0, out_max: 0.0)
        progressHUD.progress = Float(progress)
        print("ConfigurationController: Progress \(String(format: "%.2f", progress)), remaining: \(ConfigurationController.remainingWriteAddresses.count)")
        if ConfigurationController.remainingWriteAddresses.count == 0 {
            self.view.isUserInteractionEnabled = true
            self.tabBarController?.view.isUserInteractionEnabled = true
            ConfigurationController.WritingStarted = false
            progressHUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            progressHUD.dismiss(afterDelay: 0.4, animated: true)
        }
    }
    
    
    func updateTextfieldKeyboardTypes() {
        tfDeviceName.keyboardType = .default
        tfBarcode.keyboardType = .default
        tfSelfDischargeRate.keyboardType = .decimalPad
        tfChargeOTTrigger.keyboardType = .numbersAndPunctuation
        tfChargeOTRelease.keyboardType = .numbersAndPunctuation
        tfChargeUTTrigger.keyboardType = .numbersAndPunctuation
        tfChargeUTRelease.keyboardType = .numbersAndPunctuation
        tfDischargeOTTrigger.keyboardType = .numbersAndPunctuation
        tfDischargeOTRelease.keyboardType = .numbersAndPunctuation
        tfDischargeUTTrigger.keyboardType = .numbersAndPunctuation
        tfDischargeUTRelease.keyboardType = .numbersAndPunctuation
    }
    
    
    func updateTextfieldLimits() {
        tfDeviceName.maxStringLength = 32
        tfBarcode.maxStringLength = 32
        tfNumberOfCells.maxIntValue = 32
        tfNumberOfCells.minIntValue = 3
        tfTotalBatteryCapacity.maxIntValue = 655350
        tfTotalBatteryCapacity.minIntValue = 0
        tfTotalBatteryCapacity.multipleOf = 10
        tfTotalCycleCapacity.maxIntValue = 655350
        tfTotalCycleCapacity.minIntValue = 0
        tfTotalCycleCapacity.multipleOf = 10
        tfSelfDischargeRate.minDoubleValue = 0.0
        tfSelfDischargeRate.maxDoubleValue = 40.0
        tfSelfDischargeRate.maxDecimalPlaces = 1
        tfCellFullVoltage.maxIntValue = 4500
        tfCellEmptyVoltage.minIntValue = 2600
        tf80PercentVoltage.maxIntValue = 4500
        tf80PercentVoltage.minIntValue = 2000
        tf80PercentVoltage.maxIntValue = 4500
        tf60PercentVoltage.minIntValue = 2000
        tf60PercentVoltage.maxIntValue = 4500
        tf40PercentVoltage.minIntValue = 2000
        tf40PercentVoltage.maxIntValue = 4500
        tf20PercentVoltage.minIntValue = 2000
        tf20PercentVoltage.maxIntValue = 4500
        tfCellEmptyVoltage.minIntValue = 2000
        tfCellEmptyVoltage.maxIntValue = 4000
        tfBalancingStartVoltage.minIntValue = 2600
        tfBalancingStartVoltage.maxIntValue = 4500
        tfBalancingVoltageDelta.minIntValue = 5
        tfBalancingVoltageDelta.maxIntValue = 300
        tfCellOVPTrigger.minIntValue = 3000
        tfCellOVPTrigger.maxIntValue = 4500
        tfCellOVPRelease.minIntValue = 3000
        tfCellOVPRelease.maxIntValue = 4500
        tfCellOVPDelay.minIntValue = 1
        tfCellOVPDelay.maxIntValue = 120
        tfCellUVPTrigger.minIntValue = 2300
        tfCellUVPTrigger.maxIntValue = 4500
        tfCellUVPRelease.minIntValue = 3000
        tfCellUVPRelease.maxIntValue = 4500
        tfCellUVPDelay.minIntValue = 1
        tfCellUVPDelay.maxIntValue = 120
        //tfPack UVP and OVP trigger and release values are not implemented
        tfPackOVPTrigger.multipleOf = 10
        tfPackOVPRelease.multipleOf = 10
        tfPackUVPTrigger.multipleOf = 10
        tfPackUVPRelease.multipleOf = 10
        tfPackOVPDelay.minIntValue = 1
        tfPackOVPDelay.maxIntValue = 120
        tfPackUVPDelay.minIntValue = 1
        tfPackUVPDelay.maxIntValue = 120
        tfChargeOCTrigger.minIntValue = 0
        tfChargeOCTrigger.maxIntValue = 0xFFFF*10
        tfChargeOCTrigger.multipleOf = 10
        tfChargeOCRelease.minIntValue = 1
        tfChargeOCRelease.maxIntValue = 120
        tfChargeOCDelay.minIntValue = 1
        tfChargeOCDelay.maxIntValue = 120
        tfDischargeOCTrigger.minIntValue = 10
        tfDischargeOCTrigger.maxIntValue = 0xFFFF*10
        tfDischargeOCTrigger.multipleOf = 10
        tfDischargeOCRelease.minIntValue = 1
        tfDischargeOCRelease.maxIntValue = 120
        tfDischargeOCDelay.minIntValue = 1
        tfDischargeOCDelay.maxIntValue = 120
        tfChargeOTTrigger.maxStringLength = 3
        tfChargeOTRelease.maxStringLength = 3
        tfChargeOTDelay.minIntValue = 1
        tfChargeOTDelay.maxIntValue = 120
        tfChargeUTTrigger.maxStringLength = 3
        tfChargeUTRelease.maxStringLength = 3
        tfChargeUTDelay.minIntValue = 1
        tfChargeUTDelay.maxIntValue = 120
        tfDischargeOTTrigger.maxStringLength = 3
        tfDischargeOTRelease.maxStringLength = 3
        tfDischargeOTDelay.minIntValue = 1
        tfDischargeOTDelay.maxIntValue = 120
        tfDischargeUTTrigger.maxStringLength = 3
        tfDischargeUTRelease.maxStringLength = 3
        tfDischargeUTDelay.minIntValue = 1
        tfDischargeUTDelay.maxIntValue = 120
    }
    
    
    static func sendNextReadRequest(address: UInt8) {
        if address == 225 { //MOS Code
            return
        }
        if retryCount > 3 {
            NotificationCenter.default.post(name: Notification.Name("abortReadWrite"), object: nil)
            retryCount = 0
            return
        }
        if ConfigurationController.remainingReadAddresses.count == 0 {
            ConfigurationController.requestSendStarted = false
            print("ConfigurationController: Finished reading all addresses")
            DevicesController.getConnectedDevice()?.saveDeviceSettings()
//            cmd_configuration.printConfiguration()
            return
        }
        if let index = ConfigurationController.remainingReadAddresses.firstIndex(of: address) {
            ConfigurationController.remainingReadAddresses.remove(at: index)
//            print("Removed index \(index) (\(element))")
        }
        if ConfigurationController.requestSendStarted {
            let addr = ConfigurationController.remainingReadAddresses.first ?? 0 //Should not use default as the function would abort if the array is empty
            if addr == 0 {
                return
            }
            print("ConfigurationController: Sending request for \(String(format:"%02X", addr)), \(ConfigurationController.remainingReadAddresses.count) more to send")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                OverviewController.BLEInterface?.sendReadRequest(address: addr)
                if ConfigurationController.remainingReadAddresses.count > 1 {
                    ConfigurationController.lastReadDataReceived = Date().millisecondsSince1970
                }
            }
        }
    }
    
    static func sendNextWriteCommand(address: UInt8) {
        if address == 225 { //MOS Code
            return
        }
        if retryCount > 3 {
            NotificationCenter.default.post(name: Notification.Name("abortReadWrite"), object: nil)
            retryCount = 0
            return
        }
        if ConfigurationController.remainingWriteAddresses.count == 0 {
            let userInfo = [ "commandCode" : address ]
            NotificationCenter.default.post(name: Notification.Name("ConfigurationDataWritten"), object: nil, userInfo: userInfo)
            ConfigurationController.WritingStarted = false
            print("ConfigurationController: Finished writing all addresses")
            DevicesController.getConnectedDevice()?.saveDeviceSettings()
            return
        }
        for i in 0...ConfigurationController.remainingWriteAddresses.count-1 {
            if ConfigurationController.remainingWriteAddresses[i][2] == address {
                ConfigurationController.remainingWriteAddresses.remove(at: i)
                break
            }
        }
        if ConfigurationController.WritingStarted {
            let userInfo = [ "commandCode" : address ]
            NotificationCenter.default.post(name: Notification.Name("ConfigurationDataWritten"), object: nil, userInfo: userInfo)
            let bytes = ConfigurationController.remainingWriteAddresses.first ?? [0]
            if bytes == [0] {
                return
            }
            print("ConfigurationController: Sending request for \(String(format:"%02X", bytes[2])), \(ConfigurationController.remainingWriteAddresses.count) more to send")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                ConfigurationController.WritingStarted = true
                OverviewController.BLEInterface?.sendCustomRequest(data: bytes)
                if ConfigurationController.remainingWriteAddresses.count > 0 {
                    ConfigurationController.lastWriteDataReceived = Date().millisecondsSince1970
                }
            }
        }
    }
    
    func ConvertToString(_ value: UInt8?, multiplier: Int) -> String {
        if value == nil {
            return ""
        }
        return "\(Int(value!) * multiplier)"
    }
    
    func ConvertToString(_ value: UInt16?, multiplier: Int) -> String {
        if value == nil {
            return ""
        }
        return "\(Int(value!) * multiplier)"
    }
    
    func ConvertToString(_ value: UInt16?, divider: Double) -> String {
        if value == nil {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let number = Double(value! ) / divider
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    func UInt16ToTemp(reading: UInt16?) -> String {
        if reading == nil {
            return ""
        }
        let temp: Int32 = Int32(reading!)
        if SettingController.settings.thermalUnit == .celsius {
            return String(format: "%.0f", Double(temp-2731) / Double(10.0)) //SWIFT WTF
        }
        else {
            return String(format: "%.0f", (Double(temp-2731) / 10.0 * 1.8) + 32)
        }
    }
    
    func IntToKelvin(_ value: Int) -> UInt16 {
        if SettingController.settings.thermalUnit == .celsius {
            let temp = 2731 + (value*10)
            return UInt16(temp)
        }
        else {
            let temp = Double(value-32) / 1.8
            return UInt16(temp + 2731)
        }
    }
    
    @IBAction func writeButton(_ sender: LGButton) {
        loadChangesIntoWriteAddresses()
        print("ConfigurationController: Need to write \(ConfigurationController.remainingWriteAddresses.count) values...")
//        if ConfigurationController.remainingWriteAddresses.count > 0 {
//            for arr in ConfigurationController.remainingWriteAddresses {
//                printHex(data: arr)
//            }
//        }
        if ConfigurationController.remainingWriteAddresses.count > 0 {
            ConfigurationController.WritingStarted = true
            ConfigurationController.WritingCommandsNeeded = ConfigurationController.remainingWriteAddresses.count
            ConfigurationController.retryCount = 0
            self.view.isUserInteractionEnabled = false
            self.tabBarController?.view.isUserInteractionEnabled = false
            progressHUD.textLabel.text = "Writing data to BMS..."
            progressHUD.indicatorView = JGProgressHUDRingIndicatorView()
            progressHUD.progress = 0.0
            progressHUD.show(in: self.view)
            ConfigurationController.sendNextWriteCommand(address: 0)
        }
    }
    
    @IBAction func readButton(_ sender: LGButton) {
        ConfigurationController.requestSendStarted = true
        ConfigurationController.remainingReadAddresses = cmd_configuration.Addresses
        ConfigurationController.sendNextReadRequest(address: 0)
        progressHUD.textLabel.text = "Reading data from BMS..."
        progressHUD.indicatorView = JGProgressHUDRingIndicatorView()
        progressHUD.progress = 0.0
        ConfigurationController.retryCount = 0
        self.view.isUserInteractionEnabled = false
        self.tabBarController?.view.isUserInteractionEnabled = false
        progressHUD.show(in: self.view)
    }
    
    func loadChangesIntoWriteAddresses() { //TODO: Fix adding empty textfields
        ConfigurationController.remainingWriteAddresses.removeAll()
        
        let request = bmsRequest()
        request.statusByte = 0x5A
        
        if tfDeviceName.hasChanged() && !tfDeviceName.hasErrorMessage && !tfDeviceName.isEmpty {
            request.commandByte = 0xA1
            let data = StringToASCII(text: tfDeviceName.text ?? "")
            request.lengthByte = UInt8(data.count)
            request.dataBytes = data
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfBarcode.hasChanged() && !tfBarcode.hasErrorMessage && !tfBarcode.isEmpty {
            request.commandByte = 0xA2
            let data = StringToASCII(text: tfBarcode.text ?? "")
            request.lengthByte = UInt8(data.count)
            request.dataBytes = data
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        
        
        // MARK: - Important: do not use commands with datalength greater than 2 under here
        request.lengthByte = 2
        
        if tfNumberOfCells.hasChanged() && !tfNumberOfCells.hasErrorMessage && !tfNumberOfCells.isEmpty {
            request.commandByte = 0x2F
            let value = UInt16(tfNumberOfCells.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfTotalBatteryCapacity.hasChanged() && !tfTotalBatteryCapacity.hasErrorMessage && !tfTotalBatteryCapacity.isEmpty {
            request.commandByte = 0x10
            let value = UInt32(tfTotalBatteryCapacity.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfTotalCycleCapacity.hasChanged() && !tfTotalCycleCapacity.hasErrorMessage && !tfTotalCycleCapacity.isEmpty {
            request.commandByte = 0x11
            let value = UInt32(tfTotalCycleCapacity.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfSelfDischargeRate.hasChanged() && !tfSelfDischargeRate.hasErrorMessage && !tfSelfDischargeRate.isEmpty {
            request.commandByte = 0x14
            let text = (tfSelfDischargeRate.text ?? "0.0").replacingOccurrences(of: ",", with: ".")
            let value = Double(text) ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value*10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellFullVoltage.hasChanged() && !tfCellFullVoltage.hasErrorMessage && !tfCellFullVoltage.isEmpty {
            request.commandByte = 0x12
            let value = UInt16(tfCellFullVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tf80PercentVoltage.hasChanged() && !tf80PercentVoltage.hasErrorMessage && !tf80PercentVoltage.isEmpty {
            request.commandByte = 0x32
            let value = UInt16(tf80PercentVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tf60PercentVoltage.hasChanged() && !tf60PercentVoltage.hasErrorMessage && !tf60PercentVoltage.isEmpty {
            request.commandByte = 0x33
            let value = UInt16(tf60PercentVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tf40PercentVoltage.hasChanged() && !tf40PercentVoltage.hasErrorMessage && !tf40PercentVoltage.isEmpty {
            request.commandByte = 0x34
            let value = UInt16(tf40PercentVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tf20PercentVoltage.hasChanged() && !tf20PercentVoltage.hasErrorMessage && !tf20PercentVoltage.isEmpty {
            request.commandByte = 0x35
            let value = UInt16(tf20PercentVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellEmptyVoltage.hasChanged() && !tfCellEmptyVoltage.hasErrorMessage && !tfCellEmptyVoltage.isEmpty {
            request.commandByte = 0x13
            let value = UInt16(tfCellEmptyVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfBalancingStartVoltage.hasChanged() && !tfBalancingStartVoltage.hasErrorMessage && !tfBalancingStartVoltage.isEmpty {
            request.commandByte = 0x2A
            let value = UInt16(tfBalancingStartVoltage.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfBalancingVoltageDelta.hasChanged() && !tfBalancingVoltageDelta.hasErrorMessage && !tfBalancingVoltageDelta.isEmpty {
            request.commandByte = 0x2B
            let value = UInt16(tfBalancingVoltageDelta.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellOVPTrigger.hasChanged() && !tfCellOVPTrigger.hasErrorMessage && !tfCellOVPTrigger.isEmpty {
            request.commandByte = 0x24
            let value = UInt16(tfCellOVPTrigger.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellOVPRelease.hasChanged() && !tfCellOVPRelease.hasErrorMessage && !tfCellOVPRelease.isEmpty {
            request.commandByte = 0x25
            let value = UInt16(tfCellOVPRelease.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellUVPTrigger.hasChanged() && !tfCellUVPTrigger.hasErrorMessage && !tfCellUVPTrigger.isEmpty {
            request.commandByte = 0x26
            let value = UInt16(tfCellUVPTrigger.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfCellUVPRelease.hasChanged() && !tfCellUVPRelease.hasErrorMessage && !tfCellUVPRelease.isEmpty {
            request.commandByte = 0x27
            let value = UInt16(tfCellUVPRelease.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: value)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfPackOVPTrigger.hasChanged() && !tfPackOVPTrigger.hasErrorMessage && !tfPackOVPTrigger.isEmpty {
            request.commandByte = 0x20
            let value = UInt32(tfPackOVPTrigger.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfPackOVPRelease.hasChanged() && !tfPackOVPRelease.hasErrorMessage && !tfPackOVPRelease.isEmpty {
            request.commandByte = 0x21
            let value = UInt32(tfPackOVPRelease.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfPackUVPTrigger.hasChanged() && !tfPackUVPTrigger.hasErrorMessage && !tfPackUVPTrigger.isEmpty {
            request.commandByte = 0x22
            let value = UInt32(tfPackUVPTrigger.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfPackUVPRelease.hasChanged() && !tfPackUVPRelease.hasErrorMessage && !tfPackUVPRelease.isEmpty {
            request.commandByte = 0x23
            let value = UInt32(tfPackUVPRelease.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfChargeOCTrigger.hasChanged() && !tfChargeOCTrigger.hasErrorMessage && !tfChargeOCTrigger.isEmpty {
            request.commandByte = 0x28
            let value = UInt32(tfChargeOCTrigger.text ?? "") ?? 0
            let data = bmsRequest.toUInt8Arr(value: UInt16(value/10))
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfDischargeOCTrigger.hasChanged() && !tfDischargeOCTrigger.hasErrorMessage && !tfDischargeOCTrigger.isEmpty {
            request.commandByte = 0x29
            let textfieldvalue = (UInt32(tfDischargeOCTrigger.text ?? "") ?? 0)/10
            let value = 0xFFFF - UInt16(textfieldvalue)
            let data = bmsRequest.toUInt8Arr(value: value+1)
            print("\(textfieldvalue), \(value), \(data), \(String(format: "%02X", data.0)):\(String(format: "%02X", data.1))")
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfChargeOTTrigger.hasChanged() && !tfChargeOTTrigger.hasErrorMessage && !tfChargeOTTrigger.isEmpty {
            request.commandByte = 0x18
            let value = Int(tfChargeOTTrigger.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfChargeOTRelease.hasChanged() && !tfChargeOTRelease.hasErrorMessage && !tfChargeOTRelease.isEmpty {
            request.commandByte = 0x19
            let value = Int(tfChargeOTRelease.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfChargeUTTrigger.hasChanged() && !tfChargeUTTrigger.hasErrorMessage && !tfChargeUTTrigger.isEmpty {
            request.commandByte = 0x1A
            let value = Int(tfChargeUTTrigger.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfChargeUTRelease.hasChanged() && !tfChargeUTRelease.hasErrorMessage && !tfChargeUTRelease.isEmpty {
            request.commandByte = 0x1B
            let value = Int(tfChargeUTRelease.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfDischargeOTTrigger.hasChanged() && !tfDischargeOTTrigger.hasErrorMessage && !tfDischargeOTTrigger.isEmpty {
            request.commandByte = 0x1C
            let value = Int(tfDischargeOTTrigger.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfDischargeOTRelease.hasChanged() && !tfDischargeOTRelease.hasErrorMessage && !tfDischargeOTRelease.isEmpty {
            request.commandByte = 0x1D
            let value = Int(tfDischargeOTRelease.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfDischargeUTTrigger.hasChanged() && !tfDischargeUTTrigger.hasErrorMessage && !tfDischargeUTTrigger.isEmpty {
            request.commandByte = 0x1E
            let value = Int(tfDischargeUTTrigger.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if tfDischargeUTRelease.hasChanged() && !tfDischargeUTRelease.hasErrorMessage && !tfDischargeUTRelease.isEmpty {
            request.commandByte = 0x1F
            let value = Int(tfDischargeUTRelease.text ?? "") ?? 0
            let temp = IntToKelvin(value)
            let data = bmsRequest.toUInt8Arr(value: temp)
            print(data)
            request.dataBytes = [data.0, data.1]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        
        
        if (tfChargeOCRelease.hasChanged() || tfChargeOCDelay.hasChanged()) && !tfChargeOCRelease.hasErrorMessage && !tfChargeOCRelease.isEmpty && !tfChargeOCDelay.hasErrorMessage && !tfChargeOCDelay.isEmpty {
            request.commandByte = 0x3E
            let value1 = UInt8(tfChargeOCDelay.text ?? "") ?? 0
            let value2 = UInt8(tfChargeOCRelease.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if (tfCellOVPDelay.hasChanged() || tfCellUVPDelay.hasChanged()) && !tfCellOVPDelay.hasErrorMessage && !tfCellOVPDelay.isEmpty && !tfCellUVPDelay.hasErrorMessage && !tfCellUVPDelay.isEmpty {
            request.commandByte = 0x3D
            let value1 = UInt8(tfCellUVPDelay.text ?? "") ?? 0
            let value2 = UInt8(tfCellOVPDelay.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if (tfDischargeOCRelease.hasChanged() || tfDischargeOCDelay.hasChanged()) && !tfDischargeOCRelease.hasErrorMessage && !tfDischargeOCRelease.isEmpty && !tfDischargeOCDelay.hasErrorMessage && !tfDischargeOCDelay.isEmpty {
            request.commandByte = 0x3F
            let value1 = UInt8(tfDischargeOCDelay.text ?? "") ?? 0
            let value2 = UInt8(tfDischargeOCRelease.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if (tfPackUVPDelay.hasChanged() || tfPackOVPDelay.hasChanged()) && !tfPackUVPDelay.hasErrorMessage && !tfPackUVPDelay.isEmpty && !tfPackOVPDelay.hasErrorMessage && !tfPackOVPDelay.isEmpty {
            request.commandByte = 0x3C
            let value1 = UInt8(tfPackUVPDelay.text ?? "") ?? 0
            let value2 = UInt8(tfPackOVPDelay.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if (tfChargeOTDelay.hasChanged() || tfChargeUTDelay.hasChanged()) && !tfChargeOTDelay.hasErrorMessage && !tfChargeOTDelay.isEmpty && !tfChargeUTDelay.hasErrorMessage && !tfChargeUTDelay.isEmpty {
            request.commandByte = 0x3A
            let value1 = UInt8(tfChargeUTDelay.text ?? "") ?? 0
            let value2 = UInt8(tfChargeOTDelay.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if (tfDischargeUTDelay.hasChanged() || tfDischargeOTDelay.hasChanged()) && !tfDischargeUTDelay.hasErrorMessage && !tfDischargeUTDelay.isEmpty && !tfDischargeOTDelay.hasErrorMessage && !tfDischargeOTDelay.isEmpty {
            request.commandByte = 0x3B
            let value1 = UInt8(tfDischargeUTDelay.text ?? "") ?? 0
            let value2 = UInt8(tfDischargeOTDelay.text ?? "") ?? 0
            request.dataBytes = [value1, value2]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        
        
        if cbEnableBalancing.hasChanged() || cbBalancingOnlyWhileCharging.hasChanged() || cbCapacityIndicatorLEDs.hasChanged() || cbEnableOnboardLEDs.hasChanged() || cbWaitForLoadDisconnect.hasChanged() || cbEnableHardwareSwitch.hasChanged() {
            var value: UInt8 = 0
            if cbCapacityIndicatorLEDs.on {
                value += 0b00100000
            }
            if cbEnableOnboardLEDs.on {
                value += 0b00010000
            }
            if cbBalancingOnlyWhileCharging.on {
                value += 0b00001000
            }
            if cbEnableBalancing.on {
                value += 0b00000100
            }
            if cbWaitForLoadDisconnect.on {
                value += 0b00000010
            }
            if cbEnableHardwareSwitch.on {
                value += 0b00000001
            }
            request.commandByte = 0x2D
            request.dataBytes = [0x00, value]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        if cbNTC1.hasChanged() || cbNTC2.hasChanged() || cbNTC3.hasChanged() || cbNTC4.hasChanged() || cbNTC5.hasChanged() || cbNTC6.hasChanged() || cbNTC7.hasChanged() || cbNTC8.hasChanged() {
            var value: UInt8 = 0
            if cbNTC8.on {
                value += 0b10000000
            }
            if cbNTC7.on {
                value += 0b01000000
            }
            if cbNTC6.on {
                value += 0b00100000
            }
            if cbNTC5.on {
                value += 0b00010000
            }
            if cbNTC4.on {
                value += 0b00001000
            }
            if cbNTC3.on {
                value += 0b00000100
            }
            if cbNTC2.on {
                value += 0b00000010
            }
            if cbNTC1.on {
                value += 0b00000001
            }
            print(value)
            request.commandByte = 0x2E
            request.dataBytes = [0x00, value]
            ConfigurationController.remainingWriteAddresses.append(request.getBytes())
        }
        
    }
    
    
    @IBAction func printButton(_ sender: UIButton) {
        cmd_configuration.printConfiguration()
    }
    
    func StringToASCII(text: String) -> [UInt8] {
        if text.count > 0 {
            guard let data = text.data(using: .ascii) else {
                return [0]
            }
            var result = [UInt8(data.count)]
            result.append(contentsOf: [UInt8](data))
            return result
        }
        return [0]
    }
    
    func printHex(data: [UInt8]) {
        var hexString = ""
        if data.count > 0 {
            for i in 0...data.count-1 {
                hexString += String(format: "%02X ", data[i])
            }
        }
        print(hexString)
        var indexString = ""
        for i in 0...data.count-1 {
            indexString += String(format: "%02d ", i)
        }
        print(indexString)
        print("")
    }
    
    
    func map(x: CGFloat, in_min: CGFloat, in_max: CGFloat, out_min: CGFloat, out_max: CGFloat) -> CGFloat {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    }
    
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
