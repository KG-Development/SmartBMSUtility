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
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    
    override func viewDidLoad() {
        selectedDevice = DevicesController.deviceArray[editDeviceController.deviceIndex]
        if selectedDevice.type == device.connectionType.bluetooth {
            detailLabel.isHidden = true
            detailTextField.isHidden = true
            deviceNameTextField.text = selectedDevice.deviceName
        }
        else if selectedDevice.type == device.connectionType.wifi {
            deviceNameTextField.text = selectedDevice.deviceName
            detailTextField.text = selectedDevice.WiFiAddress
        }
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
