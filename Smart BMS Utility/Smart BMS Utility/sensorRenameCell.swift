//
//  sensorRenameCell.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 12.11.20.
//

import UIKit

class sensorRenameCell: UITableViewCell {
    
    var index = 0
    
    @IBOutlet var sensorNameLabel: UILabel!
    @IBOutlet var sensorNameTextField: UITextField!
    
    @IBAction func editingDidEnd(_ sender: UITextField) {
        DispatchQueue.main.async {
            if self.sensorNameTextField.text == nil || self.sensorNameTextField.text == "" {
                DevicesController.getConnectedDevice()?.settings.sensorNames[self.index] = nil
            }
            else {
                DevicesController.getConnectedDevice()?.settings.sensorNames[self.index] = self.sensorNameTextField.text
            }
        }
    }
}
