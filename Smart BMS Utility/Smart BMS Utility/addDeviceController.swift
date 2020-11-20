//
//  addDeviceController.swift
//  Smart BMS Utility
//
//  Created by Justin on 05.11.20.
//

import UIKit

class addDeviceController: UIViewController {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNameTextField: UITextField!
    
    @IBOutlet weak var IPAddressLabel: UILabel!
    @IBOutlet weak var IPAddressTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func loadObject(Device: device) {
//        tmpDevice = Device
//        if tmpDevice.type == device.connectionType.bluetooth {
//            IPAddressLabel.text = "Detail info:"
//            deviceNameTextField.text = tmpDevice.deviceName
//        }
//        else {
//            deviceNameTextField.text = tmpDevice.deviceName
//            IPAddressTextField.text = tmpDevice.WiFiAddress
//        }
//    }
    @IBAction func saveDevice(_ sender: Any) {
        if DevicesController.deviceArray.count > 0 {
            for obj in DevicesController.deviceArray {
                if obj.type == device.connectionType.wifi {
                    if obj.WiFiAddress == IPAddressTextField.text {
                        //TODO: Alert: already exists
                        return
                    }
                }
            }
        }
        let tmpDevice = device()
        tmpDevice.type = .wifi
        tmpDevice.WiFiAddress = IPAddressTextField.text ?? ""
        tmpDevice.connected = false
        tmpDevice.deviceName = deviceNameTextField.text
        DevicesController.deviceArray.append(tmpDevice)
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("reloadDevices"), object: nil)
    }
}
