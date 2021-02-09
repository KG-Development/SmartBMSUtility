//
//  BluetoothInterface.swift
//  Smart BMS Utility
//
//  Created by Justin on 14.10.20.
//

import CoreBluetooth

class BluetoothInterface: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    
    var tempData = Data()
    
    let serviceUUID = CBUUID(string: "FF00")
    let rxUUID = CBUUID(string: "FF01")
    let txUUID = CBUUID(string: "FF02")
    
    var pauseTransmission = false
    
    func initBluetooth() {
        print("BluetoothInterface: initBluetooth()")
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(sendRequest), name: NSNotification.Name("BluetoothSendNeeded"), object: nil)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            //TODO: Notifiy user to enable bluetooth
            break
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [serviceUUID])
//            centralManager.scanForPeripherals(withServices: nil)
            break
        @unknown default:
            break
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let bluetoothDevice = device()
        
//        print(peripheral.identifier)
        
        if DevicesController.indexFromID(id: peripheral.identifier) == -1 {
            bluetoothDevice.peripheral = peripheral
            bluetoothDevice.peripheral?.delegate = self
            
            let deviceName = UserDefaults.standard.string(forKey: peripheral.identifier.description + ":deviceName")
            if deviceName == nil {
                bluetoothDevice.deviceName = peripheral.name
            }
            else {
                bluetoothDevice.deviceName = deviceName
            }
//            if peripheral.identifier == UUID(uuidString: "D6AA3825-EF12-2A69-85E1-7E6FF6D527F4") {
//                bluetoothDevice.deviceName = "17S"
//            }
            bluetoothDevice.type = .bluetooth
            DevicesController.deviceArray.append(bluetoothDevice)
            NotificationCenter.default.post(name: NSNotification.Name("reloadDevices"), object: nil)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let index = DevicesController.indexFromID(id: peripheral.identifier)
        if index == -1 {
            print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
            return
        }
        print("BluetoothInterface: \(peripheral.name!) connected... ")
        centralManager.stopScan()
        DevicesController.deviceArray[index].connected = true
        DevicesController.deviceArray[index].peripheral?.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let index = DevicesController.indexFromID(id: peripheral.identifier)
        if index == -1 {
            print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
            return
        }
        DevicesController.deviceArray[index].connected = false
        print("BluetoothInterface: Failed to connect to \(peripheral.name!)")
        NotificationCenter.default.post(name: Notification.Name("didFailToConnect"), object: nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (peripheral.services?.count ?? 0) > 0 {
            for i in 0...(peripheral.services?.count ?? 0)-1 {
                if peripheral.services?[i].uuid == CBUUID(string: "FF00") {
                    print("BluetoothInterface: Found FF00")
                    let index = DevicesController.indexFromID(id: peripheral.identifier)
                    if index == -1 {
                        print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
                        return
                    }
                    DevicesController.deviceArray[index].service = peripheral.services?[i]
                    peripheral.discoverCharacteristics(nil, for: (DevicesController.deviceArray[index].service)!)
                    return
                }
//                print(peripheral.services?[i] ?? "")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (service.characteristics?.count ?? 0) > 0 {
            for i in 0...(service.characteristics?.count ?? 0)-1 {
                if service.characteristics?[i].uuid == CBUUID(string: "FF01") {
                    let index = DevicesController.indexFromID(id: peripheral.identifier)
                    if index == -1 {
                        print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
                        return
                    }
                    DevicesController.deviceArray[index].connected = true
                    DevicesController.deviceArray[index].RXcharacteristic = service.characteristics?[i]
                    
                    
                    peripheral.setNotifyValue(true, for: (DevicesController.deviceArray[index].RXcharacteristic)!)
                }
                else if service.characteristics?[i].uuid == CBUUID(string: "FF02") {
                    let index = DevicesController.indexFromID(id: peripheral.identifier)
                    if index == -1 {
                        print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
                        return
                    }
                    DevicesController.deviceArray[index].connected = true
                    DevicesController.deviceArray[index].TXcharacteristic = service.characteristics?[i]
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("BluetoothInterface: \(characteristic.uuid) updated notifying to \(characteristic.isNotifying)")
        if characteristic.isNotifying {
            //peripheral.writeValue(Data(data), for: bmsTXCharacteristic!, type: .withoutResponse)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        
        let index = DevicesController.indexFromID(id: peripheral.identifier)
        if index == -1 {
            print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
            return
        }
        
        if data?.first == 0xDD && data?.last != 0x77 && data?.count == 20 {
            tempData = data!
            DevicesController.deviceArray[index].waitingForMultiPart = true
        }
        else if DevicesController.deviceArray[index].waitingForMultiPart && data?.first != 0xDD && data?.last == 0x77 {
            tempData.append(data!)
            DevicesController.deviceArray[index].waitingForMultiPart = false
        }
        else if DevicesController.deviceArray[index].waitingForMultiPart && data?.first != 0xDD /*&& data?.last == 0x77*/ {
            tempData.append(data!)
            DevicesController.deviceArray[index].waitingForMultiPart = true
        }
        else if data?.first == 0xDD && data?.last == 0x77 {
            tempData = data!
            DevicesController.deviceArray[index].waitingForMultiPart = false
        }
        
        if tempData.count == 7 && BMSData.isWriteAnswer(response: [UInt8](tempData)) {
            if tempData[1] == 0x00 {
//                print("Enabled ReadWriteMode")
                BMSData.ReadWriteMode = true
                tempData.removeAll()
                return
            }
            else if tempData[1] == 0x01 {
//                print("Disabled ReadWriteMode")
                BMSData.ReadWriteMode = false
                tempData.removeAll()
                return
            }
//            print(printHex(data: tempData))
            if tempData[2] == 0x80 || tempData[2] == 0x81 {
                BMSData.ReadWriteMode = false
                ConfigurationController.sendNextWriteCommand(address: 0)
            }
            else {
                ConfigurationController.sendNextWriteCommand(address: tempData[1])
            }
            tempData.removeAll()
            return
        }
        
        
        let valid = BMSData.validateChecksum(response: [UInt8](tempData))
        
        if !(DevicesController.deviceArray[index].waitingForMultiPart) && valid && data!.count <= 20 && tempData.first == 0xDD && tempData.last == 0x77 {
            BMSData.dataToBMSReading(bytes: [UInt8](tempData))
//            print("Received: \(printHex(data: tempData))")
            tempData.removeAll()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let index = DevicesController.indexFromID(id: peripheral.identifier)
        if index == -1 {
            print("BluetoothInterface: Did not find correct index for \(peripheral.identifier)")
            return
        }
        
        DevicesController.deviceArray[index].connected = false
        if DevicesController.deviceArray[index].peripheral != nil {
            centralManager.connect(DevicesController.deviceArray[index].peripheral!, options: nil)
        }
        NotificationCenter.default.post(name: Notification.Name("disconnectUpdate"), object: nil)
    }
    
    
    func printHex(data: Data) -> String {
        var hexString = ""
        if data.count > 0 {
            for i in 0...data.count-1 {
                hexString += String(format: "%02X ", data[i])
            }
        }
        return hexString
    }
    
    func printCharacteristicProperties(characteristic: CBCharacteristic) {
        
        print(characteristic.uuid.uuidString)
        if characteristic.properties.rawValue & CBCharacteristicProperties.broadcast.rawValue != 0x0 {
            print("broadcast")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue != 0x0 {
            print("read")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue != 0x0 {
            print("write without response")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue != 0x0 {
            print("write")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue != 0x0 {
            print("notify")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.indicate.rawValue != 0x0 {
            print("indicate")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.authenticatedSignedWrites.rawValue != 0x0 {
            print("authenticated signed writes ")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.extendedProperties.rawValue != 0x0 {
            print("indicate")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.notifyEncryptionRequired.rawValue != 0x0 {
            print("notify encryption required")
        }
        if characteristic.properties.rawValue & CBCharacteristicProperties.indicateEncryptionRequired.rawValue != 0x0 {
            print("indicate encryption required")
        }
    }
    
    
    @objc func sendRequest() {
        let device = DevicesController.getConnectedDevice()
        if device.connected && device.peripheral?.state == .connected && device.TXcharacteristic != nil && device.RXcharacteristic != nil {
//            print("BluetoothInterface: sendRequest() \(Date())")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let data = BMSData.generateRequest(command: 0x03)
                device.peripheral!.writeValue(Data(data), for: device.TXcharacteristic!, type: .withoutResponse)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let data = BMSData.generateRequest(command: 0x04)
                device.peripheral!.writeValue(Data(data), for: device.TXcharacteristic!, type: .withoutResponse)
            }
        }
    }
    
    func sendReadRequest(address: UInt8) {
        let device = DevicesController.getConnectedDevice()
        if device.connected && device.peripheral?.state == .connected && device.TXcharacteristic != nil && device.RXcharacteristic != nil {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if BMSData.ReadWriteMode {
                    let data = BMSData.generateRequest(command: address)
                    device.peripheral!.writeValue(Data(data), for: device.TXcharacteristic!, type: .withoutResponse)
                }
                else {
                    print("BluetoothInterface: Could not write because we are not in ReadWriteMode. Trying to open ReadWriteMode...")
                    self.sendOpenReadWriteModeRequest()
                }
            }
        }
    }
    
    func sendCloseReadWriteModeRequest() {
        print("BluetoothInterface: sendCloseReadWriteModeRequest()")
        self.sendCustomRequest(data: [0xDD, 0x5A, 0x01, 0x02, 0x00, 0x00, 0xFF, 0xFD, 0x77])
    }
    func sendOpenReadWriteModeRequest() {
        print("BluetoothInterface: sendOpenReadWriteModeRequest()")
        self.sendCustomRequest(data: [0xDD, 0x5A, 0x00, 0x02, 0x56, 0x78, 0xFF, 0x30, 0x77])
    }
    
    func sendCustomRequest(data: [UInt8]) {
        let device = DevicesController.getConnectedDevice()
        if device.connected && device.peripheral!.state == .connected && device.TXcharacteristic != nil && device.RXcharacteristic != nil {
            device.peripheral!.writeValue(Data(data), for: device.TXcharacteristic!, type: .withoutResponse)
        }
    }
    
}
