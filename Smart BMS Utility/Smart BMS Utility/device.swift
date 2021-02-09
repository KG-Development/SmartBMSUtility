//
//  device.swift
//  Smart BMS Utility
//
//  Created by Justin on 04.11.20.
//

import CoreBluetooth

class device {
    
    //GENERAL
    public enum connectionType {
        case bluetooth
        case demo
        case disconnected
    }
    
    var type: connectionType?
    var deviceName: String?
    
    var connected = false
    
    //BLUETOOTH
    var waitingForMultiPart = false
    var macAddress: String?
    var peripheral: CBPeripheral?
    var service: CBService?
    var RXcharacteristic: CBCharacteristic? //FF01, .read, .notify
    var TXcharacteristic: CBCharacteristic? //FF02, .read, .writeWithoutResponse
    
    func getIdentifier() -> String {
        if type == connectionType.bluetooth {
            return peripheral?.identifier.uuidString ?? ""
        }
        return ""
    }
    
    func getName() -> String {
        if type == connectionType.bluetooth {
            return deviceName ?? ""
        }
        else if type == connectionType.demo {
            return "Demo device"
        }
        return ""
    }
    
    
}
