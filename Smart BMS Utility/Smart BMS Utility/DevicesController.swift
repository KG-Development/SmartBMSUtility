//
//  Devices.swift
//  Smart BMS Utility
//
//  Created by Justin on 03.11.20.
//

import UIKit

class DevicesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var deviceTable: UITableView!
    
    static var connectionMode: device.connectionType = .disconnected
    
    static var deviceArray = [device]()
    
    static var connectedIndex = -1
    
    static var selectedDeviceID: String?
    
    var refreshCtrl = UIRefreshControl()
    
    var firstStart = true
    
    override func viewDidLoad() {
        print("DevicesController: viewDidLoad()")
        deviceTable.delegate = self
        deviceTable.dataSource = self
        
        deviceTable.refreshControl = refreshCtrl
        refreshCtrl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        OverviewController.BLEInterface = BluetoothInterface()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("reloadDevices"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            SettingController.loadSettings()
            print("DevicesController: viewDidAppear()")
            self.title = "Devices"
            OverviewController.BLEInterface?.initBluetooth()
            DevicesController.connectionMode = .disconnected
            DevicesController.selectedDeviceID = nil
            DevicesController.connectedIndex = -1
            let device = DevicesController.getConnectedDevice()
            if device != nil {
                let peripheral = device?.peripheral
                if peripheral == nil {
                    return
                }
                OverviewController.BLEInterface?.centralManager.cancelPeripheralConnection(peripheral!)
            }
            if SettingController.settings.useDemo {
                demoDevice.setupDemoDevice()
            } else {
                demoDevice.removeDemoDevice()
            }
            
            if !(SettingController.settings.LiontronHidden ?? false) {
                self.showLionTronWarning()
            }
            
            self.reloadData()
            self.resetApp()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, boolValue) in
            boolValue(true)
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let mainNC = storyBoard.instantiateViewController(withIdentifier: "editDevice") as! UINavigationController
//            mainNC.modalPresentationStyle = .formSheet
            editDeviceController.deviceIndex = indexPath.section
            self.present(mainNC, animated: true, completion: nil)
        }
        edit.backgroundColor = .systemBlue
        let swipeActions = UISwipeActionsConfiguration(actions: [edit])

        return swipeActions
    }
    
    @objc func reloadData() {
        deviceTable.reloadData()
        print(DevicesController.deviceArray.count)
        if DevicesController.deviceArray.count > 0 && firstStart {
            for i in 0...DevicesController.deviceArray.count-1 {
                if DevicesController.deviceArray[i].settings.autoConnect ?? false {
                    firstStart = false
                    print("Autoconnect device found! \(DevicesController.deviceArray[i].settings.deviceName ?? "")")
                    tableView(deviceTable, didSelectRowAt: IndexPath(row: 0, section: i))
                    performSegue(withIdentifier: "deviceSegue", sender: nil)
                }
            }
        }
    }
    
    @objc func refreshData() {
        DevicesController.deviceArray.removeAll()
        NotificationCenter.default.post(name: Notification.Name("refreshBluetooth"), object: nil)
        
        firstStart = true
        deviceTable.reloadData()
        refreshCtrl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return DevicesController.deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! deviceCell
        if DevicesController.deviceArray[indexPath.section].type == device.connectionType.bluetooth {
            cell.titleLabel.text = DevicesController.deviceArray[indexPath.section].settings.deviceName ?? ""
            if cell.titleLabel.text == DevicesController.deviceArray[indexPath.section].peripheral?.name {
                cell.subtitleLabel.text = ""
            }
            else {
                cell.subtitleLabel.text = DevicesController.deviceArray[indexPath.section].peripheral?.name ?? ""
            }
            return cell
        }
        else {
            cell.titleLabel.text = DevicesController.deviceArray[indexPath.section].settings.deviceName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DevicesController.deviceArray[indexPath.section].type == device.connectionType.bluetooth && DevicesController.deviceArray[indexPath.section].peripheral != nil {
            OverviewController.BLEInterface?.centralManager.connect(DevicesController.deviceArray[indexPath.section].peripheral!, options: nil)
            DevicesController.connectionMode = .bluetooth
            DevicesController.selectedDeviceID = DevicesController.deviceArray[indexPath.section].peripheral?.identifier.uuidString
        }
        else if DevicesController.deviceArray[indexPath.section].type == device.connectionType.demo {
            DevicesController.connectionMode = .demo
        }
        else {
            print("ELSE")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return DevicesController.deviceArray[indexPath.section].type != .demo
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
    
    static func getConnectedDevice() -> device? {
        if DevicesController.deviceArray.count > 0 {
            for i in 0...DevicesController.deviceArray.count-1 {
                if DevicesController.deviceArray[i].type == device.connectionType.demo && connectionMode == .demo {
                    return DevicesController.deviceArray[i]
                }
                if DevicesController.deviceArray[i].getIdentifier() == selectedDeviceID {
                    return DevicesController.deviceArray[i]
                }
            }
        }
        
        return nil //Should not return, hopefully
    }
    
    
    @IBAction func settingsPressed(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let mainNC = storyBoard.instantiateViewController(withIdentifier: "settingsPage") as! SettingController
        mainNC.modalPresentationStyle = .fullScreen
        self.present(mainNC, animated: true, completion: nil)
    }
    
    func resetApp() {
        print("DevicesController: resetApp()")
        GPSController.topSpeed = 0.0
        GPSController.currentSpeed = 0.0
        GPSController.efficiency = 0.0
        OverviewController.retryCount = 0
        OverviewController.didCheckReadWriteMode = false
        cmd_basicInformation.totalVoltage = nil
        cmd_basicInformation.current = nil
        cmd_basicInformation.residualCapacity = nil
        cmd_basicInformation.nominalCapacity = nil
        cmd_basicInformation.cycleLife = nil
        cmd_basicInformation.productDate = nil
        cmd_basicInformation.balanceCells = [Bool](repeating: true, count: 32)
        cmd_basicInformation.protection = protectionStatus()
        cmd_basicInformation.version = nil
        cmd_basicInformation.rsoc = nil
        cmd_basicInformation.controlStatus = nil
        cmd_basicInformation.numberOfCells = nil
        cmd_basicInformation.numberOfTempSensors = nil
        cmd_basicInformation.temperatureReadings = [Double](repeating: 0, count: 8)
        cmd_basicInformation.chargingPort = true
        cmd_basicInformation.dischargingPort = true
        cmd_voltages.voltageOfCell = [UInt16](repeating: 0, count: 32)
        cmd_configuration.FullCapacity = nil
        cmd_configuration.CycleCapacity = nil
        cmd_configuration.CellFullVoltage = nil
        cmd_configuration.CellEmptyVoltage = nil
        cmd_configuration.RateDsg = nil
        cmd_configuration.ProdDate = nil
        cmd_configuration.CycleCount = nil
        cmd_configuration.ChgOTPtrig = nil
        cmd_configuration.ChgOTPrel = nil
        cmd_configuration.ChgUTPtrig = nil
        cmd_configuration.ChgUTPrel = nil
        cmd_configuration.DsgOTPtrig = nil
        cmd_configuration.DsgOTPrel = nil
        cmd_configuration.DsgUTPtrig = nil
        cmd_configuration.DsgUTPrel = nil
        cmd_configuration.PackOVPtrig = nil
        cmd_configuration.PackOVPrel = nil
        cmd_configuration.PackUVPtrig = nil
        cmd_configuration.PackUVPrel = nil
        cmd_configuration.CellOVPtrig = nil
        cmd_configuration.CellOVPrel = nil
        cmd_configuration.CellUVPtrig = nil
        cmd_configuration.CellUVPrel = nil
        cmd_configuration.ChgOCP = nil
        cmd_configuration.DsgOCP = nil
        cmd_configuration.BalanceStartVoltage = nil
        cmd_configuration.BalanceVoltageDelta = nil
        cmd_configuration.LEDCapacityIndicator = false
        cmd_configuration.LEDEnable = false
        cmd_configuration.BalanceOnlyWhileCharging = false
        cmd_configuration.BalanceEnable = false
        cmd_configuration.LoadDetect = false
        cmd_configuration.HardwareSwitch = false
        cmd_configuration.NTCSensorEnable = [Bool](repeating: false, count: 8)
        cmd_configuration.CellCount = nil
        cmd_configuration.Capacity80 = nil
        cmd_configuration.Capacity60 = nil
        cmd_configuration.Capacity40 = nil
        cmd_configuration.Capacity20 = nil
        cmd_configuration.HardCellOVP = nil
        cmd_configuration.HardCellUVP = nil
        cmd_configuration.ChgUTPdel = nil
        cmd_configuration.ChgOTPdel = nil
        cmd_configuration.DsgUTPdel = nil
        cmd_configuration.DsgOTPdel = nil
        cmd_configuration.PackUVPdel = nil
        cmd_configuration.PackOVPdel = nil
        cmd_configuration.CellOVPdel = nil
        cmd_configuration.CellUVPdel = nil
        cmd_configuration.ChgOCPdel = nil
        cmd_configuration.ChgOCPrel = nil
        cmd_configuration.DsgOCPdel = nil
        cmd_configuration.DsgOCPrel = nil
        cmd_configuration.SerialNumber = nil
        cmd_configuration.Model = nil
        cmd_configuration.Barcode = nil
    }
    
    func showLionTronWarning() {
        let alert = UIAlertController(title: "Warning: LionTron batteries are not fully supported!", message: "This app has some issues communicating with LionTron batteries. Do not use the charging and discharging on/off buttons. The configuration view will also be useless for LionTron users.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: { (action) in
            SettingController.settings.LiontronHidden = true
            fileController.saveAppSettings()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
