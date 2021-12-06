//
//  BaseViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adaptToUserInterfaceStyle()
    }
    

    private func adaptToUserInterfaceStyle() {
        let backgroundColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        
        self.view.backgroundColor = backgroundColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }

}
