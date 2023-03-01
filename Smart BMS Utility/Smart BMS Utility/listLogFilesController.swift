//
//  listLogFilesController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 18.02.21.
//

import Foundation
import UIKit

class listLogFilesController: UITableViewController {
    
    var dirs: [String]!
    static var uuid = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = fileController.getDeviceSettings(deviceUUID: listLogFilesController.uuid)?.deviceName
        dirs = fileController.getLogFiles(uuid: listLogFilesController.uuid)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(dirs.count)
        return (section == 0) ? 1 : dirs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shareCell") as? shareLogCell
        if cell == nil {
            return UITableViewCell()
        }
        if indexPath.section == 0 {
            cell?.setupDeleteCell()
            return cell!
        }
        else {
            cell?.filename = dirs[indexPath.row]
            cell?.normalizeCell()
            let filename = reformatFilename(filename: dirs[indexPath.row])
            cell?.mainLabel.text = filename
            let logcount = fileController.logCountForFile(uuid: listLogFilesController.uuid, filename: dirs[indexPath.row])
            cell?.detailLabel.text = "\(logcount) entr" + ((logcount == 1) ? "y" : "ies")
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            deleteAllLogFiles()
            tableView.reloadData()
        }
        else {
            loggingGraphController.filename = dirs[indexPath.row]
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (contextualAction, view, boolValue) in
                
                let alert = UIAlertController(title: "Are you sure?", message: "You are about to delete the log from \(self.reformatFilename(filename: self.dirs[indexPath.row]))", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                    fileController.removeLogfile(UUID: listLogFilesController.uuid, filename: self.dirs[indexPath.row])
                    self.dirs = fileController.getLogFiles(uuid: listLogFilesController.uuid)
                    tableView.reloadData()
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                }
            delete.backgroundColor = .systemRed
            let swipeActions = UISwipeActionsConfiguration(actions: [delete])
            return swipeActions
        }
        return nil
    }
    
    
    func reformatFilename(filename: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let date = dateFormatter.date(from: filename)!
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
        
        return dateFormatter.string(from: date)
    }
    
    func deleteAllLogFiles() {
        let alert = UIAlertController(title: "Are you sure?", message: "You are about to delete all logs from this device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            fileController.clearLogDirectoryForDevice(UUID: listLogFilesController.uuid)
            self.dismiss(animated: true, completion: nil)

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let cell = sender as? shareLogCell
        return cell?.filename != nil
    }
}
