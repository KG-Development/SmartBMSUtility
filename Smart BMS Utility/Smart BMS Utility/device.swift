//
//  device.swift
//  Smart BMS Utility
//
//  Created by Justin on 04.11.20.
//

import CoreBluetooth

class device {
    
    public struct deviceSettings: Decodable, Encodable {
        var deviceUUID: String = "demo"
        var deviceName: String?
        var dongleName: String?
        var cellCount: Int?
        var sensorNames = [String?](repeating: nil, count: 8)
        var cellEmptyVoltage: UInt16 = 3000
        var cellFullVoltage: UInt16 = 4200
        var loggingEnabled: Bool? = false
        var gpsLoggingEnabled: Bool? = false
        var loggingInterval: Int? = 2 //seconds
        var liontronMode: Bool? = false
        var autoConnect: Bool? = false
        
        func getSensorName(index: Int) -> String? {
            if index < 8 {
                return sensorNames[index]
            }
            return nil
        }
    }
    
    //GENERAL
    
    var type: connectionType?
    public enum connectionType: Int {
        case bluetooth = 0
        case demo = 1
        case disconnected
    }
    
    var settings = deviceSettings()
    
    var connected = false
    var selected = false
    
    var peakPower = 0.0
    var peakCurrent = 0.0
    var lowestVoltage = 0.0
    var highestVoltage = 0.0
    
    
    
    //BLUETOOTH
    var waitingForMultiPart = false
    var peripheral: CBPeripheral?
    var service: CBService?
    var RXcharacteristic: CBCharacteristic? //FF01, .read, .notify
    var TXcharacteristic: CBCharacteristic? //FF02, .read, .writeWithoutResponse
    
    func getIdentifier() -> String {
        if type == connectionType.bluetooth {
            return peripheral?.identifier.uuidString ?? settings.deviceUUID
        }
        if type == connectionType.demo {
            return "demo"
        }
        return ""
    }
    
    func loadDeviceSettings() {
        let uuid = peripheral?.identifier.uuidString ?? ""
        if uuid == "" {
            print("unknown identifier")
            return
        }
        let newsettings = fileController.getDeviceSettings(deviceUUID: uuid)
        if newsettings == nil {
            return
        }
        self.settings = newsettings!
    }
    
    func saveDeviceSettings() {
        settings.deviceUUID = peripheral?.identifier.uuidString ?? "demo"
        fileController.saveDeviceSettings(deviceSettings: settings)
    }
    
    
    
    func getName() -> String {
        if type == connectionType.bluetooth {
            return settings.deviceName ?? ""
        }
        else if type == connectionType.demo {
            return "Demo device"
        }
        return ""
    }
    
    
}
