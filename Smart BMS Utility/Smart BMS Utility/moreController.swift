//
//  moreController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 29.11.20.
//

import UIKit
import BEMCheckBox

class moreController: UITableViewController {
    
    @IBOutlet weak var autoConnectCheckbox: BEMCheckBox!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 && indexPath.section == 0 {
            let device = DevicesController.getConnectedDevice()!
            device.peakPower = 0.0
            device.peakCurrent = 0.0
            device.lowestVoltage = 0.0
            device.highestVoltage = 0.0
            GPSController.topSpeed = 0.0
            GPSController.currentSpeed = 0.0
            GPSController.efficiency = 0.0
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        }
        else if indexPath.row == 1 && indexPath.section == 0 {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DevicesController.connectionMode == .demo && indexPath.row <= 1 && indexPath.section == 0 {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoConnectCheckbox.on = DevicesController.getConnectedDevice()?.settings.autoConnect ?? false
        print("moreController: viewDidLoad(): \(autoConnectCheckbox.on)")
    }
    
    @IBAction func autoconnectChanged(_ sender: BEMCheckBox) {
        DevicesController.getConnectedDevice()?.settings.autoConnect = sender.on
        DevicesController.getConnectedDevice()?.saveDeviceSettings()
    }
    
}
