//
//  moreController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 29.11.20.
//

import UIKit

class moreController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 0 {
//            OverviewController.highestVoltage = cmd_basicInformation.totalVoltage
            OverviewController.peakPower = 0.0
            OverviewController.peakCurrent = 0.0
            OverviewController.lowestVoltage = 0.0
            OverviewController.highestVoltage = 0.0
            GPSController.topSpeed = 0.0
            GPSController.maxPower = 0.0
            GPSController.currentSpeed = 0.0
            GPSController.efficiency = 0.0
            tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        }
    }
}
