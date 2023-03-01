import UIKit


class BMSData {
    
    static var parsingError = false
    static var ReadWriteMode = false
    
    static var lastCurrentArray = [Int16](repeating: 0, count: 8)
    static var lastCurrentIndex = -1
    
    static var lastProtectionState: [UInt8] = [0x00, 0x00]
    
    static var lastControlStatus: UInt8?
    
    static func validateChecksum(response: [UInt8] ) -> Bool {
        if response.count <= 5 || response[0] != 0xDD || response[response.count-1] != 0x77 {
            return false
        }
        var checksum: UInt32 = 0x10000
        for i in stride(from: 2, through: response.count-4, by: 1) {
            checksum = checksum - UInt32(response[i])
        }
//        print("Checksum: \(checksum + 1 == convertByteToUInt16(data1: response[response.count-3], data2: response[response.count-2]))")
        return checksum == convertByteToUInt16(data1: response[response.count-3], data2: response[response.count-2])
    }
    
    static func isWriteAnswer(response: [UInt8]) -> Bool {
        return response[0] == 0xDD && response[3] == 0 && response[4] == 0 && response[5] == 0 && response[6] == 0x77
    }
    
    
    static func dataToBMSReading(bytes: [UInt8]) {
        let data = bytes
        
        if data[2] == 0x81 || data[2] == 0x80 {
            BMSData.ReadWriteMode = false
        }
        if (data[1] == 0xE1 || data[1] == 0x00) && data[2] == 0x80 {
            let device = DevicesController.getConnectedDevice()
            if device != nil && !(device!.settings.liontronMode ?? false) {
                device!.settings.liontronMode = true
                device!.saveDeviceSettings()
                print("Activated LionTron-Mode")
                NotificationCenter.default.post(name: Notification.Name("LionTronMode"), object: nil)
            }
        }
        
        
        if(data.count == 0 || data[0] != 0xDD || data[2] != 0x00 || data[data.count-1] != 0x77 || data[3] != (data.count - 7)) {
            print("Invalid packet received!")
            for i in 0...data.count-1 {
                print(String(format: "%02X ", data[i]), separator: "", terminator: "")
            }
            print("")
            return
        }
        switch data[1] {
        case 3:
            if(data.count <= 29) {
                print("Data size not correct (3)! \(data[1])")
                return
            }
            cmd_basicInformation.totalVoltage = convertByteToUInt16(data1: data[4], data2: data[5])
            cmd_basicInformation.current = convertByteToInt16(data1: data[6], data2: data[7])
            if self.lastCurrentIndex == -1 {
                if cmd_basicInformation.current != nil {
                    for i in 0...self.lastCurrentArray.count-1 {
                        self.lastCurrentArray[i] = cmd_basicInformation.current ?? 0
                    }
                    self.lastCurrentIndex = 0
                }
            }
            self.lastCurrentArray[self.lastCurrentIndex] = cmd_basicInformation.current ?? 0
            if self.lastCurrentIndex == self.lastCurrentArray.count-1 {
                self.lastCurrentIndex = 0
            }
            else {
                self.lastCurrentIndex += 1
            }
            cmd_basicInformation.residualCapacity = convertByteToUInt16(data1: data[8], data2: data[9])
            cmd_basicInformation.nominalCapacity = convertByteToUInt16(data1: data[10], data2: data[11])
            cmd_basicInformation.cycleLife = convertByteToUInt16(data1: data[12], data2: data[13])
            cmd_basicInformation.productDate = convertByteToUInt16(data1: data[14], data2: data[15])
            var cellIndex = 0
            for i in (0...15).reversed() {
                cmd_basicInformation.balanceCells[cellIndex] = checkBit(byte: data[16 + Int(i/8)], pos: i % 8)
//                print((cmd_basicInformation.balanceCells[cellIndex]) ? "1" : "0", separator: "", terminator: "")
                cellIndex += 1
            }
//            print(" ", separator: "", terminator: "")
            for i in (16...31).reversed() {
                cmd_basicInformation.balanceCells[cellIndex] = checkBit(byte: data[16 + Int(i/8)], pos: i % 8)
//                print((cmd_basicInformation.balanceCells[cellIndex]) ? "1" : "0", separator: "", terminator: "")
                cellIndex += 1
            }
//            print("")
            cmd_basicInformation.protection.CellBlockOverVoltage = checkBit(byte: data[21], pos: 7)
            cmd_basicInformation.protection.CellBlockUnderVoltage = checkBit(byte: data[21], pos: 6)
            cmd_basicInformation.protection.BatteryOverVoltage = checkBit(byte: data[21], pos: 5)
            cmd_basicInformation.protection.BatteryUnderVoltage = checkBit(byte: data[21], pos: 4)
            cmd_basicInformation.protection.ChargingOverTemp = checkBit(byte: data[21], pos: 3)
            cmd_basicInformation.protection.ChargingUnderTemp = checkBit(byte: data[21], pos: 2)
            cmd_basicInformation.protection.DischargingOverTemp = checkBit(byte: data[21], pos: 1)
            cmd_basicInformation.protection.DischargingUnderTemp = checkBit(byte: data[21], pos: 0)
            cmd_basicInformation.protection.ChargingOverCurr = checkBit(byte: data[20], pos: 7)
            cmd_basicInformation.protection.DischargingOverCurr = checkBit(byte: data[20], pos: 6)
            cmd_basicInformation.protection.ShortCircuit = checkBit(byte: data[20], pos: 5)
            cmd_basicInformation.protection.ICError = checkBit(byte: data[20], pos: 4)
            cmd_basicInformation.protection.MOSLockIn = checkBit(byte: data[20], pos: 3)
            cmd_basicInformation.version = data[22]
            cmd_basicInformation.rsoc = data[23]
            cmd_basicInformation.controlStatus = data[24]
            if BMSData.lastControlStatus == nil {
                BMSData.lastControlStatus = cmd_basicInformation.controlStatus
            }
            else if BMSData.lastControlStatus != cmd_basicInformation.controlStatus {
                OverviewController.waitingForMosStatus = false
                BMSData.lastControlStatus = cmd_basicInformation.controlStatus
            }
            
            cmd_basicInformation.chargingPort = checkBit(byte: data[24], pos: 7)
            cmd_basicInformation.dischargingPort = checkBit(byte: data[24], pos: 6)
//            print("Recv Charging:    \(cmd_basicInformation.chargingPort.description)")
//            print("Recv Discharging: \(cmd_basicInformation.dischargingPort.description)")
//            print("Recv code: \(data[24])")
            cmd_basicInformation.numberOfCells = data[25]
            if (DevicesController.getConnectedDevice()?.settings.cellCount ?? 0) != cmd_basicInformation.numberOfCells ?? 0 {
                DevicesController.getConnectedDevice()?.settings.cellCount = Int(cmd_basicInformation.numberOfCells ?? 0)
                DevicesController.getConnectedDevice()?.saveDeviceSettings()
            }
            cmd_basicInformation.numberOfTempSensors = data[26]
//            printHex(data: Data(data))
            if (cmd_basicInformation.numberOfTempSensors ?? 0) > 0 {
//                print(cmd_basicInformation.numberOfTempSensors ?? 0)
                for i in 0...Int(cmd_basicInformation.numberOfTempSensors ?? 0) - 1 {
                    if data[27+(i*2)] != nil || data[28+(i*2)] != nil {
                        cmd_basicInformation.temperatureReadings[i] = UInt16ToTemp(reading: convertByteToUInt16(data1: data[27+(i*2)], data2: data[28+(i*2)]))
                    }
                    else {
                        if !parsingError {
                            NotificationCenter.default.post(name: Notification.Name("parsingFailed"), object: nil)
                        }
                        parsingError = true
                    }
                }
            }
            NotificationCenter.default.post(name: Notification.Name("OverviewDataAvailable"), object: nil)
            if (data[20] ^ lastProtectionState[0]) != 0x00 || (data[21] ^ lastProtectionState[1]) != 0x00 {
//                print("BMSData: AlertAvailable()")
                NotificationCenter.default.post(name: Notification.Name("AlertAvailable"), object: nil)
            }
            lastProtectionState = [data[20], data[21]]
            
            break
        case 4:
            for i in 0...Int(data[3]/2)-1 {
                cmd_voltages.voltageOfCell[i] = convertByteToUInt16(data1: data[i*2+4], data2: data[i*2+5])
            }
            if data[3] < 32 {
                for i in Int(data[3]/2)...31 {
                    cmd_voltages.voltageOfCell[i] = 0
                }
            }
            if loggingController.shouldLogCurrentEntry() {
                loggingController.WriteDataLine()
            }
            break
        case 0x10:
            cmd_configuration.FullCapacity = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x11:
            cmd_configuration.CycleCapacity = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x12:
            cmd_configuration.CellFullVoltage = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x13:
            cmd_configuration.CellEmptyVoltage = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x14:
            cmd_configuration.RateDsg = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x15:
//            cmd_configuration.ProdDate = convertByteToUInt16(data1: data[4], data2: data[5])
            //TODO: Convert to date
            break
        case 0x17:
            cmd_configuration.CycleCount = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x18:
            cmd_configuration.ChgOTPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x19:
            cmd_configuration.ChgOTPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1A:
            cmd_configuration.ChgUTPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1B:
            cmd_configuration.ChgUTPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1C:
            cmd_configuration.DsgOTPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1D:
            cmd_configuration.DsgOTPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1E:
            cmd_configuration.DsgUTPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x1F:
            cmd_configuration.DsgUTPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x20:
            cmd_configuration.PackOVPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x21:
            cmd_configuration.PackOVPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x22:
            cmd_configuration.PackUVPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x23:
            cmd_configuration.PackUVPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x24:
            cmd_configuration.CellOVPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x25:
            cmd_configuration.CellOVPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x26:
            cmd_configuration.CellUVPtrig = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x27:
            cmd_configuration.CellUVPrel = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x28:
            cmd_configuration.ChgOCP = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x29:
            var value: UInt32 = 0x10000 - UInt32(convertByteToUInt16(data1: data[4], data2: data[5]))
            if value == 0x10000 {
                value = 0
            }
            cmd_configuration.DsgOCP = UInt16(value)
        case 0x2A:
            cmd_configuration.BalanceStartVoltage = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x2B:
            cmd_configuration.BalanceVoltageDelta = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x2D:
            cmd_configuration.LEDCapacityIndicator = checkBit(byte: data[5], pos: 2)
            cmd_configuration.LEDEnable = checkBit(byte: data[5], pos: 3)
            cmd_configuration.BalanceOnlyWhileCharging = checkBit(byte: data[5], pos: 4)
            cmd_configuration.BalanceEnable = checkBit(byte: data[5], pos: 5)
            cmd_configuration.LoadDetect = checkBit(byte: data[5], pos: 6)
            cmd_configuration.HardwareSwitch = checkBit(byte: data[5], pos: 7)
        case 0x2E:
            cmd_configuration.NTCSensorEnable[0] = checkBit(byte: data[5], pos: 7)
            cmd_configuration.NTCSensorEnable[1] = checkBit(byte: data[5], pos: 6)
            cmd_configuration.NTCSensorEnable[2] = checkBit(byte: data[5], pos: 5)
            cmd_configuration.NTCSensorEnable[3] = checkBit(byte: data[5], pos: 4)
            cmd_configuration.NTCSensorEnable[4] = checkBit(byte: data[5], pos: 3)
            cmd_configuration.NTCSensorEnable[5] = checkBit(byte: data[5], pos: 2)
            cmd_configuration.NTCSensorEnable[6] = checkBit(byte: data[5], pos: 1)
            cmd_configuration.NTCSensorEnable[7] = checkBit(byte: data[5], pos: 0)
        case 0x2F:
            cmd_configuration.CellCount = data[5]
        case 0x32:
            cmd_configuration.Capacity80 = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x33:
            cmd_configuration.Capacity60 = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x34:
            cmd_configuration.Capacity40 = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x35:
            cmd_configuration.Capacity20 = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x36:
            cmd_configuration.HardCellOVP = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x37:
            cmd_configuration.HardCellUVP = convertByteToUInt16(data1: data[4], data2: data[5])
        case 0x3A:
            cmd_configuration.ChgUTPdel = data[4]
            cmd_configuration.ChgOTPdel = data[5]
        case 0x3B:
            cmd_configuration.DsgUTPdel = data[4]
            cmd_configuration.DsgOTPdel = data[5]
        case 0x3C:
            cmd_configuration.PackUVPdel = data[4]
            cmd_configuration.PackOVPdel = data[5]
        case 0x3D:
            cmd_configuration.CellOVPdel = data[5]
            cmd_configuration.CellUVPdel = data[4]
        case 0x3E:
            cmd_configuration.ChgOCPdel = data[4]
            cmd_configuration.ChgOCPrel = data[5]
        case 0x3F:
            cmd_configuration.DsgOCPdel = data[4]
            cmd_configuration.DsgOCPrel = data[5]
        case 0xA0:
            cmd_configuration.SerialNumber = ASCIItoString(bytes: data)
        case 0xA1:
            cmd_configuration.Model = ASCIItoString(bytes: data)
        case 0xA2:
            cmd_configuration.Barcode = ASCIItoString(bytes: data)
        default:
            print("invalid command code!")
            return
        }
        if ConfigurationController.requestSendStarted && (data[1] < 3 || data[1] > 5) {
//            print("Received value for address \(data[1])")
            ConfigurationController.sendNextReadRequest(address: data[1])
            let userInfo = [ "commandCode" : data[1] ]
            NotificationCenter.default.post(name: Notification.Name("ConfigurationDataAvailable"), object: nil, userInfo: userInfo)
        }
        
        return
        
    }
    
    static func convertByteToUInt16(data1: UInt8, data2: UInt8) -> UInt16 {
        return UInt16(data1) << 8 + UInt16(data2)
    }
    static func convertByteToInt16(data1: UInt8, data2: UInt8) -> Int16 {
        return Int16(data1) << 8 + Int16(data2)
    }
    
    static func checkBit(byte: UInt8, pos: Int) -> Bool {
        switch pos {
        case 0:
            return (byte & 0b10000000) == 0b10000000;
        case 1:
            return (byte & 0b01000000) == 0b01000000;
        case 2:
            return (byte & 0b00100000) == 0b00100000;
        case 3:
            return (byte & 0b00010000) == 0b00010000;
        case 4:
            return (byte & 0b00001000) == 0b00001000;
        case 5:
            return (byte & 0b00000100) == 0b00000100;
        case 6:
            return (byte & 0b00000010) == 0b00000010;
        case 7:
            return (byte & 0b00000001) == 0b00000001;
        default:
            print("invalid pos")
            return false
        }
    }
    
    static func UInt16ToTemp(reading: UInt16) -> Double {
        let temp: Int32 = Int32(reading)
        if SettingController.settings.thermalUnit == .celsius {
            return Double(temp-2731) / Double(10.0) //SWIFT WTF
        }
        else {
            return (Double(temp-2731) / 10.0 * 1.8) + 32
        }
    }
    
    static func convertToString(value: UInt16) -> String {
        return String(format: "%.2f", Double(Double(value) / Double(100)))
    }
    static func convertToVoltageString(value: UInt16, decimalplaces: Int) -> String {
        return String(format: "%.\(decimalplaces)f", Double(Double(value) / Double(1000)))
    }
    
    static func ASCIItoString(bytes: [UInt8]) -> String {
        var opStr = ""
        if bytes[4] >= 1 {
            for i in 5...bytes.count-4 {
                if bytes[i] > 0 {
                    opStr +=  String(Character(UnicodeScalar(bytes[i])))
                }
            }
        }
        return opStr
    }
    
    static func getLowestCell() -> (Int, UInt16) {
        var lowestIndex = 0
        var lowestReading: UInt16 = cmd_voltages.voltageOfCell[0]
        for i in 0...cmd_voltages.voltageOfCell.count-1 {
            if cmd_voltages.voltageOfCell[i] == 0 {
                return (lowestIndex, lowestReading)
            }
            if cmd_voltages.voltageOfCell[i] < lowestReading {
                lowestReading = cmd_voltages.voltageOfCell[i]
                lowestIndex = i
            }
        }
        return (lowestIndex, lowestReading)
    }
    static func getHighestCell() -> (Int, UInt16) {
        var highestIndex = 0
        var highestReading: UInt16 = 0
        for i in 0...cmd_voltages.voltageOfCell.count-1 {
            if cmd_voltages.voltageOfCell[i] == 0 {
                return (highestIndex, highestReading)
            }
            if cmd_voltages.voltageOfCell[i] > highestReading {
                highestReading = cmd_voltages.voltageOfCell[i]
                highestIndex = i
            }
        }
        return (highestIndex, highestReading)
    }
    static func getAvgCell() -> Int {
        var average = 0
        var count = 0
        for i in 0...cmd_voltages.voltageOfCell.count-1 {
            if cmd_voltages.voltageOfCell[i] == 0 {
                break
            }
            count += 1
            average += Int(cmd_voltages.voltageOfCell[i])
        }
        if count == 0 {
            return 0
        }
        return average / count
    }
    
    static func returnAverage() -> Int16 {
        var sum: Int32 = 0
        for i in 0...self.lastCurrentArray.count-1 {
            sum += Int32(self.lastCurrentArray[i])
        }
        return Int16(sum / Int32(self.lastCurrentArray.count))
    }
    
    static func generateRequest(command: UInt8) -> [UInt8] {
        let data: [UInt8] = [0xDD, 0xA5, command, 0x00, 0xFF, 0xFF-(command-1), 0x77]
        return data
    }
    
    static func getDischargingCurrent() -> Double {
        if cmd_basicInformation.current == nil {
            return 0
        }
        let value = min(0, cmd_basicInformation.current!)
        return Double(-value) / 100.0
    }
    
    static func getChargingCurrent() -> Double {
        if cmd_basicInformation.current == nil {
            return 0
        }
        let value = max(0, cmd_basicInformation.current!)
        return Double(value) / 100.0
    }
    
    static func printHex(data: Data) {
        var hexString = ""
        if data.count > 0 {
            for i in 0...data.count-1 {
                hexString += String(format: "%02X ", data[i])
            }
        }
        print(hexString)
        var indexString = ""
        for i in 0...data.count-1 {
            indexString += String(format: "%02d ", i)
        }
        print(indexString)
    }
    
    static func protectionArray() -> [Bool] {
        let pr = cmd_basicInformation.protection
        return [pr.CellBlockOverVoltage ?? false, pr.CellBlockUnderVoltage ?? false, pr.BatteryOverVoltage ?? false, pr.BatteryUnderVoltage ?? false, pr.ChargingOverTemp ?? false, pr.ChargingUnderTemp ?? false, pr.DischargingOverTemp ?? false, pr.DischargingUnderTemp ?? false, pr.ChargingOverCurr ?? false, pr.DischargingOverCurr ?? false, pr.ShortCircuit ?? false, pr.ICError ?? false, pr.MOSLockIn ?? false]
    }
    
    static func protectionDescription(index: Int) -> String {
        switch index {
        case 0:
            return "Cell overvoltage!"
        case 1:
            return "Cell undervoltage!"
        case 2:
            return "Battery overvoltage!"
        case 3:
            return "Battery undervoltage!"
        case 4:
            return "Temperature above charging temperature limit!"
        case 5:
            return "Temperature below charging temperature limit!"
        case 6:
            return "Temperature above discharging temperature limit!"
        case 7:
            return "Temperature below discharging temperature limit!"
        case 8:
            return "Charging overcurrent!"
        case 9:
            return "Discharging overcurrent"
        case 10:
            return "Short circuit detected!"
        case 11:
            return "BMS error detected!"
        case 12:
            return "MOS locked!"
        default:
            return "Unknown"
        }
    }
    
}
