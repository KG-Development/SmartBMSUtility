//
//  loggingCheckboxCell.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 19.02.21.
//

import Foundation
import UIKit
import BEMCheckBox

class loggingCheckboxCell: UITableViewCell {
    
    @IBOutlet weak var loggingEnabledCheckbox: BEMCheckBox!
    
    @IBAction func valueChangd(_ sender: BEMCheckBox) {
        DevicesController.getConnectedDevice()?.settings.loggingEnabled = loggingEnabledCheckbox.on
        DevicesController.getConnectedDevice()?.saveDeviceSettings()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loggingEnabledCheckbox.on = DevicesController.getConnectedDevice()?.settings.loggingEnabled ?? false
    }
}
