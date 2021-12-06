//
//  ThemeManager.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/11/3.
//

import Foundation
import UIKit

// Enum declaration
let SelectedThemeKey = "light"

struct ThemeManager {
    
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .auto
        }
    }
    
    static func applyTheme(theme: Theme, rootViewController: UITabBarController) {

    }
    
    enum Theme: Int {

        case dark, light, auto

        var mainColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .white
            case .auto:
                return .systemBackground
            }
        }

        //Customizing the Navigation Bar
        var navigationBarStyle: UIBarStyle {
            switch self {
            case .dark:
                return .default
            case .light:
                return .black
            case .auto:
                return UITraitCollection.current.userInterfaceStyle == .light ? .black : .default
            }
        }
        
        var tabBarStyle: UIBarStyle {
            switch self {
            case .dark:
                return .black
            case .light:
                return .default
            case .auto:
                return UITraitCollection.current.userInterfaceStyle == .light ? .default : .black
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .white
            case .auto:
                return .systemBackground
            }
        }
        
        var segmentedSelectedColor: UIColor {
            switch self {
            case .dark:
                return .white
            case .light:
                return .white
            case .auto:
                return UITraitCollection.current.userInterfaceStyle == .light ? .white : .white
            }
        }
        
        var segmentedTitleColor: UIColor {
            switch self {
            case .dark:
                return .white
            case .light:
                return .black
            case .auto:
                return .label
            }
        }
        
        var segmentedSelectedTitleColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .black
            case .auto:
                return .label
            }
        }

        var secondaryColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .white
            case .auto:
                return .systemBackground
            }
        }
        
        var titleTextColor: UIColor {
            switch self {
            case .dark:
                return .white
            case .light:
                return .black
            case .auto:
                return .label
            }
        }
        var subtitleTextColor: UIColor {
            switch self {
            case .dark:
                return .black
            case .light:
                return .lightGray
            case .auto:
                return .secondaryLabel
            }
        }
    }
}

extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
