//
//  Devices.swift
//  Smart BMS Utility
//
//  Created by Justin on 03.11.20.
//

import UIKit

class DevicesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var deviceTable: UITableView!
    
    static var connectionMode: device.connectionType = .bluetooth
    
    static var deviceArray = [device]()
    
    static var connectedIndex = -1
    
    
    
    override func viewDidLoad() {
        print("DevicesController: viewDidLoad()")
        deviceTable.delegate = self
        deviceTable.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("reloadDevices"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("DevicesController: viewDidAppear()")
            self.title = "Devices"
            
            if DevicesController.deviceArray.count > 0 {
                for (i, obj) in DevicesController.deviceArray.enumerated().reversed() {
                    if obj.type != .wifi {
                        DevicesController.deviceArray.remove(at: i)
                    }
                }
            }
            
            self.reloadData()
            DevicesController.connectedIndex = -1
            SettingController.loadSettings()
            
            if SettingController.useWiFi {
                WiFiInterface.setupUDPServer()
            }
            if SettingController.useBluetooth {
                OverviewController.BLEInterface = BluetoothInterface()
                OverviewController.BLEInterface?.initBluetooth()
            }
            if SettingController.useDemo {
                demoDevice.setupDemoDevice()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, boolValue) in
            boolValue(true)
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let mainNC = storyBoard.instantiateViewController(withIdentifier: "editDevice") as! UINavigationController
//            mainNC.modalPresentationStyle = .formSheet
            editDeviceController.deviceIndex = indexPath.row
            self.present(mainNC, animated: true, completion: nil)
        }
        edit.backgroundColor = .systemBlue
        let swipeActions = UISwipeActionsConfiguration(actions: [edit])

        return swipeActions
    }
    
    @objc func reloadData() {
        deviceTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DevicesController.deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! deviceCell
        if DevicesController.deviceArray[indexPath.row].type == device.connectionType.bluetooth {
            cell.titleLabel.text = DevicesController.deviceArray[indexPath.row].deviceName ?? "Unknown name"
            if cell.titleLabel.text == DevicesController.deviceArray[indexPath.row].peripheral?.name {
                cell.subtitleLabel.text = ""
            }
            else {
                cell.subtitleLabel.text = DevicesController.deviceArray[indexPath.row].peripheral?.name ?? ""
            }
            return cell
        }
        else {
            cell.titleLabel.text = DevicesController.deviceArray[indexPath.row].deviceName
            cell.subtitleLabel.text = DevicesController.deviceArray[indexPath.row].WiFiAddress
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DevicesController.deviceArray[indexPath.row].type == device.connectionType.bluetooth &&  DevicesController.deviceArray[indexPath.row].peripheral != nil {
            OverviewController.BLEInterface?.centralManager.connect(DevicesController.deviceArray[indexPath.row].peripheral!, options: nil)
            DevicesController.connectionMode = .bluetooth
        }
        else if DevicesController.deviceArray[indexPath.row].type == device.connectionType.demo {
            DevicesController.connectionMode = .demo
        }
        else if DevicesController.deviceArray[indexPath.row].type == device.connectionType.wifi {
            DevicesController.connectionMode = .wifi
            print("Selected wifi device with ipaddr: \(DevicesController.deviceArray[indexPath.row].WiFiAddress)")
            WiFiInterface.connectedIPAddr = DevicesController.deviceArray[indexPath.row].WiFiAddress
            WiFiInterface.updateClient()
        }
        DevicesController.deviceArray[indexPath.row].selected = true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if DevicesController.deviceArray[indexPath.row].type == .demo {
            return false
        }
        return true
    }
    
    
    static func indexFromID(id: UUID) -> Int {
        if DevicesController.deviceArray.count == 0 {
            return -1
        }
        else {
            for i in 0...DevicesController.deviceArray.count-1 {
                if DevicesController.deviceArray[i].peripheral?.identifier == id {
                    return i
                }
            }
        }
        return -1
    }
    
    static func getConnectedDevice() -> device {
        if DevicesController.deviceArray.count > 0 {
            for i in 0...DevicesController.deviceArray.count-1 {
                if connectionMode == DevicesController.deviceArray[i].type && (DevicesController.deviceArray[i].connected || DevicesController.deviceArray[i].selected) {
                    return (DevicesController.deviceArray[i])
                }
            }
        }
        
        return device() //Should not return, hopefully
    }
    
    
    @IBAction func addDevice(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainNC = storyBoard.instantiateViewController(withIdentifier: "newDevice") as! UINavigationController
//        mainNC.modalPresentationStyle = .automatic
//        mainNC.modalTransitionStyle = .coverVertical
//        self.present(mainNC, animated: true, completion: nil)
        self.present(mainNC, animated: true, completion: nil)
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainNC = storyBoard.instantiateViewController(withIdentifier: "settingsPage") as! SettingController
        mainNC.modalPresentationStyle = .fullScreen
        self.present(mainNC, animated: true, completion: nil)
    }
}
