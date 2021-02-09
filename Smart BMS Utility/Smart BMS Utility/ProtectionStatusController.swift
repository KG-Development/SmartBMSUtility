//
//  ProtectionStatusController.swift
//  Smart BMS Utility
//
//  Created by Justin on 15.10.20.
//

import UIKit

class ProtectionStatusController: UITableViewController {
    
    @IBOutlet weak var cellOverVoltageImage: UIImageView!
    @IBOutlet weak var cellUnderVoltageImage: UIImageView!
    @IBOutlet weak var BatteryOverVoltageImage: UIImageView!
    @IBOutlet weak var BatteryUnderVoltageImage: UIImageView!
    @IBOutlet weak var ChargingOverTempImage: UIImageView!
    @IBOutlet weak var ChargingUnderTempImage: UIImageView!
    @IBOutlet weak var DischargingOverTempImage: UIImageView!
    @IBOutlet weak var DischargingUnderTempImage: UIImageView!
    @IBOutlet weak var ChargingOverCurrentImage: UIImageView!
    @IBOutlet weak var DischargingOverCurrentImage: UIImageView!
    @IBOutlet weak var ShortcircuitImage: UIImageView!
    @IBOutlet weak var ICErrorImage: UIImageView!
    @IBOutlet weak var MOSLockInImage: UIImageView!
    
    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        super.viewDidLoad()
            print("Protection: viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateValues), name: Notification.Name("OverviewDataAvailable"), object: nil)
        print("Protection: didAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Protection: didDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateValues() {
        print("ProtectionController: updateValues()")
        if cmd_basicInformation.protection.CellBlockOverVoltage ?? false {
            self.cellOverVoltageImage.image = UIImage(systemName: "xmark.shield.fill")
            self.cellOverVoltageImage.tintColor = .red
        }
        else {
            self.cellOverVoltageImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.cellOverVoltageImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.CellBlockUnderVoltage ?? false {
            self.cellUnderVoltageImage.image = UIImage(systemName: "xmark.shield.fill")
            self.cellUnderVoltageImage.tintColor = .red
        }
        else {
            self.cellUnderVoltageImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.cellUnderVoltageImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.BatteryOverVoltage ?? false {
            self.BatteryOverVoltageImage.image = UIImage(systemName: "xmark.shield.fill")
            self.BatteryOverVoltageImage.tintColor = .red
        }
        else {
            self.BatteryOverVoltageImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.BatteryOverVoltageImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.BatteryUnderVoltage ?? false {
            self.BatteryUnderVoltageImage.image = UIImage(systemName: "xmark.shield.fill")
            self.BatteryUnderVoltageImage.tintColor = .red
        }
        else {
            self.BatteryUnderVoltageImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.BatteryUnderVoltageImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.ChargingOverTemp ?? false {
            self.ChargingOverTempImage.image = UIImage(systemName: "xmark.shield.fill")
            self.ChargingOverTempImage.tintColor = .red
        }
        else {
            self.ChargingOverTempImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.ChargingOverTempImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.ChargingUnderTemp ?? false {
            self.ChargingUnderTempImage.image = UIImage(systemName: "xmark.shield.fill")
            self.ChargingUnderTempImage.tintColor = .red
        }
        else {
            self.ChargingUnderTempImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.ChargingUnderTempImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.DischargingOverTemp ?? false {
            self.DischargingOverTempImage.image = UIImage(systemName: "xmark.shield.fill")
            self.DischargingOverTempImage.tintColor = .red
        }
        else {
            self.DischargingOverTempImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.DischargingOverTempImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.DischargingUnderTemp ?? false {
            self.DischargingUnderTempImage.image = UIImage(systemName: "xmark.shield.fill")
            self.DischargingUnderTempImage.tintColor = .red
        }
        else {
            self.DischargingUnderTempImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.DischargingUnderTempImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.ChargingOverCurr ?? false {
            self.ChargingOverCurrentImage.image = UIImage(systemName: "xmark.shield.fill")
            self.ChargingOverCurrentImage.tintColor = .red
        }
        else {
            self.ChargingOverCurrentImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.ChargingOverCurrentImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.DischargingOverCurr ?? false {
            self.DischargingOverCurrentImage.image = UIImage(systemName: "xmark.shield.fill")
            self.DischargingOverCurrentImage.tintColor = .red
        }
        else {
            self.DischargingOverCurrentImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.DischargingOverCurrentImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.ShortCircuit ?? false {
            self.ShortcircuitImage.image = UIImage(systemName: "xmark.shield.fill")
            self.ShortcircuitImage.tintColor = .red
        }
        else {
            self.ShortcircuitImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.ShortcircuitImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.ICError ?? false {
            self.ICErrorImage.image = UIImage(systemName: "xmark.shield.fill")
            self.ICErrorImage.tintColor = .red
        }
        else {
            self.ICErrorImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.ICErrorImage.tintColor = .systemGreen
        }
        if cmd_basicInformation.protection.MOSLockIn ?? false {
            self.MOSLockInImage.image = UIImage(systemName: "xmark.shield.fill")
            self.MOSLockInImage.tintColor = .red
        }
        else {
            self.MOSLockInImage.image = UIImage(systemName: "checkmark.shield.fill")
            self.MOSLockInImage.tintColor = .systemGreen
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
    
    
}
