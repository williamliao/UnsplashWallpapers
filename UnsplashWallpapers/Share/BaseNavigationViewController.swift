//
//  BaseNavigationViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adaptToUserInterfaceStyle()
    }
    

    private func adaptToUserInterfaceStyle() {
        let textColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithDefaultBackground()
        barAppearance.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]

        self.navigationBar.standardAppearance = barAppearance
        self.navigationBar.scrollEdgeAppearance = barAppearance
        
        let compactAppearance = barAppearance.copy()
        self.navigationBar.compactAppearance = compactAppearance
        if #available(iOS 15.0, *) { // For compatibility with earlier iOS.
            self.navigationBar.compactScrollEdgeAppearance = compactAppearance
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
}
