//
//  demoDevice.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 07.11.20.
//


import UIKit

class demoDevice {
    
    static var capacity = UInt16.random(in: 1000...2000)
    static var rsoc = UInt8(map(x: Int(capacity), in_min: 0, in_max: 8000, out_min: 0, out_max: 100))
    static var capacityOffset: Float = 0.0
    
    static func setupDemoDevice() {
        print("demoDevice: AddObserver()")
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(generateData), name: Notification.Name("DemoDeviceNeeded"), object: nil)
        let tmpDevice = device()
        tmpDevice.connected = false
        tmpDevice.type = .demo
        tmpDevice.deviceName = "Demo device"
        tmpDevice.macAddress = "01:23:45:67:89:AB"
        DevicesController.deviceArray.insert(tmpDevice, at: 0)
        NotificationCenter.default.post(name: NSNotification.Name("reloadDevices"), object: nil)
    }
    
    @objc static func generateData() {
        if DevicesController.connectionMode == .demo {
            print("demoDevice: generateData()")
            
            let voltage = UInt16ToUInt8(data: 0x08E0 - UInt16.random(in: 0...80))
            let cell1 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let cell2 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let cell3 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let cell4 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let cell5 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let cell6 = UInt16ToUInt8(data: 0x0ED6 - UInt16.random(in: 0...125))
            let current = Int16.random(in: -400...0) - 400
            let currentData = Int16ToUInt8(data: current)
            
            capacityOffset = capacityOffset + (Float(current) / 3600.0)
            rsoc = UInt8(map(x: Int(capacity - UInt16(-capacityOffset)), in_min: 0, in_max: 8000, out_min: 0, out_max: 100))
//            print(capacity - UInt16(-capacityOffset))
            let capacityData = UInt16ToUInt8(data: capacity - UInt16(-capacityOffset))
            
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                //DD 03 00 1B 08 E0 02 8B 04 41 07 C9 00 02 29 4C 00 00 00 00 00 00 25 37 03 06 02 0B D5 0B CF FA C3 77
                let infoData: [UInt8] = [0xDD, 0x03, 0x00, 0x1B, voltage.0, voltage.1, currentData.0, currentData.1, capacityData.0, capacityData.1, 0x17, 0x70, 0x00, 0x02, 0x29, 0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, rsoc, 0x03, 0x06, 0x02, 0x0B, 0xD5, 0x0B, 0xCF, 0xFA, 0xC3, 0x77]
                
                
                BMSData.dataToBMSReading(bytes: infoData)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                //DD 04 00 0C 0E D6 0E C4 0E C2 0E C1 0E C2 0E E2 FA DF 77
                let infoData: [UInt8] = [0xDD, 0x04, 0x00, 0x0C, cell1.0, cell1.1, cell2.0, cell2.1, cell3.0, cell3.1, cell4.0, cell4.1, cell5.0, cell5.1, cell6.0, cell6.1, 0xFA, 0xDF, 0x77]
                BMSData.dataToBMSReading(bytes: infoData)
            }
        }
    }
    
    static func UInt16ToUInt8(data: UInt16) -> (UInt8, UInt8) {
        return (UInt8(data >> 8), UInt8(data & 0x00FF))
    }
    static func Int16ToUInt8(data: Int16) -> (UInt8, UInt8) {
        let result = byteArray(from: data)
        
        return (result[0], result[1])
    }
    
    private static func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    static func map(x: Int, in_min: Int, in_max: Int, out_min: Int, out_max: Int) -> Int {
        return (Int(x) - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    }
    
    static func setChecksum(data: [UInt8]) -> [UInt8] {
        var datacopy = data
        var checksum: UInt16 = 0xFFFF
        
        for i in 2...datacopy.count-1 {
            checksum = checksum - UInt16(datacopy[i])
        }
        
        print("demoDevice: \(checksum)")
        
        let checksumBytes = UInt16ToUInt8(data: checksum+1)
        datacopy[datacopy.count-3] = checksumBytes.0
        datacopy[datacopy.count-2] = checksumBytes.1
        
        return data
    }
}
