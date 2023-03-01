//
//  editDeviceController.swift
//  Smart BMS Utility
//
//  Created by Justin on 05.11.20.
//

import UIKit

class editDeviceController2: UIViewController {
    
    static var deviceIndex = -1
    var selectedDevice: device!

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    override func viewDidLoad() {
        if DevicesController.getConnectedDevice() != nil {
            selectedDevice = DevicesController.getConnectedDevice()
        }
        else if DevicesController.connectionMode == .demo {
            return
        }
        else {
            selectedDevice = DevicesController.deviceArray[editDeviceController.deviceIndex]
        }
        
        deviceNameTextField.text = selectedDevice.settings.deviceName
        self.navigationItem.hidesBackButton = true
        super.viewDidLoad()
    }
    @IBAction func saveButton(_ sender: Any) {
        self.dismiss(animated: true) { [self] in
            NotificationCenter.default.post(name: Notification.Name("reloadDevices"), object: nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if DevicesController.getConnectedDevice() != nil {
            DevicesController.getConnectedDevice()?.settings.deviceName = deviceNameTextField.text
            DevicesController.getConnectedDevice()?.saveDeviceSettings()
        }
        else {
            DevicesController.deviceArray[editDeviceController.deviceIndex].settings.deviceName = deviceNameTextField.text
            DevicesController.deviceArray[editDeviceController.deviceIndex].saveDeviceSettings()
        }
    }
}
