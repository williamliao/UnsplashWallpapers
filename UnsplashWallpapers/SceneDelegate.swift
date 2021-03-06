//
//  SceneDelegate.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let tabController = UITabBarController()
           
        let coordinator = MainCoordinator(rootViewController: tabController)
        coordinator.start()
        mainCoordinator = coordinator
        
//        NotificationCenter.default.addObserver(forName: traitCollectionDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
//            //print("isDark: \(UITraitCollection.current.userInterfaceStyle == .dark)")
//            // Do your things...
//            self?.setupThemeManager(rootViewController: tabController)
//        }
//
//        setupThemeManager(rootViewController: tabController)
        
        window = MyWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = tabController
        window?.makeKeyAndVisible()
        
    }
    
    func setupThemeManager(rootViewController: UITabBarController) {
        let value = UITraitCollection.current.userInterfaceStyle == .light ? 1 : 0
        var themeValue = ThemeManager.Theme.init(rawValue: value)
        
        switch UITraitCollection.current.userInterfaceStyle {
            case .dark:
                themeValue = ThemeManager.Theme.init(rawValue: 0)
            case .light:
                themeValue = ThemeManager.Theme.init(rawValue: 1)
            case .unspecified:
                themeValue = ThemeManager.Theme.init(rawValue: 2)
            @unknown default:
                themeValue = ThemeManager.Theme.init(rawValue: 2)
        }

        UserDefaults.standard.setValue(themeValue?.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        ThemeManager.applyTheme(theme: themeValue!, rootViewController: rootViewController)
//
//        if ((UserDefaults.standard.object(forKey: SelectedThemeKey) == nil)) {
//
//
//        } else {
//            let storeTheme = UserDefaults.standard.object(forKey: SelectedThemeKey) as! Int
//            let theme = ThemeManager.Theme.init(rawValue: storeTheme)
//            ThemeManager.applyTheme(theme: theme ?? .light)
//        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

