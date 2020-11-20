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
        print(index)
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(self.sensorNameTextField.text, forKey: "com.nearix.Smart-BMS-Utility:\(DevicesController.getConnectedDevice().getIdentifier()):\(self.index)")
        }
    }
}
