//
//  shareLogCell.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 19.02.21.
//

import UIKit
class shareLogCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var btShare: UIButton!
    
    var filename: String?
    
    @IBAction func shareButton(_ sender: Any) {
        if filename == nil || filename == "" {
            return
        }
        let filepath = NSURL(fileURLWithPath: fileController.getLogFileDirectory(UUID: listLogFilesController.uuid, filename: filename ?? ""))
        
        let activityViewController = UIActivityViewController(activityItems: [filepath], applicationActivities: nil)
        self.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func setupDeleteCell() {
        self.mainLabel.textColor = .red
        self.mainLabel.text = "Clear logs"
        self.detailLabel.isHidden = true
        self.btShare.isHidden = true
        self.accessoryType = .none
    }
    
    func normalizeCell() {
        self.mainLabel.textColor = .label
        self.detailLabel.isHidden = false
        self.btShare.isHidden = false
        self.accessoryType = .disclosureIndicator
    }
    
}
