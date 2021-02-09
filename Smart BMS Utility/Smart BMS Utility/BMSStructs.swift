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
    
    public func getBytes() -> [UInt8] {
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
        result.append(bmsRequest.toUInt8Arr(value: self.getChecksum()).0)
        result.append(bmsRequest.toUInt8Arr(value: self.getChecksum()).1)
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
    
    public static func toUInt8Arr(value: UInt16) -> (UInt8, UInt8) {
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
    static var temperatureReadings = [Double](repeating: 0, count: 8)
    static var chargingPort: Bool = true
    static var dischargingPort: Bool = true
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

class cmd_configuration {
    
    public enum connectionType:UInt8 {
        case FullCapacity = 0x10
        case CycleCapacity = 0x11
        case CellFullVoltage = 0x12
        case CellEmptyVoltage = 0x13
        case RateDsg = 0x14
        case ProdDate = 0x15
        case CycleCount = 0x17
        case ChgOTPtrig = 0x18
        case ChgOTPrel = 0x19
        case ChgUTPtrig = 0x1A
        case ChgUTPrel = 0x1B
        case DsgOTPtrig = 0x1C
        case DsgOTPrel = 0x1D
        case DsgUTPtrig = 0x1E
        case DsgUTPrel = 0x1F
        case PackOVPtrig = 0x20
        case PackOVPrel = 0x21
        case PackUVPtrig = 0x22
        case PackUVPrel = 0x23
        case CellOVPtrig = 0x24
        case CellOVPrel = 0x25
        case CellUVPtrig = 0x26
        case CellUVPrel = 0x27
        case ChgOCP = 0x28
        case DsgOCP = 0x29
        case BalanceStartVoltage = 0x2A
        case BalanceVoltageDelta = 0x2B
        case BalanceSwitches = 0x2D
        case NTCSensorEnable = 0x2E
        case CellCount = 0x2F
        case Capacity80 = 0x32
        case Capacity60 = 0x33
        case Capacity40 = 0x34
        case Capacity20 = 0x35
        case HardCellOVP = 0x36
        case HardCellUVP = 0x37
        case ChargeTempDelay = 0x3A
        case DischargeTempDelay = 0x3B
        case PackVoltageProtectionDelay = 0x3C
        case CellVoltageProtectionDelay = 0x3D
        case ChargeOvercurrent = 0x3E
        case DischargeOvercurrent = 0x3F
        case SerialNumber = 0xA0
        case Model = 0xA1
        case Barcode = 0xA2
    }
    
    
    static let Addresses: [UInt8] = [0x10, 0x11, 0x12, 0x13, 0x14, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2D, 0x2E, 0x2F, 0x32, 0x33, 0x34, 0x35, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0xA1, 0xA2] //TODO: Update this when adding new elements
    
    
    static var FullCapacity: UInt16?
    static var CycleCapacity: UInt16?
    static var CellFullVoltage: UInt16?
    static var CellEmptyVoltage: UInt16?
    static var RateDsg: UInt16?
    static var ProdDate: String?
    static var CycleCount: UInt16?
    static var ChgOTPtrig: UInt16?
    static var ChgOTPrel: UInt16?
    static var ChgUTPtrig: UInt16?
    static var ChgUTPrel: UInt16?
    static var DsgOTPtrig: UInt16?
    static var DsgOTPrel: UInt16?
    static var DsgUTPtrig: UInt16?
    static var DsgUTPrel: UInt16?
    static var PackOVPtrig: UInt16?
    static var PackOVPrel: UInt16?
    static var PackUVPtrig: UInt16?
    static var PackUVPrel: UInt16?
    static var CellOVPtrig: UInt16?
    static var CellOVPrel: UInt16?
    static var CellUVPtrig: UInt16?
    static var CellUVPrel: UInt16?
    static var ChgOCP: UInt16?
    static var DsgOCP: UInt16?
    static var BalanceStartVoltage: UInt16?
    static var BalanceVoltageDelta: UInt16?
    static var LEDCapacityIndicator = false
    static var LEDEnable = false
    static var BalanceOnlyWhileCharging = false
    static var BalanceEnable = false
    static var LoadDetect = false
    static var HardwareSwitch = false
    static var NTCSensorEnable = [Bool](repeating: false, count: 8)
    static var CellCount: UInt8?
    static var Capacity80: UInt16?
    static var Capacity60: UInt16?
    static var Capacity40: UInt16?
    static var Capacity20: UInt16?
    static var HardCellOVP: UInt16?
    static var HardCellUVP: UInt16?
    static var ChgUTPdel: UInt8?
    static var ChgOTPdel: UInt8?
    static var DsgUTPdel: UInt8?
    static var DsgOTPdel: UInt8?
    static var PackUVPdel: UInt8?
    static var PackOVPdel: UInt8?
    static var CellOVPdel: UInt8?
    static var CellUVPdel: UInt8?
    static var ChgOCPdel: UInt8?
    static var ChgOCPrel: UInt8?
    static var DsgOCPdel: UInt8?
    static var DsgOCPrel: UInt8?
    static var SerialNumber: String?
    static var Model: String?
    static var Barcode: String?
    
    static func printConfiguration() {
        print("FullCapacity: \(cmd_configuration.FullCapacity ?? 0)")
        print("CycleCapacity: \(cmd_configuration.CycleCapacity ?? 0)")
        print("CellFullVoltage: \(cmd_configuration.CellFullVoltage ?? 0)")
        print("CellEmptyVoltage: \(cmd_configuration.CellEmptyVoltage ?? 0)")
        print("RateDsg: \(cmd_configuration.RateDsg ?? 0)")
        print("ProdDate: \(cmd_configuration.ProdDate ?? "")")
        print("CycleCount: \(cmd_configuration.CycleCount ?? 0)")
        print("ChgOTPtrig: \(cmd_configuration.ChgOTPtrig ?? 0)")
        print("ChgOTPrel: \(cmd_configuration.ChgOTPrel ?? 0)")
        print("ChgUTPtrig: \(cmd_configuration.ChgUTPtrig ?? 0)")
        print("ChgUTPrel: \(cmd_configuration.ChgUTPrel ?? 0)")
        print("DsgOTPtrig: \(cmd_configuration.DsgOTPtrig ?? 0)")
        print("DsgOTPrel: \(cmd_configuration.DsgOTPrel ?? 0)")
        print("DsgUTPtrig: \(cmd_configuration.DsgUTPtrig ?? 0)")
        print("DsgUTPrel: \(cmd_configuration.DsgUTPrel ?? 0)")
        print("PackOVPtrig: \(cmd_configuration.PackOVPtrig ?? 0)")
        print("PackOVPrel: \(cmd_configuration.PackOVPrel ?? 0)")
        print("PackUVPtrig: \(cmd_configuration.PackUVPtrig ?? 0)")
        print("PackUVPrel: \(cmd_configuration.PackUVPrel ?? 0)")
        print("CellOVPtrig: \(cmd_configuration.CellOVPtrig ?? 0)")
        print("CellOVPrel: \(cmd_configuration.CellOVPrel ?? 0)")
        print("CellUVPtrig: \(cmd_configuration.CellUVPtrig ?? 0)")
        print("CellUVPrel: \(cmd_configuration.CellUVPrel ?? 0)")
        print("ChgOCP: \(cmd_configuration.ChgOCP ?? 0)")
        print("DsgOCP: \(cmd_configuration.DsgOCP ?? 0)")
        print("BalanceStartVoltage: \(cmd_configuration.BalanceStartVoltage ?? 0)")
        print("BalanceVoltageDelta: \(cmd_configuration.BalanceVoltageDelta ?? 0)")
        print("LEDCapacityIndicator: \(cmd_configuration.LEDCapacityIndicator)")
        print("LEDEnable: \(cmd_configuration.LEDEnable)")
        print("BalanceOnlyWhileCharging: \(cmd_configuration.BalanceOnlyWhileCharging)")
        print("BalanceEnable: \(cmd_configuration.BalanceEnable)")
        print("LoadDetect: \(cmd_configuration.LoadDetect)")
        print("HardwareSwitch: \(cmd_configuration.HardwareSwitch)")
        print("NTCSensorEnable: \(cmd_configuration.NTCSensorEnable)")
        print("CellCount: \(cmd_configuration.CellCount ?? 0)")
        print("Capacity80: \(cmd_configuration.Capacity80 ?? 0)")
        print("Capacity60: \(cmd_configuration.Capacity60 ?? 0)")
        print("Capacity40: \(cmd_configuration.Capacity40 ?? 0)")
        print("Capacity20: \(cmd_configuration.Capacity20 ?? 0)")
        print("HardCellOVP: \(cmd_configuration.HardCellOVP ?? 0)")
        print("HardCellUVP: \(cmd_configuration.HardCellUVP ?? 0)")
        print("ChgUTPdel: \(cmd_configuration.ChgUTPdel ?? 0)")
        print("ChgOTPdel: \(cmd_configuration.ChgOTPdel ?? 0)")
        print("DsgUTPdel: \(cmd_configuration.DsgUTPdel ?? 0)")
        print("DsgOTPdel: \(cmd_configuration.DsgOTPdel ?? 0)")
        print("PackUVPdel: \(cmd_configuration.PackUVPdel ?? 0)")
        print("PackOVPdel: \(cmd_configuration.PackOVPdel ?? 0)")
        print("CellOVPdel: \(cmd_configuration.CellOVPdel ?? 0)")
        print("CellUVPdel: \(cmd_configuration.CellUVPdel ?? 0)")
        print("ChgOCPdel: \(cmd_configuration.ChgOCPdel ?? 0)")
        print("ChgOCPrel: \(cmd_configuration.ChgOCPrel ?? 0)")
        print("DsgOCPdel: \(cmd_configuration.DsgOCPdel ?? 0)")
        print("DsgOCPrel: \(cmd_configuration.DsgOCPrel ?? 0)")
        print("SerialNumber: \(cmd_configuration.SerialNumber ?? "")")
        print("Model: \(cmd_configuration.Model ?? "")")
        print("Barcode: \(cmd_configuration.Barcode ?? "")")
        print("NTC1: \(cmd_configuration.NTCSensorEnable[0])")
        print("NTC2: \(cmd_configuration.NTCSensorEnable[1])")
        print("NTC3: \(cmd_configuration.NTCSensorEnable[2])")
        print("NTC4: \(cmd_configuration.NTCSensorEnable[3])")
        print("NTC5: \(cmd_configuration.NTCSensorEnable[4])")
        print("NTC6: \(cmd_configuration.NTCSensorEnable[5])")
        print("NTC7: \(cmd_configuration.NTCSensorEnable[6])")
        print("NTC8: \(cmd_configuration.NTCSensorEnable[7])")
    }
    
}
