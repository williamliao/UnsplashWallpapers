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
    
    static func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        //UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        //UserDefaults.standard.synchronize()
        
        
         
        // You get your current (selected) theme and apply the main color to the tintColor property of your application's window.
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor

        UINavigationBar.appearance().barStyle = theme.navigationBarStyle
        UINavigationBar.appearance().barTintColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = theme.mainColor

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = barAppearance
        navigationBar.scrollEdgeAppearance = barAppearance
        
         //UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
         //UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
         //UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.titleTextColor]


        UITabBar.appearance().barStyle = theme.tabBarStyle
        UITabBar.appearance().barTintColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        UITabBar.appearance().unselectedItemTintColor = theme.titleTextColor
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = theme.mainColor
        
        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        } else {
            // Fallback on earlier versions
        }
        
        UICollectionView.appearance().tintColor = theme.mainColor
        UICollectionView.appearance().backgroundColor = theme.mainColor
        
        UICollectionViewCell.appearance().backgroundColor = theme.mainColor
        
        UISegmentedControl.appearance().backgroundColor = theme.mainColor
        UISegmentedControl.appearance().selectedSegmentTintColor = theme.segmentedSelectedColor

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.segmentedTitleColor]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: theme.segmentedSelectedTitleColor]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes1, for:.selected)
        
         //UITabBar.appearance().backgroundImage = theme.tabBarBackgroundImage

//         let tabIndicator = UIImage(named: "tabBarSelectionIndicator")?.withRenderingMode(.alwaysTemplate)
//         let tabResizableIndicator = tabIndicator?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
//         UITabBar.appearance().selectionIndicatorImage = tabResizableIndicator

      /*   let controlBackground = UIImage(named: "controlBackground")?.withRenderingMode(.alwaysTemplate)
             .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
         let controlSelectedBackground = UIImage(named: "controlSelectedBackground")?
             .withRenderingMode(.alwaysTemplate)
             .resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))

         UISegmentedControl.appearance().setBackgroundImage(controlBackground, for: .normal, barMetrics: .default)
         UISegmentedControl.appearance().setBackgroundImage(controlSelectedBackground, for: .selected, barMetrics: .default)

         UIStepper.appearance().setBackgroundImage(controlBackground, for: .normal)
         UIStepper.appearance().setBackgroundImage(controlBackground, for: .disabled)
         UIStepper.appearance().setBackgroundImage(controlBackground, for: .highlighted)
         UIStepper.appearance().setDecrementImage(UIImage(named: "fewerPaws"), for: .normal)
         UIStepper.appearance().setIncrementImage(UIImage(named: "morePaws"), for: .normal)

         UISlider.appearance().setThumbImage(UIImage(named: "sliderThumb"), for: .normal)
         UISlider.appearance().setMaximumTrackImage(UIImage(named: "maximumTrack")?
             .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 6.0)), for: .normal)
         UISlider.appearance().setMinimumTrackImage(UIImage(named: "minimumTrack")?
             .withRenderingMode(.alwaysTemplate)
             .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 6.0, bottom: 0, right: 0)), for: .normal)

         UISwitch.appearance().onTintColor = theme.mainColor.withAlphaComponent(0.3)
         UISwitch.appearance().thumbTintColor = theme.mainColor */
         
        
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
