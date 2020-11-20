//
//  BMSStructs.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 12.10.20.
//

import Foundation

class bmsRequest {
    
    var startByte: UInt8 = 0xDD
    var statusByte: UInt8 = 0xA5 //Read
    var commandByte: UInt8 = 0x03 //Basic information
    var lengthByte: UInt8 = 0x00
    var dataBytes: [UInt8] = []
    var checksumByte: UInt16 = 0xFFFF
    var stopByte: UInt8 = 0x77
    
    private func getBytes() -> [UInt8] {
        var result: [UInt8] = []
        
        //TODO: Append instead of set
        result.append(self.startByte)
        result.append(self.statusByte)
        result.append(self.commandByte)
        result.append(UInt8(self.dataBytes.count))
        result[3] = UInt8(self.dataBytes.count)
        if self.dataBytes.count > 1 {
            for i in 0...self.dataBytes.count-1 {
                result.append(self.dataBytes[i])
            }
        }
        result.append(toUInt8Arr(value: self.getChecksum()).0)
        result.append(toUInt8Arr(value: self.getChecksum()).1)
        result.append(self.stopByte)
        return result
    }
    
    func generateBasicInfoRequest() -> [UInt8] {
        self.statusByte = 0xA5
        self.commandByte = 0x03
        self.dataBytes = []
        self.lengthByte = UInt8(self.dataBytes.count)
        self.checksumByte = self.getChecksum()
        return getBytes()
    }
    
    func generateVoltageRequest() -> [UInt8] {
        self.statusByte = 0xA5
        self.commandByte = 0x04
        self.dataBytes = []
        self.lengthByte = UInt8(self.dataBytes.count)
        self.checksumByte = self.getChecksum()
        return getBytes()
    }
    
    private func getChecksum() -> UInt16 {
        var checksum: UInt16 = 0
        checksum += UInt16(self.commandByte)
        checksum += UInt16(self.lengthByte)
        for (_, data) in self.dataBytes.enumerated() {
            checksum += UInt16(data)
        }
        return UInt16(65536 - Int(checksum))
    }
    
    private func toUInt8Arr(value: UInt16) -> (UInt8, UInt8) {
        let one = UInt8((value & 0xFF00) >> 8)
        let two = UInt8(value & 0x00FF)
        return (one, two)
    }
    
}

class bmsResponse {
    
    var startByte: UInt8 = 0xDD
    var commandByte: UInt8 = 0x03 //Basic information
    var statusByte: UInt8 = 0x00 //Read
    var lengthByte: UInt8 = 0x00
    var dataBytes: [UInt8] = [0x00]
    var checksumByte: UInt16 = 0xFFFF
    var stopByte: UInt8 = 0x77
    
}


class cmd_basicInformation {
    static var totalVoltage: UInt16?
    static var current: Int16?
    static var residualCapacity: UInt16?
    static var nominalCapacity: UInt16?
    static var cycleLife: UInt16?
    static var productDate: UInt16?
    static var balanceCells = [Bool](repeating: true, count: 32)
    static var protection: protectionStatus = protectionStatus()
    static var version: UInt8?
    static var rsoc: UInt8?
    static var controlStatus: UInt8?
    static var numberOfCells: UInt8?
    static var numberOfTempSensors: UInt8?
    static var temperatureReadings = [Double](repeating: 0, count: 3)
}

class protectionStatus {
    var CellBlockOverVoltage: Bool?
    var CellBlockUnderVoltage: Bool?
    var BatteryOverVoltage: Bool?
    var BatteryUnderVoltage: Bool?
    var ChargingOverTemp: Bool?
    var ChargingUnderTemp: Bool?
    var DischargingOverTemp: Bool?
    var DischargingUnderTemp: Bool?
    var ChargingOverCurr: Bool?
    var DischargingOverCurr: Bool?
    var ShortCircuit: Bool?
    var ICError: Bool?
    var MOSLockIn: Bool?
    //... reserved
}

class cmd_voltages {
    static var voltageOfCell = [UInt16](repeating: 0, count: 32)
}

class cmd_bmsVersion {
    static var version: UInt32?
}
