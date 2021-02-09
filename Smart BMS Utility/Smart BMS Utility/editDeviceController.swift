//
//  editDeviceController.swift
//  Smart BMS Utility
//
//  Created by Justin on 05.11.20.
//

import UIKit

class editDeviceController: UIViewController {
    
    static var deviceIndex = -1
    var selectedDevice: device!

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    override func viewDidLoad() {
        selectedDevice = DevicesController.deviceArray[editDeviceController.deviceIndex]
        deviceNameTextField.text = selectedDevice.deviceName
        super.viewDidLoad()
    }
    @IBAction func saveButton(_ sender: Any) {
        DevicesController.deviceArray[editDeviceController.deviceIndex].deviceName = deviceNameTextField.text
        self.dismiss(animated: true) { [self] in
            NotificationCenter.default.post(name: Notification.Name("reloadDevices"), object: nil)
            UserDefaults.standard.setValue(deviceNameTextField.text, forKey: (DevicesController.deviceArray[editDeviceController.deviceIndex].getIdentifier()) + ":deviceName")
        }
    }
}
