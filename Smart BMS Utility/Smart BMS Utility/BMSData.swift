import UIKit


class BMSData {
    
    static var lastCurrentArray = [Int16](repeating: 0, count: 8)
    static var lastCurrentIndex = -1
    
    static func validateChecksum(response: [UInt8] ) -> Bool {
        if response.count == 0 || response[0] != 0xDD || response[response.count-1] != 0x77 {
            return false
        }
        var checksum: UInt16 = 0xFFFF
        for i in 2...response.count-4 {
            checksum = checksum - UInt16(response[i])
        }
//        print("Checksum: \(checksum + 1 == convertByteToUInt16(data1: response[response.count-3], data2: response[response.count-2]))")
        return checksum + 1 == convertByteToUInt16(data1: response[response.count-3], data2: response[response.count-2])
    }
    
    
    static func dataToBMSReading(bytes: [UInt8]) {
        let data = bytes
        
        if(data.count == 0 || data[0] != 0xDD || data[2] != 0x00 || data[data.count-1] != 0x77) {
            print("Invalid packet received!")
            for i in 0...data.count-1 {
                print(String(format: "%02X ", data[i]), separator: "", terminator: "")
            }
            print("")
            return
        }
        switch data[1] {
        case 3:
            
            if(data[3] != (data.count - 7) && data.count <= 29) {
                print("Data size not correct (3)! \(data[1])")
                return
            }
            cmd_basicInformation.totalVoltage = convertByteToUInt16(data1: data[4], data2: data[5])
            cmd_basicInformation.current = -convertByteToInt16(data1: data[6], data2: data[7])
            if self.lastCurrentIndex == -1 {
                if self.lastCurrentIndex == -1 && cmd_basicInformation.current != nil {
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
            cmd_basicInformation.numberOfCells = data[25]
            cmd_basicInformation.numberOfTempSensors = data[26]
            if (cmd_basicInformation.numberOfTempSensors ?? 0) > 0 {
//                print(cmd_basicInformation.numberOfTempSensors ?? 0)
                for i in 0...Int(cmd_basicInformation.numberOfTempSensors ?? 0) - 1 {
                    cmd_basicInformation.temperatureReadings[i] = UInt16ToTemp(reading: convertByteToUInt16(data1: data[27+(i*2)], data2: data[28+(i*2)]))
                }
            }
            NotificationCenter.default.post(name: Notification.Name("OverviewDataAvailable"), object: nil)
            break
        case 4:
            
            if(data[3] != data.count - 7) {
                //print("Data size not correct (4)! \(data[3])")
                return
            }
            for i in 0...Int(data[3]/2)-1 {
                cmd_voltages.voltageOfCell[i] = convertByteToUInt16(data1: data[i*2+4], data2: data[i*2+5])
            }
            break
        default:
            print("invalid command code!")
            return
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
        if SettingController.thermalUnit == .celsius {
            return Double(reading-2731) / Double(10.0) //SWIFT WTF
        }
        else {
            return (Double(reading-2731) / 10.0 * 1.8) + 32
        }
    }
    
    static func convertToString(value: UInt16) -> String {
        return String(format: "%.2f", Double(Double(value) / Double(100)))
    }
    static func convertToVoltageString(value: UInt16, decimalplaces: Int) -> String {
        return String(format: "%.\(decimalplaces)f", Double(Double(value) / Double(1000)))
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
        var sum: Int16 = 0
        for i in 0...self.lastCurrentArray.count-1 {
            sum += self.lastCurrentArray[i]
        }
        return Int16(sum / Int16(self.lastCurrentArray.count))
    }
    
    static func generateRequest(command: UInt8) -> [UInt8] {
        let data: [UInt8] = [0xDD, 0xA5, command, 0x00, 0xFF, 0xFF-(command-1), 0x77]
        return data
    }
    
    
    static func printHex(data: Data) -> String {
        var hexString = ""
        if data.count > 0 {
            for i in 0...data.count-1 {
                hexString += String(format: "%02X ", data[i])
            }
        }
        return hexString
    }
    
    
}
