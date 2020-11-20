//
//  device.swift
//  Smart BMS Utility
//
//  Created by Justin on 04.11.20.
//

import CoreBluetooth

class device: NSObject, NSCoding {
    
    
    func encode(with coder: NSCoder) {
        coder.encode(self.type, forKey: "type")
        coder.encode(self.deviceName, forKey: "deviceName")
        coder.encode(self.WiFiAddress, forKey: "WiFiAddress")
    }
    
    required init?(coder: NSCoder) {
        self.type = coder.decodeObject(forKey: "type") as? connectionType
        self.deviceName = coder.decodeObject(forKey: "deviceName") as? String
        self.WiFiAddress = coder.decodeObject(forKey: "WiFiAddress") as? String ?? ""
    }
    
    override init() {
        super.init()
    }
    
    //GENERAL
    public enum connectionType {
        case bluetooth
        case wifi
        case demo
    }
    
    var type: connectionType?
    var deviceName: String?
    
    var connected = false
    var selected = false
    
    //WIFI
    var WiFiAddress = "" //IP Address
    
    //BLUETOOTH
    var waitingForMultiPart = false
    var macAddress: String?
    var peripheral: CBPeripheral?
    var service: CBService?
    var RXcharacteristic: CBCharacteristic? //FF01, .read, .notify
    var TXcharacteristic: CBCharacteristic? //FF02, .read, .writeWithoutResponse
    
    func getIdentifier() -> String {
        if type == connectionType.wifi {
            return WiFiAddress
        }
        else if type == connectionType.bluetooth {
            return peripheral?.identifier.uuidString ?? ""
        }
        return ""
    }
    
    
}
