//
//  sensorRenameController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 12.11.20.
//

import UIKit

class sensorRenameController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sensorRenameCell", for: indexPath) as! sensorRenameCell
        cell.index = indexPath.row
        cell.sensorNameLabel.text = "Sensor \(indexPath.row+1):"
        cell.sensorNameTextField.text = returnTextFieldName(index: indexPath.row)
        
        
        return cell
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DevicesController.getConnectedDevice()?.saveDeviceSettings()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(cmd_basicInformation.numberOfTempSensors ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func returnTextFieldName(index: Int) -> String {
        return DevicesController.getConnectedDevice()?.settings.getSensorName(index: index) ?? "Temperature \(index+1)"
    }
    
}
