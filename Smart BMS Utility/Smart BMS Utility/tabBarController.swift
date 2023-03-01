//
//  tabBarController.swift
//  Smart BMS Utility
//
//  Created by Justin Kühner on 07.11.20.
//

import UIKit


class tabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate = self
        self.moreNavigationController.navigationBar.isHidden = true
        traitCollectionDidChange(nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.title = item.title
    }
}
