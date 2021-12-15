//
//  BaseTabBarViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adaptToUserInterfaceStyle()
    }
    

    private func adaptToUserInterfaceStyle() {
        
        let tabBar = UITabBar.appearance()
        
        guard let items = self.tabBar.items else {
            return
        }
        
        for currentItem in items {
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.badgeTextAttributes = [NSAttributedString.Key.foregroundColor: UITraitCollection.current.userInterfaceStyle == .dark ? UIColor.white : UIColor.black]
            itemAppearance.normal.badgePositionAdjustment = UIOffset(horizontal: 10, vertical: -10)
           
            itemAppearance.normal.iconColor = UIColor.lightGray
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                    
            if #available(iOS 15.0, *) {
                itemAppearance.selected.iconColor = .systemCyan
                itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemCyan]
            } else {
                // Fallback on earlier versions
            }
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
            
            
            tabBarAppearance.stackedLayoutAppearance = itemAppearance
            tabBarAppearance.inlineLayoutAppearance = itemAppearance
            tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
            tabBar.standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBarAppearance
                currentItem.scrollEdgeAppearance = tabBarAppearance
            }
            currentItem.standardAppearance = tabBarAppearance
            
            
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }

}
