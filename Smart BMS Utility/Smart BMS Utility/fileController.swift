//
//  fileController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 10.02.2021.
//

import FileProvider

class fileController {
    
    enum directoryType {
        case logs
        case config
    }
    
    //Example: /var/mobile/Containers/Data/Application/687DBB06-C45F-47BA-B119-AC9873586403/Documents/logs
    static private func getDirectory(dirType: directoryType) -> String {
        let docdir = docDirectory()
        switch dirType {
        case .logs:
            return docdir+"/logs"
        case .config:
            return docdir+"/cfg"
        }
    }
    
    static private func docDirectory() -> String {
        
        guard let docDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return ""
        }
        return docDirectory
    }
    
    static func createDirectories() {
        let fm = FileManager.default
        do {
            try fm.createDirectory(atPath: getDirectory(dirType: .logs), withIntermediateDirectories: true, attributes: nil)
            try fm.createDirectory(atPath: getDirectory(dirType: .config), withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    static func createDeviceDirectory(identifier: String) {
        let fm = FileManager.default
        do {
            let path = getDirectory(dirType: .logs)+"/\(identifier)"
            try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    
    static func checkAndCreateDirectory(at path: String) {
//        print(path)
        let fm = FileManager.default
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error)
            }
        }
        else {
            //print("Folder already exists")
        }
    }
    
    static func writeLogFile(content: String) {
//        print("fileController: writeLogFile")
        let filename = loggingController.generateFilename()
        let uuid = DevicesController.getConnectedDevice()?.getIdentifier() ?? "demo"
        let path = getDirectory(dirType: .logs)+"/\(uuid)/\(filename).csv"
        let fm = FileManager.default
        do {
            if !fm.fileExists(atPath: path) {
                print("fileController: file does not exist. Creating one")
                let header = loggingController.generateFileHeader()
                if header == nil {
                    print("header == nil")
                    return
                }
                let newcontent = header!+content
                try newcontent.write(toFile: path, atomically: true, encoding: .utf8)
            } else { //Appending
                let oldcontent = loadLogFile(uuid: uuid, filename: filename)
                let newcontent = oldcontent+content
                try newcontent.write(toFile: path, atomically: true, encoding: .utf8)
            }
        } catch {
            print("fileController: unable to write to file: \(error)")
        }
    }
    
    static func loadLogFile(uuid: String, filename: String) -> String {
        let fm = FileManager.default
        let path = getDirectory(dirType: .logs)+"/\(uuid)/\(filename).csv"
//        print(path)
        let data = fm.contents(atPath: path)
        if data == nil {
            print("loadFile: unable to read file (data == nil)")
            return ""
        }
        return String(data: data!, encoding: .utf8) ?? ""
    }
    
    
    static func loadConfigFile(filename: String) -> Data? {
        let fm = FileManager.default
        let path = getDirectory(dirType: .config)+"/\(filename).json"
        return fm.contents(atPath: path)
    }
    
    static func saveDeviceSettings(deviceSettings: device.deviceSettings) {
        print("saveDeviceSettings() for uuid \(deviceSettings.deviceUUID)")
        do {
            let fm = FileManager.default
            let path = getDirectory(dirType: .config)+"/\(deviceSettings.deviceUUID).json"
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let data = try jsonEncoder.encode(deviceSettings)
//            print(String(data: data, encoding: .utf8)!)
            
            fm.createFile(atPath: path, contents: data, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    static func getDeviceSettings(deviceUUID: String) -> device.deviceSettings? {
//        print("getDeviceSettings() for uuid \(deviceUUID)")
        let data = loadConfigFile(filename: deviceUUID)
        if data == nil {
            print("could not load devicesettings for uuid \(deviceUUID)")
            return nil
        }
//        print(String(data: data!, encoding: .utf8)!)
        do {
            let deviceSettings = try JSONDecoder().decode(device.deviceSettings.self, from: data!)
            return deviceSettings
        } catch {
            print(error)
            return nil
        }
    }
    
    
    
    static func saveAppSettings() {
        print("saveAppSettings()")
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let data = try jsonEncoder.encode(SettingController.settings)
            print(String(data: data, encoding: .utf8)!)
            let fm = FileManager.default
            let path = getDirectory(dirType: .config)+"/appSettings.json"
//            print(path)
            fm.createFile(atPath: path, contents: data, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    
    static func logCountForFile(uuid: String, filename: String) -> Int {
        let count = loadLogFile(uuid: uuid, filename: filename).components(separatedBy: "\n")
        return max(0, count.count-1)
    }
    
    
    static func countLogDirectories() -> [(String, Int)] {
        let fm = FileManager.default
        let logDir = getDirectory(dirType: .logs)
        var resultArr = [(String, Int)]()
        do {
            let paths = try fm.contentsOfDirectory(atPath: logDir)
            if paths.count > 0 {
                for i in 0...paths.count-1 {
                    let subDirPath = logDir + "/\(paths[i])"
                    let files = try fm.contentsOfDirectory(atPath: subDirPath)
                    if files.count > 0 {
                        resultArr.append((paths[i], files.count))
                    }
                }
            }
            return resultArr
        } catch {
            print(error)
        }
        
        return []
    }
    
    
    static func getLogFiles(uuid: String) -> [String] {
        let fm = FileManager.default
        do {
            var unedited = try fm.contentsOfDirectory(atPath: getDirectory(dirType: .logs)+"/\(uuid)").sorted()
            if unedited.count > 0 {
                for i in 0...unedited.count-1 {
                    unedited[i] = unedited[i].replacingOccurrences(of: ".csv", with: "")
                }
                unedited.sort()
            }
            return unedited
        } catch {
            print(error)
        }
        return [String]()
    }
    
    
    static func listConfigFiles() {
        let fm = FileManager.default
        let configDir = getDirectory(dirType: .config)
        do {
            let paths = try fm.contentsOfDirectory(atPath: configDir)
            if paths.count > 0 {
                print("=====docs=====")
                for i in 0...paths.count-1 {
                    print(paths[i])
                    var isDir : ObjCBool = false
                    if fm.fileExists(atPath: configDir+"/"+paths[i], isDirectory: &isDir) {
                        if isDir.boolValue {
                            let subPaths = try fm.contentsOfDirectory(atPath: configDir+"/"+paths[i])
                            if subPaths.count > 0 {
                                for i in 0...subPaths.count-1 {
                                    print("\t\(subPaths[i])")
                                }
                            }
                        }
                    }
                }
                print("==============")
            }
            else {
                print("Documents directory is empty.")
            }
        } catch {
            print(error)
        }
    }
    
    static func listLogFiles() {
        let fm = FileManager.default
        let logdir = getDirectory(dirType: .logs)
        do {
            let paths = try fm.contentsOfDirectory(atPath: logdir)
            if paths.count > 0 {
                print("=====logs=====")
                for i in 0...paths.count-1 {
                    print(paths[i])
                    var isDir : ObjCBool = false
                    if fm.fileExists(atPath: logdir+"/"+paths[i], isDirectory: &isDir) {
                        if isDir.boolValue {
                            let subPaths = try fm.contentsOfDirectory(atPath: logdir+"/"+paths[i])
                            if subPaths.count > 0 {
                                for i in 0...subPaths.count-1 {
                                    print("\t\(subPaths[i])")
                                }
                            }
                        }
                    }
                }
                print("==============")
            }
            else {
                print("Log directory is empty.")
            }
        } catch {
            print(error)
        }
    }
    
    static func clearDirectory() {
        let fm = FileManager.default
        let docdir = docDirectory()
        do {
            let items = try fm.contentsOfDirectory(atPath: docdir)
            if items.count > 0 {
                for i in 0...items.count-1 {
                    try fm.removeItem(atPath: docdir+"/"+items[i])
                }
            }
        } catch {
            print(error)
        }
    }
    
    static func clearLogDirectory() {
        let fm = FileManager.default
        let docdir = getDirectory(dirType: .logs)
        do {
            let items = try fm.contentsOfDirectory(atPath: docdir)
            if items.count > 0 {
                for i in 0...items.count-1 {
                    try fm.removeItem(atPath: docdir+"/"+items[i])
                }
            }
        } catch {
            print(error)
        }
    }
    
    static func clearLogDirectoryForDevice(UUID: String) {
        let fm = FileManager.default
        let docdir = getDirectory(dirType: .logs)+"/\(UUID)"
        do {
            let items = try fm.contentsOfDirectory(atPath: docdir)
            if items.count > 0 {
                for i in 0...items.count-1 {
                    print("Removing \(docdir)/\(items[i])")
                    try fm.removeItem(atPath: docdir+"/"+items[i])
                }
            }
        } catch {
            print(error)
        }
    }
    
    static func removeLogfile(UUID: String, filename: String) {
        let fm = FileManager.default
        let logdir = getDirectory(dirType: .logs)+"/\(UUID)/\(filename).csv"
        do {
            try fm.removeItem(atPath: logdir)
        }
        catch {
            print(error)
        }
    }
    
    static func getLogFileDirectory(UUID: String, filename: String) -> String {
        let filedir = getDirectory(dirType: .logs)+"/\(UUID)/\(filename).csv"
        let fm = FileManager.default
        if fm.fileExists(atPath: filedir) {
            return filedir
        }
        return ""
    }
    
}
