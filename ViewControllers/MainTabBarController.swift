//
//  MainTabBarController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 15/07/22.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    static let identifier = "MainTabBarController"
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        DashXUtils.trackEventClient()
        DashXUtils.client1.track("TestEventFromiOSApp")
        setShadowForTaBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setShadowForTaBar()
    }
    
    func setShadowForTaBar() {
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowColor = UIColor(named: "secondaryColorDisabled")?.cgColor
        tabBar.layer.shadowOpacity = 0.5
    }
    
}
