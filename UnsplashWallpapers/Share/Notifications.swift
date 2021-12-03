//
//  Notifications.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/3.
//

import UIKit

let traitCollectionDidChangeNotification = NSNotification.Name("traitCollectionDidChange")

final class MyWindow: UIWindow {
    private var userInterfaceStyle = UITraitCollection.current.userInterfaceStyle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let currentUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        if currentUserInterfaceStyle != userInterfaceStyle {
            userInterfaceStyle = currentUserInterfaceStyle
            NotificationCenter.default.post(name: traitCollectionDidChangeNotification, object: self)
        }
    }
}
