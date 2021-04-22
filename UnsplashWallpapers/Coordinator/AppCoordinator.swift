//
//  AppCoordinator.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/25.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    // MARK: - Properties
    let window: UIWindow?
    var tabController: UITabBarController
    lazy var rootViewController: UITabBarController = {
        return UITabBarController()
    }()

    // MARK: - Coordinator
    init(navController: UITabBarController, window: UIWindow?) {
        self.tabController = navController
        self.window = window
    }

    override func start() {
        let coordinator = MainCoordinator(rootViewController: tabController)
        coordinator.start()
    }
    
    override func finish() {
        
    }
}
