//
//  loggingViewController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 06.02.21.
//

import Foundation
import UIKit
import BEMCheckBox
import ActionSheetPicker_3_0

class loggingViewController: UITableViewController {
    
    var dirs = [(String, Int)]()
    
    let logIntervalOptions = ["1 second", "2 seconds", "3 seconds", "4 seconds", "5 seconds", "6 seconds", "7 seconds", "8 seconds", "9 seconds", "10 seconds", "11 seconds", "12 seconds", "13 seconds", "14 seconds", "15 seconds", "16 seconds", "17 seconds", "18 seconds", "19 seconds", "20 seconds", "21 seconds", "22 seconds", "23 seconds", "24 seconds", "25 seconds", "26 seconds", "27 seconds", "28 seconds", "29 seconds", "30 seconds", "31 seconds", "32 seconds", "33 seconds", "34 seconds", "35 seconds", "36 seconds", "37 seconds", "38 seconds", "39 seconds", "40 seconds", "41 seconds", "42 seconds", "43 seconds", "44 seconds", "45 seconds", "46 seconds", "47 seconds", "48 seconds", "49 seconds", "50 seconds", "51 seconds", "52 seconds", "53 seconds", "54 seconds", "55 seconds", "56 seconds", "57 seconds", "58 seconds", "59 seconds", "60 seconds", "61 seconds", "62 seconds", "63 seconds", "64 seconds", "65 seconds", "66 seconds", "67 seconds", "68 seconds", "69 seconds", "70 seconds", "71 seconds", "72 seconds", "73 seconds", "74 seconds", "75 seconds", "76 seconds", "77 seconds", "78 seconds", "79 seconds", "80 seconds", "81 seconds", "82 seconds", "83 seconds", "84 seconds", "85 seconds", "86 seconds", "87 seconds", "88 seconds", "89 seconds", "90 seconds", "91 seconds", "92 seconds", "93 seconds", "94 seconds", "95 seconds", "96 seconds", "97 seconds", "98 seconds", "99 seconds", "100 seconds", "101 seconds", "102 seconds", "103 seconds", "104 seconds", "105 seconds", "106 seconds", "107 seconds", "108 seconds", "109 seconds", "110 seconds", "111 seconds", "112 seconds", "113 seconds", "114 seconds", "115 seconds", "116 seconds", "117 seconds", "118 seconds", "119 seconds", "120 seconds", "121 seconds", "122 seconds", "123 seconds", "124 seconds", "125 seconds", "126 seconds", "127 seconds", "128 seconds", "129 seconds", "130 seconds", "131 seconds", "132 seconds", "133 seconds", "134 seconds", "135 seconds", "136 seconds", "137 seconds", "138 seconds", "139 seconds", "140 seconds", "141 seconds", "142 seconds", "143 seconds", "144 seconds", "145 seconds", "146 seconds", "147 seconds", "148 seconds", "149 seconds", "150 seconds", "151 seconds", "152 seconds", "153 seconds", "154 seconds", "155 seconds", "156 seconds", "157 seconds", "158 seconds", "159 seconds", "160 seconds", "161 seconds", "162 seconds", "163 seconds", "164 seconds", "165 seconds", "166 seconds", "167 seconds", "168 seconds", "169 seconds", "170 seconds", "171 seconds", "172 seconds", "173 seconds", "174 seconds", "175 seconds", "176 seconds", "177 seconds", "178 seconds", "179 seconds", "180 seconds", "181 seconds", "182 seconds", "183 seconds", "184 seconds", "185 seconds", "186 seconds", "187 seconds", "188 seconds", "189 seconds", "190 seconds", "191 seconds", "192 seconds", "193 seconds", "194 seconds", "195 seconds", "196 seconds", "197 seconds", "198 seconds", "199 seconds", "200 seconds", "201 seconds", "202 seconds", "203 seconds", "204 seconds", "205 seconds", "206 seconds", "207 seconds", "208 seconds", "209 seconds", "210 seconds", "211 seconds", "212 seconds", "213 seconds", "214 seconds", "215 seconds", "216 seconds", "217 seconds", "218 seconds", "219 seconds", "220 seconds", "221 seconds", "222 seconds", "223 seconds", "224 seconds", "225 seconds", "226 seconds", "227 seconds", "228 seconds", "229 seconds", "230 seconds", "231 seconds", "232 seconds", "233 seconds", "234 seconds", "235 seconds", "236 seconds", "237 seconds", "238 seconds", "239 seconds", "240 seconds", "241 seconds", "242 seconds", "243 seconds", "244 seconds", "245 seconds", "246 seconds", "247 seconds", "248 seconds", "249 seconds", "250 seconds", "251 seconds", "252 seconds", "253 seconds", "254 seconds", "255 seconds", "256 seconds", "257 seconds", "258 seconds", "259 seconds", "260 seconds", "261 seconds", "262 seconds", "263 seconds", "264 seconds", "265 seconds", "266 seconds", "267 seconds", "268 seconds", "269 seconds", "270 seconds", "271 seconds", "272 seconds", "273 seconds", "274 seconds", "275 seconds", "276 seconds", "277 seconds", "278 seconds", "279 seconds", "280 seconds", "281 seconds", "282 seconds", "283 seconds", "284 seconds", "285 seconds", "286 seconds", "287 seconds", "288 seconds", "289 seconds", "290 seconds", "291 seconds", "292 seconds", "293 seconds", "294 seconds", "295 seconds", "296 seconds", "297 seconds", "298 seconds", "299 seconds", "300 seconds"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dirs = fileController.countLogDirectories()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Settings"
        case 1:
            return "Logs for other devices"
        default:
            return ""
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let deviceUUID = DevicesController.getConnectedDevice()?.getIdentifier()
        if dirs.count > 0 {
            for i in 0...dirs.count-1 {
                if dirs[i].0 != deviceUUID {
                    return 2
                }
            }
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            if dirs.count == 0 {
                return 0
            }
            var count = 0
            let deviceUUID = DevicesController.getConnectedDevice()?.getIdentifier() ?? "demo"
            for i in 0...dirs.count-1 {
                if dirs[i].0 != deviceUUID {
                    count += 1
                }
            }
            return count
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "loggingCheckboxCell") as? loggingCheckboxCell
                if cell == nil {
                    return UITableViewCell()
                }
                return cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail") as? rightDetailCell
                if cell == nil {
                    return UITableViewCell()
                }
                cell!.mainLabel.text = "Log interval"
                cell!.detailLabel.text = getIntervalDescription()
                return cell!
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail") as? rightDetailCell
                if cell == nil {
                    return UITableViewCell()
                }
                cell!.mainLabel.text = "View logs"
                let count = getFileCount(for: DevicesController.getConnectedDevice()?.getIdentifier() ?? "demo")
                cell!.detailLabel.text = "\(count) item" + ((count == 1) ? "" : "s")
                if count == 0 {
                    cell?.mainLabel.textColor = .secondaryLabel
                    cell?.accessoryType = .none
                    cell?.isUserInteractionEnabled = false
                    cell?.allowSegue = false
                }
                else {
                    cell?.mainLabel.textColor = .label
                    cell?.accessoryType = .disclosureIndicator
                    cell?.isUserInteractionEnabled = true
                    cell?.allowSegue = true
                }
                return cell!
            default:
                return UITableViewCell()
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetail") as? rightDetailCell
            if cell == nil {
                return UITableViewCell()
            }
            let otherdevice = getOtherDeviceUUIDAndFileCount(index: indexPath.row)
            let devicesettings = fileController.getDeviceSettings(deviceUUID: otherdevice.0)
            cell!.mainLabel.text = devicesettings?.deviceName ?? ((devicesettings?.dongleName ?? "") + "(\(devicesettings?.cellCount ?? 0)S)")
            cell!.detailLabel.text = "\(otherdevice.1) item" + (otherdevice.1 == 1 ? "" : "s")
            cell?.allowSegue = true
            return cell!
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 2 {
            listLogFilesController.uuid = DevicesController.getConnectedDevice()?.getIdentifier() ?? "demo"
        } else if indexPath.section == 1 {
            listLogFilesController.uuid = getOtherDeviceUUIDAndFileCount(index: indexPath.row).0
        } else if indexPath.section == 0 && indexPath.row == 1 {
            let defaultInterval = DevicesController.getConnectedDevice()?.settings.loggingInterval ?? 2
            ActionSheetStringPicker.show(withTitle: "Select log interval", rows: logIntervalOptions, initialSelection: defaultInterval-1, doneBlock: { (picker, indexes, value) in
                let newval = value as? String
                if newval == nil {
                    return
                }
                let parsed = newval!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                let seconds = Int(parsed)
                DevicesController.getConnectedDevice()?.settings.loggingInterval = seconds
                DevicesController.getConnectedDevice()?.saveDeviceSettings()
                self.tableView.reloadData()
            }, cancel: { (_) in
                return
            }, origin: tableView.cellForRow(at: indexPath))
            return
        } else {
            return
        }
        
    }
    
    func getIntervalDescription() -> String {
        let logInterval = DevicesController.getConnectedDevice()?.settings.loggingInterval ?? 2
        
        if logInterval > 59 {
            let minutes = Int(floor(Double(logInterval)/60.0))
            let seconds = logInterval % 60
            if seconds == 0 {
                return "\(minutes)m"
            }
            return "\(minutes)m, \(seconds)s"
        }
        return "\(logInterval)s"
    }
    
    func getFileCount(for uuid: String) -> Int {
        if dirs.count > 0 {
            for i in 0...dirs.count-1 {
                if dirs[i].0 == uuid {
                    return dirs[i].1
                }
            }
        }
        return 0
    }
    
    func getOtherDeviceUUIDAndFileCount(index: Int) -> (String, Int) {
        let deviceUUID = DevicesController.getConnectedDevice()?.getIdentifier() ?? "demo"
        var otherDevices = dirs
        if otherDevices.count > 0 {
            for i in 0...otherDevices.count-1 {
                if otherDevices[i].0 == deviceUUID {
                    otherDevices.remove(at: i)
                    break
                }
            }
        }
        return otherDevices[index]
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let cell = sender as? loggingCheckboxCell {
            return false
        }
        else if let cell = sender as? rightDetailCell {
            return cell.allowSegue
        }
        return false
    }
    
}
