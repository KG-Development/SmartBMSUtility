//
//  VoltageInfoCell.swift
//  Smart BMS Utility
//
//  Created by Justin on 13.10.20.
//

import UIKit
import GradientProgress

class VoltageInfoCell: UITableViewCell {
    
    @IBOutlet weak var balancingImage: UIImageView!
    @IBOutlet weak var progressView: GradientProgressBar!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var voltageWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let accentColor = UIColor(named: "AccentColor")!
        if #available(macOS 10.15, *) {
            progressView.transform = progressView.transform.scaledBy(x: 1, y: 3)
        }
        else {
            progressView.transform = progressView.transform.scaledBy(x: 1, y: 2)
        }
        progressView.gradientColors = [accentColor.cgColor, accentColor.cgColor]
    }


}
