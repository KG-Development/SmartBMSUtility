//
//  loggingController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 06.02.21.
//

import SwiftCSV

class loggingController {
    
    static var lastLogTimestamp = Int64(NSDate().timeIntervalSince1970 * 1000)

    static func generateFileHeader() -> String? {
        if (cmd_basicInformation.numberOfCells ?? 0) <= 0 {
            return nil
        }
        var header = "timestampUTC;totalVoltage;chargingCurrentA;disChargingCurrentA;remainingCapacityAh;socPercent;"
        if (cmd_basicInformation.numberOfTempSensors ?? 0) > 0 {
            for i in 1...cmd_basicInformation.numberOfTempSensors! {
                header = header + String(format: "t%d;", i)
            }
        }
        for i in 1...cmd_basicInformation.numberOfCells! {
            header = header + String(format: "c%d", i)
            if i != cmd_basicInformation.numberOfCells {
                header = header + ";"
            }
        }
        return header + "\n"
    }
    
    static private func getNewDataLine() -> String? {
        if (cmd_basicInformation.numberOfCells ?? 0) <= 0 {
            return nil
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var line = formatter.string(from: date) + ";"
        line += BMSData.convertToString(value: cmd_basicInformation.totalVoltage ?? 0) + ";"
        line += String(format: "%.2f", BMSData.getChargingCurrent()) + ";"
        line += String(format: "%.2f", BMSData.getDischargingCurrent()) + ";"
        line += BMSData.convertToString(value: cmd_basicInformation.residualCapacity ?? 0) + ";"
        line += String(format: "%d", cmd_basicInformation.rsoc ?? 0) + ";"
    
        if (cmd_basicInformation.numberOfTempSensors ?? 0) > 0 {
            for i in 0...cmd_basicInformation.numberOfTempSensors!-1 {
                line += String(format: "%.1f", cmd_basicInformation.temperatureReadings[Int(i)]) + ";"
            }
        }
        for i in 0...cmd_basicInformation.numberOfCells!-1 {
            line += String(format: "%.3f", Double(cmd_voltages.voltageOfCell[Int(i)])/1000.0)
            if i != cmd_basicInformation.numberOfCells!-1 {
                line = line + ";"
            }
        }
        return line + "\n"
    }
    
    static func generateFilename() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.string(from: date)
        return formatter.string(from: date)
    }
    
    static func WriteDataLine() {
        let newline = getNewDataLine()
        if newline != nil {
            fileController.writeLogFile(content: newline!)
            lastLogTimestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        }
    }
    
    static func shouldLogCurrentEntry() -> Bool {
        let settings = DevicesController.getConnectedDevice()?.settings
        if settings?.deviceUUID == "demo" {
            return false
        }
        
        let enabled = settings?.loggingEnabled ?? false
        let interval = getTimestamp() - lastLogTimestamp >= (settings?.loggingInterval ?? 2)*950 //950 because it would not trigger perfectly on 1000
        return enabled && interval
    }
    
    static private func getTimestamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970*1000)
    }
    
    static func getLogData(uuid: String, filename: String) -> CSV? {
        let loggingText = fileController.loadLogFile(uuid: uuid, filename: filename)
        
        do {
            let csv: CSV = try CSV(string: loggingText, delimiter: ";", loadColumns: true)
            return csv
        }
        catch {
            print(error)
        }
        return nil
    }
    
    struct LogEntry {
        var timestampUTC: String
        var totalVoltage: String
        var chargingCurrent: Double
        var dischargingCurrent: Double
        var remainingCapacityAh: Double
        var socPercent: Int
        var temperature: [Double]
        var cellVoltage: [Double]
    }
}
