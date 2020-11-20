//
//  VoltageInfoCell.swift
//  Smart BMS Utility
//
//  Created by Justin on 13.10.20.
//

import UIKit
import MBCircularProgressBar

class VoltageInfoCell: UITableViewCell {
    
    @IBOutlet weak var balancingImage: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
