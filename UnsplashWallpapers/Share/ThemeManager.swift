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
        // First persist the selected theme using NSUserDefaults.
        //UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        //UserDefaults.standard.synchronize()
        
        print("applyTheme \(theme)")
         
        // You get your current (selected) theme and apply the main color to the tintColor property of your application's window.
       //
      //  sharedApplication.delegate?.window??.tintColor = theme.mainColor

        
        //UINavigationBar.appearance().setBackgroundImage(theme.navigationBackgroundImage, for: .default)
        //UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backArrow")
        //UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backArrowMaskFixed")
       // UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.titleTextColor]
      //  UINavigationBar.appearance().barStyle = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .default
      //  UINavigationBar.appearance().barTintColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        
       
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        barAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.titleTextColor]

        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        
        let compactAppearance = barAppearance.copy()
        UINavigationBar.appearance().compactAppearance = compactAppearance
        if #available(iOS 15.0, *) { // For compatibility with earlier iOS.
            UINavigationBar.appearance().compactScrollEdgeAppearance = compactAppearance
        }
        
//        guard let selectVC = rootViewController.selectedViewController else {
//            return
//        }
//
//        selectVC.navigationItem.standardAppearance = barAppearance
//        selectVC.navigationItem.scrollEdgeAppearance = barAppearance
        
        

        let tabBar = UITabBar.appearance()
        
        guard let items = rootViewController.tabBar.items else {
            return
        }
        
        for currentItem in items {
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.badgeTextAttributes = [NSAttributedString.Key.foregroundColor: UITraitCollection.current.userInterfaceStyle == .dark ? UIColor.white : UIColor.black]
            itemAppearance.normal.badgePositionAdjustment = UIOffset(horizontal: 10, vertical: -10)
           
            itemAppearance.normal.iconColor = UIColor.lightGray
            itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
                    
            itemAppearance.selected.iconColor = .systemCyan
            itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemCyan]
            
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
            
            
            tabBarAppearance.stackedLayoutAppearance = itemAppearance
            tabBarAppearance.inlineLayoutAppearance = itemAppearance
            tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
            
            currentItem.standardAppearance = tabBarAppearance
            currentItem.scrollEdgeAppearance = tabBarAppearance
            
        }
        
        //UITabBar.appearance().barStyle = theme.tabBarStyle
//        UITabBar.appearance().barTintColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
//        UITabBar.appearance().unselectedItemTintColor = theme.titleTextColor
        
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

extension UIApplication {

    /// The app's key window taking into consideration apps that support multiple scenes.
    var keyWindowInConnectedScenes: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
